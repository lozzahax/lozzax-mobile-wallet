import 'package:intl/intl.dart';
import 'package:lozzax_wallet/src/wallet/crypto_amount_format.dart';

const lozzaxAmountDivider = 1000000000;

String lozzaxAmountToString(int amount,
    {AmountDetail detail = AmountDetail.ultra}) {
  final lozzaxAmountFormat = NumberFormat()
    ..maximumFractionDigits = detail.fraction
    ..minimumFractionDigits = 1;
  return lozzaxAmountFormat.format(lozzaxAmountToDouble(amount));
}

double lozzaxAmountToDouble(int amount) =>
    cryptoAmountToDouble(amount: amount, divider: lozzaxAmountDivider);
