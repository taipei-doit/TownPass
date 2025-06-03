import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/gen/fonts.gen.dart';
import 'package:town_pass/page/home/widget/activity_info/activity_banner_widget.dart';
import 'package:town_pass/page/home/widget/activity_info/activity_banner_widget_controller.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text.dart';

class ActivityInfoWidget extends StatelessWidget {
  const ActivityInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const TPText(
                '活動訊息',
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
                onTap: () async {
                  final ActivityBannerWidgetController controller = Get.find<ActivityBannerWidgetController>();
                  await Get.toNamed(TPRoute.activityList, arguments: controller.list);
                },
                child: Row(
                  children: [
                    const TPText(
                      '更多',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: TPColors.grayscale800,
                        fontSize: 16,
                        fontFamily: FontFamily.pingFangTC,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Assets.svg.iconArrowRight.svg(width: 24, height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const ActivityBannerWidget(),
      ],
    );
  }
}
