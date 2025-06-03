import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:town_pass/bean/activity.dart';
import 'package:town_pass/page/home/widget/activity_info/activity_banner_widget_controller.dart';
import 'package:town_pass/util/tp_cached_network_image.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text.dart';

class ActivityBannerWidget extends StatelessWidget {
  const ActivityBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: Get.put<ActivityBannerWidgetController>(ActivityBannerWidgetController()),
      builder: (controller) {
        return SizedBox(
          height: 180, //
          child: switch (controller.isLoading) {
            true => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (_, __) => const _Banner(),
                ),
              ),
            false => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: controller.list!.data.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (_, index) => _Banner(activity: controller.list!.data[index]),
              ),
          },
        );
      },
    );
  }
}

class _Banner extends StatelessWidget {
  final ActivityItem? activity;

  const _Banner({this.activity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Get.toNamed(TPRoute.activityDetail, arguments: activity),
      child: SizedBox(
        width: 134,
        child: switch (activity == null) {
          true => _placeHolder(),
          false => Column(
              children: [
                TPCachedNetworkImage(
                  height: 88,
                  width: 132,
                  fit: BoxFit.fitHeight,
                  imageUrl: activity!.imageUrl,
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: TPText(
                    activity!.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
        },
      ),
    );
  }

  Widget _placeHolder() {
    return const Column(
      children: [
        _BannerRectangle(),
        SizedBox(height: 16),
        _BannerTextPlaceHolder(),
      ],
    );
  }
}

class _BannerRectangle extends StatelessWidget {
  final Widget? child;

  const _BannerRectangle({this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      width: 132,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(3)),
        color: TPColors.white,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _BannerTextPlaceHolder extends StatelessWidget {
  const _BannerTextPlaceHolder();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _textRow(width: 134),
        const SizedBox(height: 8),
        _textRow(width: 83),
      ],
    );
  }

  Widget _textRow({required double width}) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        color: TPColors.white,
      ),
      height: 16,
      width: width,
    );
  }
}
