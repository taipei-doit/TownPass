import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/gen/fonts.gen.dart';
import 'package:town_pass/page/home/widget/activity_info/activity_banner_widget.dart';
import 'package:town_pass/page/home/widget/activity_info/activity_banner_widget_controller.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

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
              const Text(
                '活動訊息',
                style: TextStyle(
                  color: Color(0xFF30383D),
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
                    const Text(
                      '更多',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Color(0xFF30383D),
                        fontSize: 16,
                        fontFamily: FontFamily.pingFangTC,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Assets.svg.iconRightArrow.svg(width: 24, height: 24),
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
