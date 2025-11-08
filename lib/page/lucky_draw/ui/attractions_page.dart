import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/models/attraction.dart';
import 'package:town_pass/service/attraction_service.dart';
import 'package:town_pass/service/geo_locator_service.dart';
import 'package:town_pass/util/tp_button.dart';
import 'package:town_pass/util/tp_card.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:town_pass/service/attraction_service.dart';
import 'package:town_pass/models/attraction.dart';


class AttractionListPage extends StatelessWidget {
  const AttractionListPage({super.key});

  Future<ApiResponse> _loadAttractions() async {
    final geoService = Get.find<GeoLocatorService>(); // find the service
    final position = await geoService.position();

    final service = AttractionService();
    return await service.fetchAttractions(
      nlat: position.latitude,
      elong: position.longitude,
      page: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('城心誠靈  |  XXXX'),
        backgroundColor: TPColors.secondary50,
      ),
      body: FutureBuilder<ApiResponse>(
        future: _loadAttractions(), // fetch with GPS
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
            return const Center(child: Text('No attractions found.'));
          }

          final attractions = snapshot.data!.data;

          return Stack(
            children: [
              Container(color: TPColors.white),
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const TPText(
                    '推薦寺廟',
                    style: TPTextStyles(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.asset(
                      'assets/image/temple.jpeg',
                      fit: BoxFit.fitWidth,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TPText(
                      '我是介紹文字，我是介紹文字，我是介紹文字，我是介紹文字。我是介紹文字，我是介紹文字，我是介紹文字，我是介紹文字。我是介紹文字，我是介紹文字，我是介紹文字，我是介紹文字。我是介紹文字，我是介紹文字，我是介紹文字，我是介紹文字。'),
                  const SizedBox(height: 24),
                  const TPText(
                    '附近景點',
                    style: TPTextStyles(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  ...attractions.map((attraction) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TPCard(
                        backgroundColor: TPColors.secondary100,
                        cornerRadius: 16,
                        child: ListTile(
                            title: TPText(
                              attraction.name,
                              style: const TPTextStyles(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: TPText(attraction.address),
                            leading: attraction.images.isNotEmpty &&
                                    attraction.images.first.src.isNotEmpty
                                ? Image.network(
                                    attraction.images.first.src,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image_not_supported,
                                    size: 60),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true, // 可以全屏高度
                                isDismissible: true, // 點背景或向下滑都會關閉
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24)),
                                ),
                                builder: (context) {
                                  return DraggableScrollableSheet(
                                    expand: false,
                                    initialChildSize: 0.5, // 初始高度
                                    minChildSize: 0.3, // 最小高度
                                    maxChildSize: 0.9, // 最大高度
                                    builder: (context, scrollController) {
                                      return SingleChildScrollView(
                                        controller: scrollController,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Center(
                                                child: Container(
                                                  width: 50,
                                                  height: 5,
                                                  margin: const EdgeInsets.only(
                                                      bottom: 16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                              ),
                                              TPText(
                                                attraction.name,
                                                style: const TPTextStyles(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              TPText(attraction.address),
                                              const SizedBox(height: 16),
                                              TPText(
                                                attraction.introduction,
                                                style: const TPTextStyles(
                                                    fontSize: 16),
                                              ),
                                              const SizedBox(height: 24),
                                              Center(
                                                child: TPButton(
                                                  text: '前往查看詳情',
                                                  onPressed: () async {
                                                    final uri = Uri.parse(
                                                        attraction.url);
                                                    if (await canLaunchUrl(
                                                        uri)) {
                                                      await launchUrl(uri,
                                                          mode: LaunchMode
                                                              .externalApplication);
                                                    }
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            }),
                      ),
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
