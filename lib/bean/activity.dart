import 'package:json_annotation/json_annotation.dart';
import 'package:town_pass/util/json_converter/datetime_converter.dart';
import 'package:town_pass/util/tp_duration.dart';

part 'activity.g.dart';

@JsonSerializable(explicitToJson: true)
class ActivityList {
  final List<ActivityItem> data;

  const ActivityList({required this.data});

  factory ActivityList.fromJson(Map<String, dynamic> json) => _$ActivityListFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityListToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ActivityItem {
  final String title;

  @JsonKey(name: 'image_url')
  final String imageUrl;

  @JsonKey(name: 'web_url')
  final String? webUrl;

  @DateTimeConverter()
  @JsonKey(name: 'start_datetime')
  final DateTime startDateTime;

  @DateTimeConverter()
  @JsonKey(name: 'end_datetime')
  final DateTime? endDateTime;

  final String content;

  const ActivityItem({
    required this.webUrl,
    required this.startDateTime,
    this.endDateTime,
    required this.content,
    required this.title,
    required this.imageUrl,
  });

  TPDuration get duration => TPDuration(start: startDateTime, end: endDateTime);

  factory ActivityItem.fromJson(Map<String, dynamic> json) => _$ActivityItemFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityItemToJson(this);
}
