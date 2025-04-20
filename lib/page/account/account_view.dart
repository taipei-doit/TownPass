import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/account/account_view_controller.dart';
import 'package:town_pass/page/account/widget/account_app_bar.dart';
import 'package:town_pass/page/account/widget/account_view_footer.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_setting_list.dart';
import 'package:town_pass/util/tp_text.dart';

class AccountView extends GetView<AccountViewController> {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AccountAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => TPSettingList(
                  children: [
                    TPSettingListTile.space(
                      backgroundColor: TPColors.white,
                      height: 19,
                    ),
                    TPSettingListTile.listTile(
                      excludeFromSemantics: true,
                      leading: Assets.svg.iconPerson.svg(),
                      title: TPText(
                        controller.name.value,
                        style: TPTextStyles.h2Regular,
                        color: TPColors.grayscale800,
                      ),
                      trailing: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async => await Get.toNamed(TPRoute.setting)?.then((value) => controller.syncAccount()),
                        child: Semantics(
                          label: '設定',
                          child: Assets.svg.iconSettings.svg(),
                        ),
                      ),
                    ),
                    TPSettingListTile.line(),
                    TPSettingListTile.listTile(
                      excludeFromSemantics: true,
                      leading: Assets.svg.iconPhone.svg(),
                      title: TPText(
                        controller.phoneNumber.value,
                        style: TPTextStyles.h2Regular,
                        color: TPColors.grayscale800,
                      ),
                      trailing: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async => await Get.toNamed(TPRoute.setting)?.then((value) => controller.syncAccount()),
                        child: Semantics(
                          label: '設定',
                          child: Assets.svg.iconSettings.svg(),
                        ),
                      ),
                    ),
                    TPSettingListTile.space(),
                    TPSettingListTile.navigate(
                      title: '訊息',
                      onTap: () => Get.toNamed(TPRoute.message),
                    ),
                    TPSettingListTile.line(),
                    TPSettingListTile.navigate(
                      title: '歷程與授權管理',
                      onTap: () {},
                    ),
                    TPSettingListTile.line(),
                    TPSettingListTile.navigate(
                      title: '訂閱',
                      content: '首頁>訂閱',
                      onTap: () {},
                    ),
                    TPSettingListTile.space(),
                    TPSettingListTile.navigate(
                      title: '功能教學',
                      onTap: () async => await TPRoute.openUri(
                        uri: 'https://id.taipei/tpcd/about/faq',
                      ),
                    ),
                    TPSettingListTile.line(),
                    TPSettingListTile.navigate(
                      title: '意見回饋',
                      onTap: () => Get.toNamed(TPRoute.feedback),
                    ),
                    TPSettingListTile.line(),
                    TPSettingListTile.display(
                      title: '版本',
                      content: controller.appVersion,
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: AccountViewFooter(),
            ),
          ],
        ),
      ),
    );
  }
}
