import 'package:json_annotation/json_annotation.dart';

part 'home_banner.g.dart';

@JsonSerializable(explicitToJson: true)
class HomeBannerList {
  final List<HomeBannerItem> data;

  const HomeBannerList({required this.data});

  factory HomeBannerList.fromJson(Map<String, dynamic> json) => _$HomeBannerListFromJson(json);

  Map<String, dynamic> toJson() => _$HomeBannerListToJson(this);
}

@JsonSerializable(explicitToJson: true)
class HomeBannerItem {
  @JsonKey(name: 'image_url')
  final String imageUrl;

  @JsonKey(name: 'web_url')
  final String webUrl;

  @JsonKey(name: 'title')
  final String title;

  const HomeBannerItem({
    required this.imageUrl,
    required this.webUrl,
    required this.title,
  });

  factory HomeBannerItem.fromJson(Map<String, dynamic> json) => _$HomeBannerItemFromJson(json);

  Map<String, dynamic> toJson() => _$HomeBannerItemToJson(this);
}
