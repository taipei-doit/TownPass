import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:town_pass/page/account/account_view_controller.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_constant.dart';
import 'package:town_pass/util/tp_line.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountViewFooter extends GetView<AccountViewController> {
  const AccountViewFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TPText(
            '隱私權政策',
            style: TPTextStyles.h3Regular.copyWith(decoration: TextDecoration.underline),
            color: TPColors.grayscale950,
            onTap: () async => await TPRoute.openUri(
              uri: 'https://id.taipei/tpcd/about/policies/privacy',
            ),
          ),
          const SizedBox(width: 24),
          const TPLine.vertical(color: TPColors.grayscale400),
          const SizedBox(width: 24),
          TPText(
            '與我們聯絡',
            style: TPTextStyles.h3Regular.copyWith(decoration: TextDecoration.underline),
            color: TPColors.grayscale950,
            onTap: () async {
              final Uri url = Uri(
                scheme: tpLaunchMailScheme,
                path: tpMailAddress,
                query: controller.mailQuery(),
              );

              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                Fluttertoast.showToast(msg: '無法開啟郵件 App');
              }
            },
          ),
        ],
      ),
    );
  }
}
