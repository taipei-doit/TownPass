import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TPColors.white,
      appBar: TPAppBar(
        showLogo: true,
        title: '遊戲',
        leading: IconButton(
          icon: Semantics(
            label: '返回上一頁',
            child: Assets.svg.iconRemove.svg(),
          ),
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TPText(
              '遊戲內容建置中',
              style: TPTextStyles.h3SemiBold,
              color: TPColors.grayscale700,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Assets.svg.iconRemove.svg(width: 20, height: 20),
              label: const TPText(
                '返回上一頁',
                style: TPTextStyles.bodySemiBold,
                color: TPColors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: TPColors.primary500,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Get.back<void>(),
            ),
          ],
        ),
      ),
    );
  }
}
