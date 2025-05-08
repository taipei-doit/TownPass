import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/feedback/feedback_view_controller.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_bottom_sheet.dart';
import 'package:town_pass/util/tp_button.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_line.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FeedbackView extends GetView<FeedbackViewController> {
  const FeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TPAppBar(title: '意見回饋'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CompositedTransformTarget(
              link: controller.dropdownMenuLayerLink,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: controller.toggleDropdownMenu,
                child: OverlayPortal(
                  controller: controller.overlayPortalController,
                  overlayChildBuilder: (context) {
                    return CompositedTransformFollower(
                      link: controller.dropdownMenuLayerLink,
                      targetAnchor: Alignment.bottomLeft,
                      followerAnchor: Alignment.topLeft,
                      child: Stack(
                        children: [
                          ModalBarrier(onDismiss: controller.toggleDropdownMenu),
                          Align(
                            alignment: Alignment.topCenter,
                            child: ColoredBox(
                              color: TPColors.grayscale50,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                shrinkWrap: true,
                                itemCount: FeedbackType.values.length,
                                separatorBuilder: (_, __) => const TPLine.horizontal(color: TPColors.grayscale200),
                                itemBuilder: (context, index) {
                                  final FeedbackType feedbackType = FeedbackType.values[index];
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      controller.feedbackType.value = feedbackType;
                                      controller.toggleDropdownMenu();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: TPText(
                                        feedbackType.string,
                                        style: TPTextStyles.h3Regular,
                                        color: TPColors.grayscale700,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => TPText(
                              switch (controller.feedbackType.value) {
                                null => '請選擇建議類型',
                                FeedbackType feedback => feedback.string,
                              },
                              style: TPTextStyles.h3SemiBold,
                              color: TPColors.grayscale700,
                            ),
                          ),
                        ),
                        Obx(
                          () => switch (controller.isDropdownOpened.value) {
                            true => Assets.svg.iconArrowUp.svg(),
                            false => Assets.svg.iconArrowDown.svg(),
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: TPColors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 23),
                    const TPText(
                      '意見內容',
                      style: TPTextStyles.bodySemiBold,
                    ),
                    const SizedBox(height: 13),
                    SizedBox(
                      height: 223,
                      child: TextField(
                        controller: controller.controller,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: TPColors.grayscale500)),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: TPColors.grayscale500)),
                          hintStyle: TPTextStyles.bodyRegular.copyWith(color: TPColors.grayscale400),
                          hintText: '請描述建議與問題',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                        textAlignVertical: TextAlignVertical.top,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Assets.svg.iconInfo.svg(height: 24, width: 24),
                        const SizedBox(width: 8),
                        Flexible(
                          child: RichText(
                            text: TextSpan(
                              text: '若您對市政府有任何建議或問題請至',
                              style: const TextStyle(color: TPColors.grayscale700),
                              children: [
                                TextSpan(
                                  text: '有話要說',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: TPColors.primary500,
                                  ),
                                  recognizer: TapGestureRecognizer()..onTap = () {},
                                ),
                                const TextSpan(text: '，若系統操作上有任何問題請'),
                                TextSpan(
                                  text: '打客服電話 ${controller.contactPhoneNumber}',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: TPColors.primary500,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrlString('tel://${controller.contactPhoneNumber}');
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: TPBottomSheet(
        child: TPButton.primary(
          text: '送出',
          onPressed: controller.sendFeedback,
        ),
      ),
    );
  }
}

extension on FeedbackType {
  String get string {
    return switch (this) {
      FeedbackType.register => '註冊',
      FeedbackType.login => '登入',
      FeedbackType.cardUsage => '卡證使用',
      FeedbackType.perk => '優惠兌換',
      FeedbackType.other => '其他問題',
    };
  }
}
