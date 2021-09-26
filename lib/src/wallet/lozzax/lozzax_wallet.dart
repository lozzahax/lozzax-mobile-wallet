import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:lozzax_coin/stake.dart' as lozzax_stake;
import 'package:lozzax_coin/transaction_history.dart' as transaction_history;
import 'package:lozzax_coin/wallet.dart' as lozzax_wallet;
import 'package:lozzax_wallet/src/node/node.dart';
import 'package:lozzax_wallet/src/node/sync_status.dart';
import 'package:lozzax_wallet/src/wallet/balance.dart';
import 'package:lozzax_wallet/src/wallet/lozzax/account.dart';
import 'package:lozzax_wallet/src/wallet/lozzax/account_list.dart';
import 'package:lozzax_wallet/src/wallet/lozzax/lozzax_balance.dart';
import 'package:lozzax_wallet/src/wallet/lozzax/subaddress.dart';
import 'package:lozzax_wallet/src/wallet/lozzax/subaddress_list.dart';
import 'package:lozzax_wallet/src/wallet/lozzax/transaction/lozzax_stake_transaction_creation_credentials.dart';
import 'package:lozzax_wallet/src/wallet/lozzax/transaction/lozzax_transaction_creation_credentials.dart';
import 'package:lozzax_wallet/src/wallet/lozzax/transaction/lozzax_transaction_history.dart';
import 'package:lozzax_wallet/src/wallet/transaction/pending_transaction.dart';
import 'package:lozzax_wallet/src/wallet/transaction/transaction_creation_credentials.dart';
import 'package:lozzax_wallet/src/wallet/transaction/transaction_history.dart';
import 'package:lozzax_wallet/src/wallet/wallet.dart';
import 'package:lozzax_wallet/src/wallet/wallet_info.dart';
import 'package:lozzax_wallet/src/wallet/wallet_type.dart';
import 'package:rxdart/rxdart.dart';

const lozzaxBlockSize = 1000;

class LozzaxWallet extends Wallet {
  LozzaxWallet({this.walletInfoSource, this.walletInfo}) {
    _cachedBlockchainHeight = 0;
    _name = BehaviorSubject<String>();
    _address = BehaviorSubject<String>();
    _syncStatus = BehaviorSubject<SyncStatus>();
    _onBalanceChange = BehaviorSubject<LozzaxBalance>();
    _account = BehaviorSubject<Account>()..add(Account(id: 0));
    _subaddress = BehaviorSubject<Subaddress>();
  }

  static Future<LozzaxWallet> createdWallet(
      {Box<WalletInfo> walletInfoSource,
      String name,
      bool isRecovery = false,
      int restoreHeight = 0}) async {
    const type = WalletType.lozzax;
    final id = walletTypeToString(type).toLowerCase() + '_' + name;
    final walletInfo = WalletInfo(
        id: id,
        name: name,
        type: type,
        isRecovery: isRecovery,
        restoreHeight: restoreHeight,
        timestamp: DateTime.now().millisecondsSinceEpoch);
    await walletInfoSource.add(walletInfo);

    return await configured(
        walletInfo: walletInfo, walletInfoSource: walletInfoSource);
  }

  static Future<LozzaxWallet> load(
      Box<WalletInfo> walletInfoSource, String name, WalletType type) async {
    final id = walletTypeToString(type).toLowerCase() + '_' + name;
    final walletInfo = walletInfoSource.values
        .firstWhere((info) => info.id == id, orElse: () => null);
    return await configured(
        walletInfoSource: walletInfoSource, walletInfo: walletInfo);
  }

  static Future<LozzaxWallet> configured(
      {@required Box<WalletInfo> walletInfoSource,
      @required WalletInfo walletInfo}) async {
    final wallet =
        LozzaxWallet(walletInfoSource: walletInfoSource, walletInfo: walletInfo);

    if (walletInfo.isRecovery) {
      wallet.setRecoveringFromSeed();

      if (walletInfo.restoreHeight != null) {
        wallet.setRefreshFromBlockHeight(height: walletInfo.restoreHeight);
      }
    }

    return wallet;
  }

  @override
  String get address => _address.value;

  @override
  String get name => _name.value;

  @override
  WalletType getType() => WalletType.lozzax;

  @override
  Observable<SyncStatus> get syncStatus => _syncStatus.stream;

  @override
  Observable<Balance> get onBalanceChange => _onBalanceChange.stream;

  @override
  Observable<String> get onNameChange => _name.stream;

  @override
  Observable<String> get onAddressChange => _address.stream;

  Observable<Account> get onAccountChange => _account.stream;

  Observable<Subaddress> get subaddress => _subaddress.stream;

  bool get isRecovery => walletInfo.isRecovery;

  Account get account => _account.value;

  Box<WalletInfo> walletInfoSource;
  WalletInfo walletInfo;

