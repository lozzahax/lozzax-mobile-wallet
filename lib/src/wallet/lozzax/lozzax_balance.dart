import 'package:flutter/foundation.dart';
import 'package:lozzax_wallet/src/wallet/balance.dart';

class LozzaxBalance extends Balance {
  LozzaxBalance({@required this.fullBalance, @required this.unlockedBalance});

  final int fullBalance;
  final int unlockedBalance;
}
