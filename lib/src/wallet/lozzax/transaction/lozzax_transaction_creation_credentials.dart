import 'package:lozzax_wallet/src/wallet/lozzax/transaction/transaction_priority.dart';
import 'package:lozzax_wallet/src/wallet/transaction/transaction_creation_credentials.dart';

class LozzaxTransactionCreationCredentials
    extends TransactionCreationCredentials {
  LozzaxTransactionCreationCredentials(
      {this.address, this.priority, this.amount});

  final String address;
  final String amount;
  final LozzaxTransactionPriority priority;
}
