import 'package:intl/intl.dart';

extension TPDateTime on DateTime {
  String format([String pattern = 'yyyy/MM/dd']) {
    return DateFormat(pattern).format(this);
  }
}
