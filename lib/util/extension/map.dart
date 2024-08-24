import 'dart:convert';

extension JsonPrettyFormatExtension on Map<String, dynamic> {

  /// Debug usage. Output formatted json string.
  String get prettyFormat {
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(this);
  }
}
