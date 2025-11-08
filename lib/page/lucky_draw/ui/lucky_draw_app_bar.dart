import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_route.dart';

class LuckyDrawAppBar extends TPAppBar {
  const LuckyDrawAppBar({super.key, String? title});

  final String mainTitle = '城心誠靈';

  @override
  Widget build(BuildContext context) => TPAppBar(
        key: key,
        title: title != null ? '$mainTitle  |  $title' : mainTitle,
        backgroundColor: TPColors.secondary50,
        actions: [
          IconButton(
            onPressed: () {
              // Navigate back to main view and ensure the service tab (index 0) is selected.
              Get.offAllNamed(TPRoute.main, arguments: 0);
            },
            icon: const Icon(
              Icons.close,
              size: 20,
            ),
          )
        ],
      );
}
