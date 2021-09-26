import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lozzax_coin/lozzax_coin_structs.dart';
import 'package:lozzax_coin/src/exceptions/creation_transaction_exception.dart';
import 'package:lozzax_coin/src/lozzax_api.dart';
import 'package:lozzax_coin/src/structs/ut8_box.dart';
import 'package:lozzax_coin/src/util/signatures.dart';
import 'package:lozzax_coin/src/util/types.dart';

final stakeCountNative = lozzaxApi
    .lookup<NativeFunction<stake_count>>('stake_count')
    .asFunction<StakeCount>();

final stakeGetAllNative = lozzaxApi
    .lookup<NativeFunction<stake_get_all>>('stake_get_all')
    .asFunction<StakeGetAll>();

final stakeCreateNative = lozzaxApi
    .lookup<NativeFunction<stake_create>>('stake_create')
    .asFunction<StakeCreate>();

final canRequestUnstakeNative = lozzaxApi
    .lookup<NativeFunction<can_request_unstake>>('can_request_stake_unlock')
    .asFunction<CanRequestUnstake>();

final submitStakeUnlockNative = lozzaxApi
    .lookup<NativeFunction<submit_stake_unlock>>('submit_stake_unlock')
    .asFunction<SubmitStakeUnlock>();

PendingTransactionDescription createStakeSync(
    String serviceNodeKey, String amount) {
  final serviceNodeKeyPointer = Utf8.toUtf8(serviceNodeKey);
  final amountPointer = Utf8.toUtf8(amount);
  final errorMessagePointer = allocate<Utf8Box>();
  final pendingTransactionRawPointer = allocate<PendingTransactionRaw>();
  final created = stakeCreateNative(serviceNodeKeyPointer, amountPointer,
          errorMessagePointer, pendingTransactionRawPointer) !=
      0;

  free(serviceNodeKeyPointer);

  if (amountPointer != nullptr) {
    free(amountPointer);
  }

  if (!created) {
    final message = errorMessagePointer.ref.getValue();
    free(errorMessagePointer);
    throw CreationTransactionException(message: message);
  }

  return PendingTransactionDescription(
      amount: pendingTransactionRawPointer.ref.amount,
      fee: pendingTransactionRawPointer.ref.fee,
      hash: pendingTransactionRawPointer.ref.getHash(),
      pointerAddress: pendingTransactionRawPointer.address);
}

PendingTransactionDescription submitStakeUnlockSync(String serviceNodeKey) {
  final serviceNodeKeyPointer = Utf8.toUtf8(serviceNodeKey);
  final errorMessagePointer = allocate<Utf8Box>();
  final pendingTransactionRawPointer = allocate<PendingTransactionRaw>();
  final created = submitStakeUnlockNative(serviceNodeKeyPointer,
          errorMessagePointer, pendingTransactionRawPointer) !=
      0;

  free(serviceNodeKeyPointer);

  if (!created) {
    final message = errorMessagePointer.ref.getValue();
    free(errorMessagePointer);
    throw CreationTransactionException(message: message);
  }

  return PendingTransactionDescription(
      amount: pendingTransactionRawPointer.ref.amount,
      fee: pendingTransactionRawPointer.ref.fee,
      hash: pendingTransactionRawPointer.ref.getHash(),
      pointerAddress: pendingTransactionRawPointer.address);
}
