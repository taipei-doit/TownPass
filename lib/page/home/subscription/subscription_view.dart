import 'package:town_pass/bean/subscription.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SubscriptionView extends StatelessWidget {
  SubscriptionItem get subscription => Get.arguments;

  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TPAppBar(title: '訂閱'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(subscription.title),
                const Spacer(),
                Text(DateFormat('yyyy/MM/dd').format(subscription.datetime)),
              ],
            ),
            const SizedBox(height: 8),
            Text(subscription.content),
          ],
        ),
      ),
    );
  }
}
