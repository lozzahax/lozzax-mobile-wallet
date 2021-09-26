import 'package:lozzax_wallet/src/wallet/transaction/transaction_creation_credentials.dart';

class LozzaxStakeTransactionCreationCredentials
    extends TransactionCreationCredentials {
  LozzaxStakeTransactionCreationCredentials({this.address, this.amount});

  final String address;
  final String amount;
}
