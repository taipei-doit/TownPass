import 'dart:math';
import 'package:flutter/material.dart';
import 'package:town_pass/models/attraction.dart';
import 'package:town_pass/page/lucky_draw/data/temple.dart';
import 'package:town_pass/page/lucky_draw/ui/lucky_draw_app_bar.dart';
import 'package:town_pass/service/attraction_service.dart';
import 'package:town_pass/util/tp_button.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

class RandomTemplePage extends StatefulWidget {
  const RandomTemplePage({super.key});

  @override
  State<RandomTemplePage> createState() => _RandomTemplePageState();
}

class _RandomTemplePageState extends State<RandomTemplePage> {
  late Future<List<Temple>> _templesFuture;
  Temple? _selectedTemple;
  Future<ApiResponse>? _attractionsFuture;

  @override
  void initState() {
    super.initState();

    _templesFuture = TempleDataService.instance.temples;

    // 選寺邏輯改成在 Future 完成後再 setState
    _templesFuture.then((temples) {
      final randomTemple = temples[Random().nextInt(temples.length)];
      setState(() {
        _selectedTemple = randomTemple;
        _attractionsFuture = _loadAttractions(randomTemple);
      });
    });
  }

  Future<ApiResponse> _loadAttractions(Temple temple) async {
    final service = AttractionService();
    return await service.fetchAttractions(
      nlat: temple.latitude,
      elong: temple.longitude,
      page: 1,
    );
  }
  Future<void> _openMap(double lat, double lng) async {
    final Uri googleMapSchemeUrl = Uri.parse('comgooglemaps://?q=$lat,$lng');
    final Uri geoUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng'); // Android fallback
    final Uri webUrl = Uri.parse('https://www.google.com/maps?q=$lat,$lng'); // Web fallback

    // Try Google Maps app (iOS)
    if (await canLaunchUrl(googleMapSchemeUrl)) {
      await launchUrl(googleMapSchemeUrl);
    } 
    // Try geo: (Android)
    else if (await canLaunchUrl(geoUrl)) {
      await launchUrl(geoUrl);
    } 
    // Fallback to web
    else {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LuckyDrawAppBar(subtitle: '推薦宮廟'),
      backgroundColor: TPColors.secondary50,
      body: FutureBuilder<List<Temple>>(
        future: _templesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _loadingPlaceholder;
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No temples found.'));
          }

          return FutureBuilder<ApiResponse>(
            future: _attractionsFuture,
            builder: (context, attractionSnap) {
              if (attractionSnap.connectionState == ConnectionState.waiting) {
                return _loadingPlaceholder;
              } else if (attractionSnap.hasError) {
                return Center(child: Text('Error: ${attractionSnap.error}'));
              } else if (!attractionSnap.hasData ||
                  attractionSnap.data!.data.isEmpty) {
                return const Center(child: Text('No attractions found.'));
              }

              final attractions = attractionSnap.data!.data;
              final temple = _selectedTemple!;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TPText(
                    temple.name,
                    style: const TPTextStyles(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      temple.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                      errorBuilder: (_, __, ___) =>
                          Image.asset('assets/image/temple.jpeg'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (temple.introduction.isNotEmpty
                            ? temple.introduction.split('\n')
                            : ['暫無介紹內容。'])
                        .map((paragraph) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 16), // 每段間距
                              child: TPText(
                                paragraph,
                                style: const TPTextStyles(
                                    fontSize: 14, height: 1.5),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  const TPText(
                    '附近景點',
                    style: TPTextStyles(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var attraction in attractions)
                    _attractionTile(attraction, context),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// shimmer loading skeleton
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
              ? Image.network(src, fit: BoxFit.cover)
              : const Center(
                  child: Icon(Icons.image_not_supported, size: 40),
                ),
        ),
      );

  Widget _attractionTile(Attraction attraction, BuildContext context) =>
      ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
            isScrollControlled: true,
            isDismissible: true,
            backgroundColor: TPColors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            builder: (_) => _bottomSheet(attraction),
          );
        },
      );

  Widget _bottomSheet(Attraction attraction) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
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
                  Center(child: 
                    TPButton(
                      text: '在地圖中查看位置',
                      onPressed: () async  {
                        await _openMap(attraction.nlat, attraction.elong);
                      },
                    )
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      );
}
