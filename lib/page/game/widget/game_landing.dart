import 'package:flutter/material.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:town_pass/util/tp_text_styles.dart';

class GameLanding extends StatelessWidget {
  const GameLanding({required this.onStart, super.key});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final int currentHour = DateTime.now().hour;
    final String backgroundAssetPath = _backgroundAssetPathForHour(currentHour);
    final Color overlayColor = _overlayColorForHour(currentHour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundAssetPath),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(overlayColor, BlendMode.srcOver),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TPText(
                  'Taipei Guessr',
                  style: TPTextStyles.h1SemiBold,
                  color: TPColors.white,
                ),
                const SizedBox(height: 12),
                const TPText(
                  '在城市的光影中，每一處風景都有它的座標。我們會為您呈上一張臺北的剪影， 請在下方四個選項中，憑著您對這座城市的記憶與直覺， 尋找出「地理位置」上，與它最相近的那一隅風景。點選您心中的答案， 看看您與臺北的連結，有多深刻。',
                  style: TPTextStyles.bodyRegular,
                  color: TPColors.white,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    height: 160,
                    child: Assets.svg.iconMunicipalNavigation.svg(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TPColors.grayscale50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _LandingBullet(
                icon: Icons.lightbulb_outline,
                text: '讀取線索，觀察描述細節',
              ),
              SizedBox(height: 12),
              _LandingBullet(
                icon: Icons.map_outlined,
                text: '從提示區域推敲實際地點',
              ),
              SizedBox(height: 12),
              _LandingBullet(
                icon: Icons.touch_app_outlined,
                text: '選擇答案，立即知道結果',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: TPColors.primary500,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const TPText(
              '開始遊戲',
              style: TPTextStyles.h3SemiBold,
              color: TPColors.white,
            ),
          ),
        ),
      ],
    );
  }

  String _backgroundAssetPathForHour(int hour) {
    if (hour >= 6 && hour < 16) {
      return 'lib/page/game/image/morning.jpg';
    } else if (hour >= 16 && hour < 20) {
      return 'lib/page/game/image/evening.jpg';
    }
    return 'lib/page/game/image/night.jpg';
  }

  Color _overlayColorForHour(int hour) {
    if (hour >= 6 && hour < 16) {
      return Colors.black.withOpacity(0.15);
    } else if (hour >= 16 && hour < 20) {
      return const Color(0xAA111827);
    }
    return const Color(0xCC050914);
  }
}

class _LandingBullet extends StatelessWidget {
  const _LandingBullet({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: TPColors.primary500),
        const SizedBox(width: 12),
        Expanded(
          child: TPText(
            text,
            style: TPTextStyles.bodyRegular,
            color: TPColors.grayscale800,
          ),
        ),
      ],
    );
  }
}
