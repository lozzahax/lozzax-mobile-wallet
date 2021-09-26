import 'package:lozzax_wallet/generated/l10n.dart';
import 'package:lozzax_wallet/src/domain/common/enumerable_item.dart';

class LozzaxTransactionPriority extends EnumerableItem<int> with Serializable<int> {
  const LozzaxTransactionPriority({String title, int raw})
      : super(title: title, raw: raw);

  static const all = [
    LozzaxTransactionPriority.slow,
    LozzaxTransactionPriority.blink
  ];

  static const slow = LozzaxTransactionPriority(title: 'Slow', raw: 1);
  static const blink = LozzaxTransactionPriority(title: 'Blink', raw: 5);
  static const standard = blink;

  static LozzaxTransactionPriority deserialize({int raw}) {
    switch (raw) {
      case 1:
        return slow;
      case 5:
        return blink;
      default:
        return null;
    }
  }

  @override
  String toString() {
    switch (this) {
      case LozzaxTransactionPriority.slow:
        return S.current.transaction_priority_slow;
      case LozzaxTransactionPriority.blink:
        return S.current.transaction_priority_blink;
      default:
        return '';
    }
  }
}
