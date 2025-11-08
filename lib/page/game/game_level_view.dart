import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';
import 'station_model.dart';


class GameLevelView extends StatelessWidget {
  final Station? station;

  const GameLevelView({super.key, this.station});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TPColors.white,
      appBar: TPAppBar(
        showLogo: true,
        title: station?.name ?? '關卡',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TPText(
              '開始 ${station?.name ?? ''} 闖關',
              style: TPTextStyles.h3SemiBold,
              color: TPColors.grayscale700,
            ),
            const SizedBox(height: 12),
            const TPText(
              '遊戲內容建置中',
              style: TPTextStyles.bodyRegular,
              color: TPColors.grayscale600,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back<void>(),
              style: ElevatedButton.styleFrom(
                backgroundColor: TPColors.primary500,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const TPText(
                '返回',
                style: TPTextStyles.bodySemiBold,
                color: TPColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Station model is defined in station_model.dart
