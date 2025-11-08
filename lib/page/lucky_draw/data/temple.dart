import 'dart:convert';

import 'package:flutter/services.dart';

class TempleDataService {
  static final TempleDataService instance = TempleDataService._();
  static Future<List<Temple>>? _temples;

  Future<List<Temple>> get temples => _temples ??= _loadTemples();

  TempleDataService._();

  Future<List<Temple>> _loadTemples() async {
    final String jsonString = await rootBundle.loadString('assets/temple.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    return jsonData.map((item) => Temple.fromJson(item)).toList();
  }
}

class Temple {
  final int id;
  final String city;
  final String district;
  final String name;
  final String attribute;
  final String merit;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final String introduction;

  Temple({
    required this.id,
    required this.city,
    required this.district,
    required this.name,
    required this.attribute,
    required this.merit,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.introduction,
  });

  factory Temple.fromJson(Map<String, dynamic> json) {
    return Temple(
      id: json['編號'] ?? 0,
      city: json['縣市'] ?? '',
      district: json['區別'] ?? '',
      name: json['temple_name'] ?? '',
      attribute: json['團體屬性'] ?? '',
      merit: json['績優項目'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['src'] ?? '',
      introduction: json['intro'] ?? '',
    );
  }
}
