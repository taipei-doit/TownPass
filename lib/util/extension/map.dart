import 'dart:convert';

extension JsonPrettyFormatExtension on Map<String, dynamic> {
  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  /// Debug usage. Output formatted json string.
  String get prettyFormat {
    return _encoder.convert(this);
  }
}