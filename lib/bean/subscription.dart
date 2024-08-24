import 'package:town_pass/util/json_converter/datetime_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subscription.g.dart';

@JsonSerializable(explicitToJson: true)
class SubscriptionList {
  @JsonKey(name: '')
  final List<SubscriptionItem> list;

  const SubscriptionList({required this.list});

  factory SubscriptionList.fromJson(Map<String, dynamic> json) => _$SubscriptionListFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionListToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SubscriptionItem {
  final String title;

  final String content;

  @JsonKey(name: 'web_url')
  final String? webUrl;

  @DateTimeConverter()
  final DateTime datetime;

  const SubscriptionItem({
    required this.title,
    required this.content,
    this.webUrl,
    required this.datetime,
  });

  factory SubscriptionItem.fromJson(Map<String, dynamic> json) => _$SubscriptionItemFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionItemToJson(this);
}
