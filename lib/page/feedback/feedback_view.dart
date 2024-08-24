import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/feedback/feedback_view_controller.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_bottom_sheet.dart';
import 'package:town_pass/util/tp_button.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FeedbackView extends GetView<FeedbackViewController> {
  const FeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    DropdownMenu(
      dropdownMenuEntries: [],
    );
    return Scaffold(
      appBar: const TPAppBar(title: '意見回饋'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: DropdownMenu(
              expandedInsets: const EdgeInsets.symmetric(horizontal: 16),
              trailingIcon: Assets.svg.iconArrowDown.svg(),
              selectedTrailingIcon: Assets.svg.iconArrowUp.svg(),
              dropdownMenuEntries: controller.feedbackTypeList
                  .map<DropdownMenuEntry<FeedbackType?>>(
                    (type) => DropdownMenuEntry<FeedbackType?>(
                      value: type,
                      label: type.string,
                      labelWidget: TPText(
                        type.string,
                        style: TPTextStyles.h3Regular,
                        color: TPColors.grayscale700,
                      ),
                      // style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 16))),
                    ),
                  )
                  .toList(),
              hintText: '請選擇建議類型',
              textStyle: TPTextStyles.h3SemiBold,
              inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
              menuStyle: MenuStyle(
                backgroundColor: WidgetStateProperty.all(TPColors.grayscale50),
              ),
              onSelected: (type) {
                controller.selectType = type;
              },
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
