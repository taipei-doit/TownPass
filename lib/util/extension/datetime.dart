import 'package:intl/intl.dart';

// 針對重複使用的日期格式模式，快取 DateFormat 實例以提升效能。
// 避免在每次呼叫時重複建立昂貴的 DateFormat 物件。
final Map<String, DateFormat> _dateFormatCache = {};

extension TPDateTime on DateTime {
  String format([String pattern = 'yyyy/MM/dd']) {
    // 嘗試從快取中取得對應模式的 DateFormat 實例。
    // 如果不存在，則建立一個新的實例並將其加入快取中以供後續使用。
    final formatter = _dateFormatCache.putIfAbsent(pattern, () => DateFormat(pattern));
    return formatter.format(this);
  }
}