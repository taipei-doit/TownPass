import 'package:intl/intl.dart';

final Map<String, DateFormat> _dateFormatCache = {};

extension TPDateTime on DateTime {
  String format([String pattern = 'yyyy/MM/dd']) {
    final formatter =
        _dateFormatCache.putIfAbsent(pattern, () => DateFormat(pattern));
    return formatter.format(this);
  }
}
