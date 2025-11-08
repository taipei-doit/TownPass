// lib/models/image_info.dart (這個保持不變)
class ImageInfo {
  final String src;
  final String subject;
  final String ext;

  ImageInfo({
    required this.src,
    required this.subject,
    required this.ext,
  });

  factory ImageInfo.fromJson(Map<String, dynamic> json) {
    return ImageInfo(
      src: json['src'] ?? '', // 提供預設值以防 null
      subject: json['subject'] ?? '',
      ext: json['ext'] ?? '',
    );
  }
}

// lib/models/category.dart (新增這個模型)
class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

// lib/models/attraction.dart (修正這個檔案)
class Attraction {
  final int id;
  final String name;
  final String? nameZh; // 新增 name_zh 欄位，可能為 null
  final int openStatus; // 新增 open_status
  final String introduction;
  final String openTime;
  final String zipcode; // 新增 zipcode
  final String distric;
  final String address;
  final String tel;
  final String? fax; // 可能為 null
  final String? email; // 可能為 null
  final String months; // 新增 months
  final double nlat;
  final double elong;
  final String? officialSite; // 可能為 null
  final String? facebook; // 可能為 null
  final String? ticket; // 可能為 null
  final String? remind; // 可能為 null
  final String? staytime; // 可能為 null
  final String modified;
  final String url;
  final List<Category> category; // 修正為 Category 列表
  final List<dynamic> target; // 先用 dynamic 處理，若有固定結構再建立模型
  final List<dynamic> service; // 先用 dynamic 處理
  final List<dynamic> friendly; // 先用 dynamic 處理
  final List<ImageInfo> images;
  final List<dynamic> files; // 先用 dynamic 處理
  final List<dynamic> links; // 先用 dynamic 處理

  Attraction({
    required this.id,
    required this.name,
    this.nameZh,
    required this.openStatus,
    required this.introduction,
    required this.openTime,
    required this.zipcode,
    required this.distric,
    required this.address,
    required this.tel,
    this.fax,
    this.email,
    required this.months,
    required this.nlat,
    required this.elong,
    this.officialSite,
    this.facebook,
    this.ticket,
    this.remind,
    this.staytime,
    required this.modified,
    required this.url,
    required this.category,
    required this.target,
    required this.service,
    required this.friendly,
    required this.images,
    required this.files,
    required this.links,
  });

  factory Attraction.fromJson(Map<String, dynamic> json) {
    return Attraction(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameZh: json['name_zh'], // 可能為 null
      openStatus: json['open_status'] ?? 0,
      introduction: json['introduction'] ?? '',
      openTime: json['open_time'] ?? '',
      zipcode: json['zipcode'] ?? '',
      distric: json['distric'] ?? '',
      address: json['address'] ?? '',
      tel: json['tel'] ?? '',
      fax: json['fax'], // 可能為 null
      email: json['email'], // 可能為 null
      months: json['months'] ?? '',
      nlat: (json['nlat'] as num?)?.toDouble() ?? 0.0,
      elong: (json['elong'] as num?)?.toDouble() ?? 0.0,
      officialSite: json['official_site'], // 可能為 null
      facebook: json['facebook'], // 可能為 null
      ticket: json['ticket'], // 可能為 null
      remind: json['remind'], // 可能為 null
      staytime: json['staytime'], // 可能為 null
      modified: json['modified'] ?? '',
      url: json['url'] ?? '',
      category: (json['category'] as List?)
              ?.map((i) => Category.fromJson(i))
              .toList() ??
          [],
      target: json['target'] as List? ?? [],
      service: json['service'] as List? ?? [],
      friendly: json['friendly'] as List? ?? [],
      images: (json['images'] as List?)
              ?.map((i) => ImageInfo.fromJson(i))
              .toList() ??
          [],
      files: json['files'] as List? ?? [],
      links: json['links'] as List? ?? [],
    );
  }
}

// lib/models/api_response.dart (這個保持不變，因為頂層結構沒有變)
class ApiResponse {
  final List<Attraction> data;
  final int total;

  ApiResponse({required this.data, required this.total});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      data: (json['data'] as List).map((i) => Attraction.fromJson(i)).toList(),
      total: json['total'] ?? 0,
    );
  }
}
