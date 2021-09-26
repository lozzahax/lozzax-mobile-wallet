import 'package:lozzax_coin/transaction_history.dart';
import 'package:lozzax_wallet/src/wallet/lozzax/lozzax_amount_format.dart';
import 'package:lozzax_wallet/src/wallet/lozzax/transaction/transaction_priority.dart';

double calculateEstimatedFee({LozzaxTransactionPriority priority}) {
  return lozzaxAmountToDouble(estimateTransactionFee(priority.raw));
}
