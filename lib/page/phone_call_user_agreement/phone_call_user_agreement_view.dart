import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/phone_call_user_agreement/phone_call_user_agreement_view_controller.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_bottom_sheet.dart';
import 'package:town_pass/util/tp_button.dart';
import 'package:town_pass/util/tp_card.dart';
import 'package:town_pass/util/tp_checkbox_list_tile.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';

class PhoneCallUserAgreementView
    extends GetView<PhoneCallUserAgreementViewController> {
  const PhoneCallUserAgreementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TPAppBar(title: '1999電話'),
      bottomSheet: Obx(
        () => TPBottomSheet(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TPCheckboxListTile(
                value: controller.checkboxValue.value,
                onChanged: (value) => controller.checkboxValue.value = value!,
                content: '本人已詳閱並同意以上條款個資使用聲明',
              ),
              const SizedBox(height: 10),
              TPButton.primary(
                text: '同意',
                enable: controller.checkboxValue.value,
                onPressed: () async => await controller.agree(),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(_CardContent._kOuterPadding),
            child: TPCard(
              child: _CardContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  // 卡片內部視覺元素的定位與尺寸常數。
  static const double _kOuterPadding = 24.0;
  static const double _kCircleAvatarRadius = 50.0;
  static const double _kCircleAvatarTopOffset = -20.0;
  static const double _kCircleAvatarLeftOffset = -20.0;
  static const double _kIconTopOffset = 18.0;
  static const double _kIconLeftOffset = 22.0;
  static const double _kTextSpacingS = 4.0;
  static const double _kTextSpacingL = 32.0;

  // 提取出的個資使用聲明長文字內容，提升可讀性。
  static const String _kAgreementContent =
      '依據個人資料保護法等相關規定,臺北市政府有義務告知以下事項:'
      '為提供更快速、便利之服務,利用台北通撥打網路電話，'
      '若須轉接至1999市民熱線專人服務時，'
      '系統自動提供您台北通會員的「姓名及手機號碼」等個人資料至'
      '「1999話務系統」、「臺北市陳情系統」 或「1999派工系統」，'
      '其個人資料的利用之期間、 對象、地區及方式，'
      '皆以該系統或該單位的「隱私 權公告」為主。\n'
      '若您使用1999網路電話聯絡我們，為維護雙方權益及提升服務效率，'
      '服務過程將錄音並轉換為文字，以利我們能更快速地登錄及處理您的意見。'
      '本次蒐集之個人資訊，僅限於撥打網路電話轉接至1999市民熱線專人服務時使用，'
      '並遵守個人資料 保護法相關規定,保障使用者的個資。\n'
      '如有使用問題,請撥打1999市民熱線。';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned( // 此處可加 const，因為其屬性皆為常數。
          top: _kCircleAvatarTopOffset,
          left: _kCircleAvatarLeftOffset,
          child: CircleAvatar( // 此處可加 const，因為其屬性皆為常數。
            radius: _kCircleAvatarRadius,
            backgroundColor: TPColors.primary100,
          ),
        ),
        Positioned( // Assets.svg.icon1999phone.svg() 非 const，故此處不可加 const。
          top: _kIconTopOffset,
          left: _kIconLeftOffset,
          child: Assets.svg.icon1999phone.svg(),
        ),
        const Padding( // 此處可加 const，因為其屬性皆為常數，且子 Widget 也皆為常數。
          padding: EdgeInsets.all(_kOuterPadding),
          child: Column(
            children: [
              TPText(
                '1999電話',
                style: TPTextStyles.h2SemiBold,
                color: TPColors.primary500,
              ),
              SizedBox(height: _kTextSpacingS),
              TPText(
                '個資使用聲明',
                style: TPTextStyles.h3Regular,
                color: TPColors.grayscale700,
              ),
              SizedBox(height: _kTextSpacingL),
              TPText(
                _kAgreementContent,
                style: TPTextStyles.h3Regular,
                color: TPColors.grayscale700,
              ),
            ],
          ),
        ),
      ],
    );
  }
}