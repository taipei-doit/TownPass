import 'package:town_pass/util/extension/datetime.dart';

class TPDuration {
  static String string({
    required DateTime start,
    DateTime? end,
    String pattern = 'yyyy/MM/dd',
  }) {
    if (end != null) {
      return '${start.format(pattern)}~${end.format(pattern)}';
    }
    return start.format(pattern);
  }
}
