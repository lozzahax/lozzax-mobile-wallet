import 'package:flutter/foundation.dart';
import 'package:lozzax_coin/transaction_history.dart' as transaction_history;
import 'package:lozzax_coin/lozzax_coin_structs.dart';
import 'package:lozzax_wallet/src/wallet/lozzax/lozzax_amount_format.dart';

class PendingTransaction {
  PendingTransaction(
      {@required this.amount, @required this.fee, @required this.hash});

  PendingTransaction.fromTransactionDescription(
      PendingTransactionDescription transactionDescription)
      : amount = lozzaxAmountToString(transactionDescription.amount),
        fee = lozzaxAmountToString(transactionDescription.fee),
        hash = transactionDescription.hash,
        _pointerAddress = transactionDescription.pointerAddress;

  final String amount;
  final String fee;
  final String hash;

  int _pointerAddress;

  Future<void> commit() async => transaction_history
      .commitTransactionFromPointerAddress(address: _pointerAddress);
}
