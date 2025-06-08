import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/suspend_account/suspend_account_controller.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_button.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_constant.dart';
import 'package:town_pass/util/tp_setting_list.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:url_launcher/url_launcher.dart';

class SuspendAccountView extends GetView<SuspendAccountController> {
  const SuspendAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TPAppBar(
        title: '停用帳號',
      ),
      body: TPSettingList(
        children: [
          TPSettingListTile.header(title: '目前登入帳號'),
          TPSettingListTile.listTile(
            leading: Assets.svg.iconPerson.svg(),
            title: TPText(
              controller.name,
              style: TPTextStyles.h2Regular,
              color: TPColors.grayscale800,
            ),
          ),
          TPSettingListTile.line(),
          TPSettingListTile.listTile(
            leading: Assets.svg.iconIdCard.svg(),
            title: TPText(
              controller.idNumber,
              style: TPTextStyles.h2Regular,
              color: TPColors.grayscale800,
            ),
          ),
          TPSettingListTile.line(),
          TPSettingListTile(
            backgroundColor: TPColors.white,
            child: Column(
              children: [
                const TPText(
                  '提用帳號即無法再登入城市通，並無法再以城市通帳號登入其他系統。相關的資料仍會保存於對應雲端平台。',
                  style: TPTextStyles.bodyRegular,
                  color: TPColors.black,
                ),
                const SizedBox(height: 16),
                TPButton.primary(
                  text: '停用帳號',
                  onPressed: () {},
                ),
              ],
            ),
          ),
          TPSettingListTile.header(title: '帳號復用方式'),
          TPSettingListTile.listTile(
            backgroundColor: TPColors.transparent,
            leading: Assets.svg.iconLogout.svg(),
            title: const TPText(
              '登入台北通，需重新驗證您的手機或Email資料來復用帳號',
              style: TPTextStyles.bodyRegular,
              color: TPColors.grayscale800,
            ),
          ),
          TPSettingListTile.listTile(
            backgroundColor: TPColors.transparent,
            leading: Assets.svg.iconMail.svg(),
            title: const TPText(
              '客服信箱',
              style: TPTextStyles.bodyRegular,
              color: TPColors.grayscale800,
            ),
            subtitle: TPText(
              tpMailAddress,
              style: TPTextStyles.bodyRegular.copyWith(
                color: TPColors.primary500,
                decoration: TextDecoration.underline,
                decorationColor: TPColors.primary500,
              ),
              onTap: () async {
                final Uri uri = Uri(
                  scheme: tpLaunchMailScheme,
                  path: tpMailAddress,
                );

                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  Fluttertoast.showToast(msg: '無法開啟郵件 App');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
