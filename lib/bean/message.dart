import 'package:town_pass/bean/tp_rich_text.dart';
import 'package:town_pass/util/json_converter/datetime_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable(explicitToJson: true)
class MessageList {
  final List<MessageItem> data;

  const MessageList({required this.data});

  factory MessageList.fromJson(Map<String, dynamic> json) =>
      _$MessageListFromJson(json);

  Map<String, dynamic> toJson() => _$MessageListToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MessageItem {
  final String title;

  @DateTimeConverter()
  final DateTime datetime;

  final MessageType type;

  @JsonKey(name: 'has_read')
  bool hasRead;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @JsonKey(name: 'rich_text')
  final List<TPRichText>? richText;

  MessageItem({
    required this.title,
    required this.datetime,
    required this.type,
    required this.hasRead,
    this.imageUrl,
    this.richText,
  });

  factory MessageItem.fromJson(Map<String, dynamic> json) =>
      _$MessageItemFromJson(json);

  Map<String, dynamic> toJson() => _$MessageItemToJson(this);
}

const String _personalType = 'PERSONAL';
const String _tcgType = 'TCG';
const String _systemType = 'SYSTEM';

@JsonEnum()
enum MessageType {
  @JsonValue(_personalType)
  personal,
  @JsonValue(_tcgType)
  tcg,
  @JsonValue(_systemType)
  system,
  ;
}
