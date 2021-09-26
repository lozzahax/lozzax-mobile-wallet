import 'package:intl/intl.dart';

final dateFormat = DateFormat('yyyy-MM');
final dates = {
  '2021-09': 1627
};

int getHeightByDate({DateTime date}) {
  final raw = '${date.year}-${date.month < 10 ? '0${date.month}' : date.month}';
  final firstDate = dateFormat.parse(dates.keys.first);
  var height = dates[raw] ?? 0;

  if (height <= 0 && date.isAfter(firstDate)) {
    height = dates.values.last;
  }

  return height;
}
