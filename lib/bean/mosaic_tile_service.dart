import 'package:json_annotation/json_annotation.dart';

part 'mosaic_tile_service.g.dart';

@JsonSerializable(explicitToJson: true)
class MosaicTileService {
  @JsonKey(name: 'data')
  final List<MosaicTileServiceItem> contentList;

  const MosaicTileService({required this.contentList});

  factory MosaicTileService.fromJson(Map<String, dynamic> json) => _$MosaicTileServiceFromJson(json);

  Map<String, dynamic> toJson() => _$MosaicTileServiceToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MosaicTileServiceItem {
  @JsonKey(name: 'main_text')
  final String mainText;

  @JsonKey(name: 'sub_text')
  final String? subText;

  @JsonKey(name: 'icon')
  final String icon;

  @JsonKey(name: 'destination_url')
  final String url;

  const MosaicTileServiceItem({
    required this.mainText,
    this.subText,
    required this.icon,
    required this.url,
  });

  factory MosaicTileServiceItem.fromJson(Map<String, dynamic> json) => _$MosaicTileServiceItemFromJson(json);

  Map<String, dynamic> toJson() => _$MosaicTileServiceItemToJson(this);
}
