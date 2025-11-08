import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';

class SnakeGameView extends StatelessWidget {
  const SnakeGameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TPColors.white,
      appBar: TPAppBar(
        title: '貪食蛇',
        leading: IconButton(
          icon: Assets.svg.iconRemove.svg(),
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: const Center(
        child: TPText(
          '貪食蛇遊戲即將推出，敬請期待！',
          style: TPTextStyles.h3SemiBold,
          color: TPColors.grayscale700,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
