class Attraction {
  Attraction({
    required this.id,
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
  });

  final String id;
  final String displayName;
  final double latitude;
  final double longitude;
  final String imageUrl;

  factory Attraction.fromJson(Map<String, dynamic> json) {
    final String? nameZh = _asString(json['name_zh']);
    final String? name = _asString(json['name']);
    final List<dynamic>? images = json['images'] as List<dynamic>?;
    final Map<String, dynamic>? firstImage =
        images?.whereType<Map<String, dynamic>>().firstWhere(
              (element) => _asString(element['src']) != null,
              orElse: () => <String, dynamic>{},
            );
    final double? lat = _asNum(json['nlat'])?.toDouble();
    final double? lon = _asNum(json['elong'])?.toDouble();
    final String? imageUrl = _asString(firstImage?['src']);

    if (lat == null || lon == null || imageUrl == null || (nameZh ?? name) == null) {
      throw const FormatException('Attraction data missing required fields');
    }

    return Attraction(
      id: (json['id'] ?? '').toString(),
      displayName: nameZh?.isNotEmpty == true ? nameZh! : name!,
      latitude: lat,
      longitude: lon,
      imageUrl: imageUrl,
    );
  }

  static Attraction? tryParse(Map<String, dynamic> json) {
    try {
      return Attraction.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  static String? _asString(dynamic value) => switch (value) {
        String v when v.isNotEmpty => v,
        _ => null,
      };

  static num? _asNum(dynamic value) => switch (value) {
        num v => v,
        String v => num.tryParse(v),
        _ => null,
      };
}
