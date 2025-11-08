import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:town_pass/page/lucky_draw/ui/animated_light_flow_background.dart';
import 'package:town_pass/util/tp_app_bar.dart';
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
      appBar: const TPAppBar(
        title: '城心誠靈',
        backgroundColor: TPColors.secondary50,
      ),
      body: AnimatedLightFlowBackground(
        backgroundColor: TPColors.secondary50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 36,
            children: [
              _button(
                title: '抽籤',
                subtitle: '尋求數位神諭',
                imagePath: 'assets/image/jiaobei.png',
                onPressed: () => Get.toNamed('/lucky_draw/drawing'),
              ),
              _button(
                title: '拜拜',
                subtitle: '點亮雲端香火',
                imagePath: 'assets/image/incense_burner.png',
                onPressed: () {},
              )
            ],
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
                padding: const EdgeInsets.symmetric(vertical: 36),
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
