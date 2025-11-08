import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
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
      backgroundColor: TPColors.secondary50,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 16,
          children: [
            _button(
              title: '抽籤',
              subtitle: '尋求數位神諭',
              onPressed: () => Get.toNamed('/lucky_draw/drawing'),
            ),
            _button(
              title: '拜拜',
              subtitle: '點亮雲端香火',
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }

  Widget _button({
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) =>
      Row(children: [
        Expanded(
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: TPColors.secondary200,
              foregroundColor: TPColors.secondary800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                spacing: 4,
                children: [
                  Text(title, style: const TextStyle(fontSize: 28)),
                  Text(subtitle, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
      ]);
}
