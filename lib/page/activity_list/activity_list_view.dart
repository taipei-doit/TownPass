import 'package:town_pass/bean/activity.dart';
import 'package:town_pass/gen/fonts.gen.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_cached_network_image.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_duration.dart';
import 'package:town_pass/util/tp_line.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivityListView extends StatelessWidget {
  const ActivityListView({super.key});

  ActivityList get list => Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TPColors.white,
      appBar: const TPAppBar(title: '活動訊息'),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: list.data.length,
        separatorBuilder: (_, __) => const TPLine.horizontal(),
        itemBuilder: (_, index) => _ActivityItemWidget(item: list.data[index]),
      ),
    );
  }
}

class _ActivityItemWidget extends StatelessWidget {
  final ActivityItem item;

  const _ActivityItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await Get.toNamed(
          TPRoute.activityDetail,
          arguments: item,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            TPCachedNetworkImage(
              imageUrl: item.imageUrl,
              width: 114,
              height: 76,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TPText(
                    item.title,
                    style: TPTextStyles.h3SemiBold,
                    color: TPColors.grayscale800,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  TPText(
                    item.duration.format(),
                    style: TPTextStyles.bodySemiBold,
                    color: TPColors.grayscale400,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
