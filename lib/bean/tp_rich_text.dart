import 'package:json_annotation/json_annotation.dart';

part 'tp_rich_text.g.dart';

@JsonSerializable(explicitToJson: true)
class TPRichText {
  final String? text;
  final String? url;

  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final List<TPRichTextStyle?>? style;

  const TPRichText({
    this.text,
    this.url,
    this.style,
  });

  factory TPRichText.fromJson(Map<String, dynamic> json) =>
      _$TPRichTextFromJson(json);

  Map<String, dynamic> toJson() => _$TPRichTextToJson(this);
}

@JsonEnum()
enum TPRichTextStyle {
  @JsonValue('ITALIC')
  italic,
  @JsonValue('BOLD')
  bold,
  @JsonValue('UNDERLINE')
  underline,
  ;
}

extension TPRichTextExtension on TPRichText {
  bool get hasStyle => style != null && style!.isNotEmpty;
}
