import 'package:town_pass/util/extension/datetime.dart';

class TPDuration {
  final DateTime start;
  final DateTime? end;

  const TPDuration({
    required this.start,
    required this.end,
  });

  String format([String pattern = 'yyyy/MM/dd']) {
    return switch (end) {
      DateTime end => '${start.format(pattern)}~${end.format(pattern)}',
      null => start.format(pattern),
    };
  }
}
