import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:town_pass/page/lucky_draw/ui/animated_light_flow_background.dart';
import 'package:town_pass/page/lucky_draw/ui/lucky_draw_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _streamSubscription = <StreamSubscription<dynamic>>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (final subscription in _streamSubscription) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LuckyDrawAppBar(),
      body: AnimatedLightFlowBackground(
        backgroundColor: TPColors.secondary50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 36,
              children: [
                const Text(
                  '在臺北的快節奏生活中\n為您找到一處安定內心的空間',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: TPColors.secondary800,
                  ),
                ),
                _button(
                  title: '抽籤',
                  subtitle: '尋求數位神諭',
                  imagePath: 'assets/image/kau_chim.png',
                  onPressed: () => Get.toNamed('/lucky_draw/drawing'),
                ),
                _button(
                  title: '拜拜',
                  subtitle: '點亮雲端香火',
                  imagePath: 'assets/image/incense_burner.png',
                  onPressed: () => Get.toNamed('/lucky_draw/temple'),
                ),
                const Padding(
                  // 在底部文字左右加上間距，讓內容不貼邊
                  padding: EdgeInsets.only(left: 12, right: 12),
                  child: Align(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 內文使用左右邊距後，保持左對齊以利閱讀
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: '我們服務結合兩大應用：\n\n1.  '),
                              TextSpan(
                                text: '數位神諭',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    '：結合城市數據與千年籤詩智慧，一鍵擲筊求籤，立即獲得最貼近您職涯、愛情、生活的指引。\n\n2. ',
                              ),
                              TextSpan(
                                text: '雲端香火',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: '：壓力山大、時間寶貴時，您可線上選擇廟宇進行拜拜，是舒緩生活壓力的最佳選擇。',
                              ),
                            ],
                          ),
                          textAlign: TextAlign.left,
                          style: TextStyle(color: TPColors.secondary800),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _button({
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onPressed,
  }) =>
      Row(
        children: [
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: TPColors.secondary200,
                foregroundColor: TPColors.secondary800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: TPColors.secondary100.withAlpha(180),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: TPColors.secondary800,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 60),
                    Column(
                      spacing: 4,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 36)),
                        Text(subtitle, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
}