  lozzax_wallet.SyncListener _listener;
  BehaviorSubject<Account> _account;
  BehaviorSubject<LozzaxBalance> _onBalanceChange;
  BehaviorSubject<SyncStatus> _syncStatus;
  BehaviorSubject<String> _name;
  BehaviorSubject<String> _address;
  BehaviorSubject<Subaddress> _subaddress;
  int _cachedBlockchainHeight;

  TransactionHistory _cachedTransactionHistory;
  SubaddressList _cachedSubaddressList;
  AccountList _cachedAccountList;
  Future<int> _cachedGetNodeHeightOrUpdateRequest;

  @override
  Future updateInfo() async {
    _name.value = await getName();
    final acccountList = getAccountList();
    acccountList.refresh();
    _account.value = acccountList.getAll().first;
    final subaddressList = getSubaddress();
    await subaddressList.refresh(
        accountIndex: _account.value != null ? _account.value.id : 0);
    final subaddresses = subaddressList.getAll();
    _subaddress.value = subaddresses.first;
    _address.value = await getAddress();
    setListeners();
  }

  @override
  Future<String> getFilename() async => lozzax_wallet.getFilename();

  @override
  Future<String> getName() async => getFilename()
      .then((filename) => filename.split('/'))
      .then((splitted) => splitted.last);

  @override
  Future<String> getAddress() async => lozzax_wallet.getAddress(
      accountIndex: _account.value.id, addressIndex: _subaddress.value.id);

  @override
  Future<String> getSeed() async => lozzax_wallet.getSeed();

  @override
  Future<int> getFullBalance() async {
    final balance = await lozzax_wallet.getFullBalance(accountIndex: _account.value.id);
    return balance;
  }

  @override
  Future<int> getUnlockedBalance() async {
    final balance = await lozzax_wallet.getUnlockedBalance(accountIndex: _account.value.id);
    return balance;
  }

  @override
  int getCurrentHeight() => lozzax_wallet.getCurrentHeight();

  @override
  bool isRefreshing() => lozzax_wallet.isRefreshing();

  @override
  Future<int> getNodeHeight() async {
    _cachedGetNodeHeightOrUpdateRequest ??=
        lozzax_wallet.getNodeHeight().then((value) {
      _cachedGetNodeHeightOrUpdateRequest = null;
      return value;
    });

    return _cachedGetNodeHeightOrUpdateRequest;
  }

  @override
  Future<bool> isConnected() async => lozzax_wallet.isConnected();

  @override
  Future<Map<String, String>> getKeys() async => {
        'publicViewKey': lozzax_wallet.getPublicViewKey(),
        'privateViewKey': lozzax_wallet.getSecretViewKey(),
        'publicSpendKey': lozzax_wallet.getPublicSpendKey(),
        'privateSpendKey': lozzax_wallet.getSecretSpendKey()
      };

  @override
  TransactionHistory getHistory() {
    _cachedTransactionHistory ??= LozzaxTransactionHistory();

    return _cachedTransactionHistory;
  }

  SubaddressList getSubaddress() {
    _cachedSubaddressList ??= SubaddressList();

    return _cachedSubaddressList;
  }

  AccountList getAccountList() {
    _cachedAccountList ??= AccountList();

    return _cachedAccountList;
  }

  @override
  Future close() async {
    _listener?.stop();
    lozzax_wallet.closeCurrentWallet();
    await _name.close();
    await _address.close();
    await _subaddress.close();
  }

  @override
  Future connectToNode(
      {Node node, bool useSSL = false, bool isLightWallet = false}) async {
    try {
      _syncStatus.value = ConnectingSyncStatus();

      // Check if node is online to avoid crash
      final nodeIsOnline = await node.isOnline();
      if (!nodeIsOnline) {
        _syncStatus.value = FailedSyncStatus();
        return;
      }

      await lozzax_wallet.setupNode(
          address: node.uri,
          login: node.login,
          password: node.password,
          useSSL: useSSL,
          isLightWallet: isLightWallet);
      _syncStatus.value = ConnectedSyncStatus();
    } catch (e) {
      _syncStatus.value = FailedSyncStatus();
      print(e);
    }
  }

  @override
  Future startSync() async {
    try {
      _setInitialHeight();
    } catch (_) {}

    print('Starting from height: ${getCurrentHeight()}');

    try {
      _syncStatus.value = StartingSyncStatus();
      lozzax_wallet.startRefresh();
      _setListeners();
      _listener?.start();
    } catch (e) {
      _syncStatus.value = FailedSyncStatus();
      print(e);
      rethrow;
    }
  }

  Future<int> getNodeHeightOrUpdate(int baseHeight) async {
    if (_cachedBlockchainHeight < baseHeight) {
      _cachedBlockchainHeight = await getNodeHeight();
    }

    return _cachedBlockchainHeight;
  }

