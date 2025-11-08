import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';

class MetroChallengeGameView extends StatelessWidget {
  const MetroChallengeGameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TPColors.white,
      appBar: TPAppBar(
        title: '捷運闖關GO',
        leading: IconButton(
          icon: Assets.svg.iconRemove.svg(),
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: const Center(
        child: TPText(
          '捷運闖關GO遊戲準備中，稍後再來玩！',
          style: TPTextStyles.h3SemiBold,
          color: TPColors.grayscale700,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
