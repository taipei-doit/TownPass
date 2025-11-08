import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:town_pass/models/attraction.dart';

class AttractionService {
  static const String _baseUrl =
      'https://www.travel.taipei/open-api/zh-tw/Attractions/All';

  Future<ApiResponse> fetchAttractions({
    double nlat = 25.058972,
    double elong = 121.513278,
    int page = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl?nlat=$nlat&elong=$elong&page=$page');
    final response = await http.get(
      uri,
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.fromJson(jsonBody);
    } else {
      throw Exception('Failed to load attractions: ${response.statusCode}');
    }
  }
}
