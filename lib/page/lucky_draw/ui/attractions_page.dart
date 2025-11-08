import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/models/attraction.dart';
import 'package:town_pass/page/lucky_draw/ui/lucky_draw_app_bar.dart';
import 'package:town_pass/service/attraction_service.dart';
import 'package:town_pass/service/geo_locator_service.dart';
import 'package:town_pass/util/tp_button.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

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
      appBar: const LuckyDrawAppBar(title: '推薦宮廟及附近景點'),
      backgroundColor: TPColors.secondary50,
      body: FutureBuilder<ApiResponse>(
        future: _loadAttractions(), // fetch with GPS
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // show shimmer skeletons for image + text while loading
            return _loadingPlaceholder;
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
            return const Center(child: Text('No attractions found.'));
          }

          final attractions = snapshot.data!.data;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const TPText(
                '推薦宮廟',
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
                '我是介紹文字，我是介紹文字，我是介紹文字，我是介紹文字。我是介紹文字，我是介紹文字，我是介紹文字，我是介紹文字。我是介紹文字，我是介紹文字，我是介紹文字，我是介紹文字。我是介紹文字，我是介紹文字，我是介紹文字，我是介紹文字。',
              ),
              const SizedBox(height: 24),
              const TPText(
                '附近景點',
                style: TPTextStyles(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 12),
              for (var attraction in attractions)
                _attractionTile(attraction, context),
            ],
          );
        },
      ),
    );
  }

  Widget get _loadingPlaceholder => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 24,
              width: 180,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 12),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                height: 140,
                width: double.infinity,
                color: Colors.grey.shade300,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 12,
                    width: double.infinity,
                    color: Colors.grey.shade300),
                const SizedBox(height: 6),
                Container(
                    height: 12,
                    width: double.infinity,
                    color: Colors.grey.shade300),
                const SizedBox(height: 6),
                Container(
                    height: 12,
                    width: double.infinity,
                    color: Colors.grey.shade300),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 20,
              width: 120,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 12),
          // placeholder list tiles
          for (int i = 0; i < 5; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Row(
                  children: [
                    Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: 12,
                              width: double.infinity,
                              color: Colors.grey.shade300),
                          const SizedBox(height: 6),
                          Container(
                              height: 12,
                              width: 200,
                              color: Colors.grey.shade300),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );

  Widget _squareImage(String? src) => SizedBox.square(
        dimension: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: src != null
              ? Image.network(
                  src,
                  fit: BoxFit.cover,
                )
              : const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 40,
                  ),
                ),
        ),
      );

  Widget _attractionTile(Attraction attraction, BuildContext context) =>
      ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          title: TPText(
            attraction.name,
            style: const TPTextStyles(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: TPText(attraction.address),
          leading: _squareImage(attraction.images.firstOrNull?.src),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true, // 可以全屏高度
              isDismissible: true, // 點背景或向下滑都會關閉
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (_) => _buildBottomSheet(attraction),
            );
          });

  Widget _buildBottomSheet(Attraction attraction) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5, // 初始高度
      minChildSize: 0.3, // 最小高度
      maxChildSize: 0.9, // 最大高度
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: TPColors.grayscale300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TPText(
                    attraction.name,
                    style: const TPTextStyles(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TPText(attraction.address),
                const SizedBox(height: 16),
                TPText(
                  attraction.introduction,
                  style: const TPTextStyles(fontSize: 16),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TPButton(
                    text: '前往查看詳情',
                    onPressed: () async {
                      final uri = Uri.parse(attraction.url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
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
  }
}
