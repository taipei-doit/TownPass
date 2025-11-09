import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:town_pass/page/lucky_draw/data/temple.dart';
import 'package:town_pass/page/lucky_draw/ui/lucky_draw_app_bar.dart';
import 'package:town_pass/util/tp_button.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:url_launcher/url_launcher.dart';

class TemplePage extends StatefulWidget {
  const TemplePage({super.key});

  @override
  State<TemplePage> createState() => _TemplePageState();
}

class _TemplePageState extends State<TemplePage> {
  late Future<List<Temple>> templesFuture;

  @override
  void initState() {
    super.initState();
    templesFuture = TempleDataService.instance.temples;
  }

  Future<void> _openMap(double lat, double lng) async {
    final Uri googleMapSchemeUrl = Uri.parse('comgooglemaps://?q=$lat,$lng');
    final Uri geoUrl =
        Uri.parse('geo:$lat,$lng?q=$lat,$lng'); // Android fallback
    final Uri webUrl =
        Uri.parse('https://www.google.com/maps?q=$lat,$lng'); // Web fallback

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
      appBar: const LuckyDrawAppBar(subtitle: '選擇參拜宮廟'),
      backgroundColor: TPColors.secondary50,
      body: FutureBuilder<List<Temple>>(
        future: templesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found.'));
          }

          final temples = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: temples.length,
            itemBuilder: (context, index) {
              final temple = temples[index];
              return _templeTile(temple);
            },
            separatorBuilder: (_, __) => const SizedBox(height: 16),
          );
        },
      ),
    );
  }

  Widget _templeTile(Temple temple) {
    return Material(
      color: TPColors.secondary100,
      borderRadius: BorderRadius.circular(12),
      child: Theme(
        data: ThemeData(
          splashColor: TPColors.secondary200.withAlpha(128),
          highlightColor: TPColors.secondary200.withAlpha(128),
        ),
        child: InkWell(
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
              builder: (_) => _bottomSheet(temple),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: temple.imageUrl.isNotEmpty
                    ? Image.network(
                        temple.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 200,
                        color: TPColors.grayscale300,
                        child: const Center(
                          child: Text('No Image'),
                        ),
                      ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      temple.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${temple.city} ${temple.district}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomSheet(Temple temple) => DraggableScrollableSheet(
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
                      temple.name,
                      style: const TPTextStyles(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TPText(
                    '${temple.city} ${temple.district}',
                    style: const TPTextStyles(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TPText(
                    temple.introduction,
                    style: const TPTextStyles(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TPButton(
                      text: '線上參拜',
                      onPressed: () =>
                          Get.toNamed('/lucky_draw/incense_burning'),
                    ),
                  ),
                  Center(
                    child: TPButton(
                      text: '在地圖中查看位置',
                      onPressed: () async  {
                        await _openMap(temple.latitude, temple.longitude);
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
