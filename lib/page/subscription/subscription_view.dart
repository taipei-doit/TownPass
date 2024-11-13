import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:town_pass/bean/subscription.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';

class SubscriptionView extends StatelessWidget {
  SubscriptionItem get subscription => Get.arguments;

  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TPAppBar(title: '訂閱'),
      backgroundColor: TPColors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TPText(
                subscription.title,
                style: TPTextStyles.titleSemiBold,
              ),
              const SizedBox(height: 12.0),
              TPText(
                subscription.content,
                style: TPTextStyles.bodyRegular,
              ),
              const SizedBox(height: 16.0),
              TPText(
                DateFormat('yyyy/MM/dd').format(subscription.datetime),
                style: TPTextStyles.bodyRegular,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
