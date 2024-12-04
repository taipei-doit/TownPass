import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_setting_list.dart';
import 'package:town_pass/page/app_home_page/app_home_page_controller.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppHomePageView extends GetView<AppHomePageController> {
  const AppHomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TPColors.white,
      appBar: const TPAppBar(
        title: '偏好設定',
      ),
      body: Obx(
        () => TPSettingList(
          children: [
            TPSettingListTile.listTile(
              title: const TPText(
                '首頁偏好設定',
                style: TPTextStyles.h3SemiBold,
                color: TPColors.grayscale700,
              ),
              subtitle: const TPText(
                '開啟APP的起始首頁',
                style: TPTextStyles.bodyRegular,
                color: TPColors.grayscale700,
              ),
              backgroundColor: TPColors.grayscale50,
            ),
            TPSettingListTile.selectionList(
              onIndexChange: (index) => controller.onIndexChange(index),
              initialIndex: controller.currentIndex.value,
              selections: [
                SettingSelectionListItem(
                  selectedLeading: Assets.svg.iconTabbarServiceSelect.svg(),
                  unselectedLeading: Assets.svg.iconTabbarServiceDefault.svg(),
                  title: '服務',
                ),
                SettingSelectionListItem(
                  selectedLeading: Assets.svg.iconTabbarHomeSelect.svg(),
                  unselectedLeading: Assets.svg.iconTabbarHomeDefault.svg(),
                  title: '首頁',
                ),
                SettingSelectionListItem(
                  selectedLeading: Assets.svg.iconTabbarCouponSelect.svg(),
                  unselectedLeading: Assets.svg.iconTabbarCouponDefault.svg(),
                  title: '優惠',
                ),
                SettingSelectionListItem(
                  selectedLeading: Assets.svg.iconTabbarAccountSelect.svg(),
                  unselectedLeading: Assets.svg.iconTabbarAccountDefault.svg(),
                  title: '帳務',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
