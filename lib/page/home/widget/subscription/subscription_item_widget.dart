import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:town_pass/bean/subscription.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text.dart';

class SubscriptionItemWidget extends StatelessWidget {
  final SubscriptionItem item;

  const SubscriptionItemWidget({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Get.toNamed(
        TPRoute.subscription,
        arguments: item,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: SubscriptionItemWidget._dotPadding),
                child: CircleAvatar(
                  radius: SubscriptionItemWidget._dotRadius,
                  backgroundColor: TPColors.primary500,
                ),
              ),
              Expanded(
                  child: TPText(
                item.title,
                style: TPTextStyles.h3SemiBold,
              )),
              TPText(
                DateFormat('yyyy/MM/dd').format(item.datetime),
                style: TPTextStyles.bodyRegular,
                color: TPColors.grayscale500,
              ),
              const SizedBox(width: _dotPadding),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const SizedBox(
                width: SubscriptionItemWidget._dotPadding * 2 + SubscriptionItemWidget._dotRadius * 2,
              ),
              Flexible(
                child: TPText(
                  item.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: _dotPadding),
            ],
          ),
        ],
      ),
    );
  }

  static const double _dotPadding = 12.0;
  static const double _dotRadius = 4.0;
}