  @override
  Future<PendingTransaction> createStake(
      TransactionCreationCredentials credentials) async {
    final _credentials = credentials as LozzaxStakeTransactionCreationCredentials;
    if (_credentials.amount == null || _credentials.address == null) {
      return Future.error('Amount and address cannot be null.');
    }
    final transactionDescription =
    await lozzax_stake.createStake(_credentials.address, _credentials.amount);

    return PendingTransaction.fromTransactionDescription(
        transactionDescription);
  }

  @override
  Future<PendingTransaction> createTransaction(
      TransactionCreationCredentials credentials) async {
    final _credentials = credentials as LozzaxTransactionCreationCredentials;
    final transactionDescription = await transaction_history.createTransaction(
        address: _credentials.address,
        amount: _credentials.amount,
        priorityRaw: _credentials.priority.serialize(),
        accountIndex: _account.value.id);

    return PendingTransaction.fromTransactionDescription(
        transactionDescription);
  }

  @override
  Future rescan({int restoreHeight = 0}) async {
    _syncStatus.value = StartingSyncStatus();
    setRefreshFromBlockHeight(height: restoreHeight);
    lozzax_wallet.rescanBlockchainAsync();
    _syncStatus.value = StartingSyncStatus();
  }

  void setRecoveringFromSeed() =>
      lozzax_wallet.setRecoveringFromSeed(isRecovery: true);

  void setRefreshFromBlockHeight({int height}) =>
      lozzax_wallet.setRefreshFromBlockHeight(height: height);

  Future setAsRecovered() async {
    walletInfo.isRecovery = false;
    await walletInfo.save();
  }

  Future askForUpdateBalance() async {
    final fullBalance = await getFullBalance();
    final unlockedBalance = await getUnlockedBalance();
    final needToChange = _onBalanceChange.value != null
        ? _onBalanceChange.value.fullBalance != fullBalance ||
        _onBalanceChange.value.unlockedBalance != unlockedBalance
        : true;

    if (!needToChange) {
      return;
    }

    _onBalanceChange.add(LozzaxBalance(
        fullBalance: fullBalance, unlockedBalance: unlockedBalance));
  }

  Future askForUpdateTransactionHistory() async {
    await getHistory().update();
  }

  void changeCurrentSubaddress(Subaddress subaddress) =>
      _subaddress.value = subaddress;

  void changeAccount(Account account) {
    _account.add(account);

    getSubaddress()
        .refresh(accountIndex: account.id)
        .then((dynamic _) => getSubaddress().getAll())
        .then((subaddresses) => _subaddress.value = subaddresses[0]);
  }

  lozzax_wallet.SyncListener setListeners() =>
      lozzax_wallet.setListeners(_onNewBlock, _onNewTransaction);

  Future _onNewBlock(int height, int blocksLeft, double ptc, bool isRefreshing) async {
    try {
      if (isRefreshing) {
        _syncStatus.add(SyncingSyncStatus(blocksLeft, ptc));
      } else {
        await askForUpdateTransactionHistory();
        await askForUpdateBalance();

        if (blocksLeft < 100) {
          _syncStatus.add(SyncedSyncStatus());
          await lozzax_wallet.store();

          if (walletInfo.isRecovery) {
            await setAsRecovered();
          }
        }

        if (blocksLeft <= 1) {
          lozzax_wallet.setRefreshFromBlockHeight(height: height);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _setListeners() {
    _listener?.stop();
    _listener = lozzax_wallet.setListeners(_onNewBlock, _onNewTransaction);
  }

  void _setInitialHeight() {
    if (walletInfo.isRecovery) {
      return;
    }

    final currentHeight = getCurrentHeight();
    print('setInitialHeight() $currentHeight');

    if (currentHeight <= 1) {
      final height = _getHeightByDate(walletInfo.date);
      lozzax_wallet.setRecoveringFromSeed(isRecovery: true);
      lozzax_wallet.setRefreshFromBlockHeight(height: height);
    }
  }

  int _getHeightDistance(DateTime date) {
    final distance =
        DateTime.now().millisecondsSinceEpoch - date.millisecondsSinceEpoch;
    final daysTmp = (distance / 86400).round();
    final days = daysTmp < 1 ? 1 : daysTmp;

    return days * 1000;
  }

  int _getHeightByDate(DateTime date) {
    final nodeHeight = lozzax_wallet.getNodeHeightSync();
    final heightDistance = _getHeightDistance(date);

    if (nodeHeight <= 0) {
      return 0;
    }

    return nodeHeight - heightDistance;
  }

  Future _onNewTransaction() async {
    try {
      await askForUpdateTransactionHistory();
      await askForUpdateBalance();
    } catch (e) {
      print(e.toString());
    }
  }
}
