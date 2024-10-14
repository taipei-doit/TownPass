import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/gen/fonts.gen.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_line.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text.dart';

class SubscriptionWidget extends StatelessWidget {
  const SubscriptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                const TPText(
                  '訂閱',
                  style: TextStyle(
                    color: TPColors.grayscale800,
                    fontSize: 20,
                    fontFamily: FontFamily.pingFangTC,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Get.toNamed(
                      TPRoute.webView,
                      arguments: 'https://taipei-pass-service.vercel.app/subscription',
                    );
                  },
                  child: Row(
                    children: [
                      Assets.svg.iconSettings.svg(
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(TPColors.grayscale600, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 8),
                      const TPText(
                        '設定',
                        style: TPTextStyles.h3Regular,
                        color: TPColors.grayscale600,
                      ),
                    ],
                  ),
                ),
                const TPLine.vertical(
                  margin: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  color: TPColors.grayscale200,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Get.toNamed(
                      TPRoute.webView,
                      arguments: 'https://taipei-pass-service.vercel.app/subscription/item-list',
                    );
                  },
                  child: Row(
                    children: [
                      const TPText(
                        '更多',
                        style: TPTextStyles.h3Regular,
                        color: TPColors.grayscale600,
                      ),
                      const SizedBox(width: 8),
                      Assets.svg.iconRightArrow.svg(
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(TPColors.grayscale600, BlendMode.srcIn),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          color: TPColors.primary50,
          child: Row(
            children: [
              Assets.svg.illustrationsBookingS.svg(width: 54, height: 46),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TPText(
                    '活動、服務、福利 一鍵讓你知',
                    style: TextStyle(
                      color: TPColors.grayscale800,
                      fontSize: 16,
                      fontFamily: FontFamily.pingFangTC,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        TPRoute.webView,
                        arguments: 'https://taipei-pass-service.vercel.app/subscription',
                      );
                    },
                    child: const TPText(
                      '訂閱設定',
                      style: TextStyle(
                        color: TPColors.primary500,
                        fontSize: 16,
                        fontFamily: FontFamily.pingFangTC,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                        decorationColor: TPColors.primary500,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
