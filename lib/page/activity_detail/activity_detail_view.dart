import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/bean/activity.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_bottom_sheet.dart';
import 'package:town_pass/util/tp_button.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_duration.dart';
import 'package:town_pass/util/tp_line.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text.dart';

class ActivityDetailView extends StatelessWidget {
  const ActivityDetailView({super.key});

  ActivityItem get activity => Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TPColors.white,
      appBar: const TPAppBar(title: '活動訊息'),
      body: Column(
        children: [
          CachedNetworkImage(imageUrl: activity.imageUrl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TPText(
              activity.title,
              style: TPTextStyles.h3SemiBold,
              color: TPColors.primary500,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    child: _ActivityDurationWidget(
                      startDate: activity.startDateTime,
                      endDate: activity.endDateTime,
                    ),
                  ),
                  const TPLine.horizontal(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TPText(
                        activity.content,
                        style: TPTextStyles.h3Regular,
                        color: TPColors.grayscale800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: switch (activity.webUrl) {
        null => null,
        String() => TPBottomSheet(
            child: Column(
              children: [
                TPButton.primary(
                  text: '網址連結',
                  onPressed: () async => await TPRoute.openUri(
                    uri: activity.webUrl ?? '',
                  ),
                ),
              ],
            ),
          ),
      },
    );
  }
}

class _ActivityDurationWidget extends StatelessWidget {
  const _ActivityDurationWidget({
    required this.startDate,
    this.endDate,
  });

  final DateTime startDate;
  final DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Assets.svg.iconCalender.svg(width: 24, height: 24),
        const SizedBox(width: 16),
        TPText(
          TPDuration.string(start: startDate, end: endDate),
          style: TPTextStyles.h3Regular,
          color: TPColors.grayscale800,
        ),
      ],
    );
  }
}
