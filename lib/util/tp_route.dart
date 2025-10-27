import 'package:get/get.dart';
import 'package:town_pass/page/account/account_view.dart';
import 'package:town_pass/page/account/account_view_controller.dart';
import 'package:town_pass/page/activity_detail/activity_detail_view.dart';
import 'package:town_pass/page/activity_list/activity_list_view.dart';
import 'package:town_pass/page/app_home_page/app_home_page_controller.dart';
import 'package:town_pass/page/app_home_page/app_home_page_view.dart';
import 'package:town_pass/page/basic_info/basic_info_view.dart';
import 'package:town_pass/page/basic_info/basic_info_view_controller.dart';
import 'package:town_pass/page/basic_info_edit/basic_info_edit_view.dart';
import 'package:town_pass/page/basic_info_edit/basic_info_edit_view_controller.dart';
import 'package:town_pass/page/city_service/widget/pinned_service_widget_controller.dart';
import 'package:town_pass/page/city_service_edit/city_service_edit_view.dart';
import 'package:town_pass/page/city_service_edit/city_service_edit_view_controller.dart';
import 'package:town_pass/page/feedback/feedback_view.dart';
import 'package:town_pass/page/feedback/feedback_view_controller.dart';
import 'package:town_pass/page/invoice_receipt/invoice_receipt_view.dart';
import 'package:town_pass/page/language/language_view.dart';
import 'package:town_pass/page/language/language_view_controller.dart';
import 'package:town_pass/page/main/main_view.dart';
import 'package:town_pass/page/main/main_view_controller.dart';
import 'package:town_pass/page/message/message_view.dart';
import 'package:town_pass/page/message/message_view_controller.dart';
import 'package:town_pass/page/message_detail/message_detail_view.dart';
import 'package:town_pass/page/online_police/online_police_view.dart';
import 'package:town_pass/page/phone_call_user_agreement/phone_call_user_agreement_view.dart';
import 'package:town_pass/page/phone_call_user_agreement/phone_call_user_agreement_view_controller.dart';
import 'package:town_pass/page/portfolioAndAuth/portfolio_auth_view.dart';
import 'package:town_pass/page/qr_code_scan/qr_code_scan_controller.dart';
import 'package:town_pass/page/qr_code_scan/qr_code_scan_view.dart';
import 'package:town_pass/page/setting/setting_view.dart';
import 'package:town_pass/page/setting/setting_view_controller.dart';
import 'package:town_pass/page/subscription/subscription_view.dart';
import 'package:town_pass/page/suspend_account/suspend_account_controller.dart';
import 'package:town_pass/page/suspend_account/suspend_account_view.dart';
import 'package:town_pass/util/tp_web_view.dart';
import 'package:flutter/material.dart'; // 導入 flutter/material.dart 以使用 Widget 類型

abstract class TPRoute {
  static const String main = '/';
  static const String account = '/account';
  static const String activityList = '/activity_list';
  static const String activityDetail = '/activity_detail';
  static const String basicInfo = '/basic_info';
  static const String basicInfoEdit = '/basic_info_edit';
  static const String feedback = '/feedback';
  static const String invoiceReceipt = '/invoice_receipt';
  static const String home = '/home';
  static const String language = '/language';
  static const String message = '/message';
  static const String messageDetail = '/message_detail';
  static const String onlinePolice = '/online_police';
  static const String phoneCallUserAgreement = '/phone_call_user_agreement';
  static const String portfolioAndAuth = '/portfolio_and_auth';
  static const String qrCodeScan = '/qr_code_scan';
  static const String service = '/service';
  static const String serviceEdit = '/service_edit';
  static const String setting = '/setting';
  static const String settingStartPage = '/setting_start_page';
  static const String subscription = '/subscription';
  static const String suspendAccount = '/suspend_account';
  static const String webView = '/web_view';

  /// Helper method to create a GetPage with a single GetxController binding.
  /// This reduces boilerplate for common GetPage definitions.
  static GetPage _buildGetPageWithController<T extends GetxController>(
    String name,
    Widget Function() pageBuilder,
    T Function() controllerBuilder,
  ) {
    return GetPage(
      name: name,
      page: pageBuilder,
      binding: BindingsBuilder(() {
        Get.put<T>(controllerBuilder());
      }),
    );
  }

  static final List<GetPage> page = [
    // Main route has multiple controllers, so keep the original verbose binding.
    GetPage(
      name: main,
      page: () => const MainView(),
      binding: BindingsBuilder(() {
        Get
          ..put<MainViewController>(MainViewController())
          ..put<PinnedServiceWidgetController>(PinnedServiceWidgetController());
      }),
    ),
    _buildGetPageWithController(
      account,
      () => const AccountView(),
      () => AccountViewController(),
    ),
    _buildGetPageWithController(
      basicInfo,
      () => const BasicInfoView(),
      () => BasicInfoViewController(),
    ),
    _buildGetPageWithController(
      basicInfoEdit,
      () => const BasicInfoEditView(),
      () => BasicInfoEditViewController(),
    ),
    _buildGetPageWithController(
      feedback,
      () => const FeedbackView(),
      () => FeedbackViewController(),
    ),
    // Pages without controllers remain in their original GetPage format.
    GetPage(
      name: invoiceReceipt,
      page: () => const InvoiceReceiptView(),
    ),
    _buildGetPageWithController(
      language,
      () => const LanguageView(),
      () => LanguageViewController(),
    ),
    _buildGetPageWithController(
      message,
      () => const MessageView(),
      () => MessageViewController(),
    ),
    // Pages without controllers remain in their original GetPage format.
    GetPage(
      name: messageDetail,
      page: () => const MessageDetailView(),
    ),
    // Pages without controllers remain in their original GetPage format.
    GetPage(
      name: onlinePolice,
      page: () => const OnlinePoliceView(),
    ),
    _buildGetPageWithController(
      phoneCallUserAgreement,
      () => const PhoneCallUserAgreementView(),
      () => PhoneCallUserAgreementViewController(),
    ),
    // Pages without controllers remain in their original GetPage format.
    GetPage(
      name: portfolioAndAuth,
      page: () => const PortfolioAndAuthView(),
    ),
    _buildGetPageWithController(
      qrCodeScan,
      () => const QRCodeScanView(),
      () => QRCodeScanController(),
    ),
    _buildGetPageWithController(
      serviceEdit,
      () => const CityServiceEditView(),
      () => CityServiceEditViewController(),
    ),
    _buildGetPageWithController(
      setting,
      () => const SettingView(),
      () => SettingViewController(),
    ),
    _buildGetPageWithController(
      settingStartPage,
      () => const AppHomePageView(),
      () => AppHomePageController(),
    ),
    // Pages without controllers remain in their original GetPage format.
    GetPage(
      name: subscription,
      page: () => const SubscriptionView(),
    ),
    _buildGetPageWithController(
      suspendAccount,
      () => const SuspendAccountView(),
      () => SuspendAccountController(),
    ),
    // Pages without controllers remain in their original GetPage format.
    GetPage(
      name: webView,
      page: () => TPWebView(),
    ),
    // Pages without controllers remain in their original GetPage format.
    GetPage(
      name: activityList,
      page: () => const ActivityListView(),
    ),
    // Pages without controllers remain in their original GetPage format.
    GetPage(
      name: activityDetail,
      page: () => const ActivityDetailView(),
    ),
  ];

  static Future openUri({required String uri, String? forceTitle}) async {
    if (uri.isEmpty) {
      return Future.value(null);
    }

    return switch (Uri.tryParse(uri)) {
      null => Future.value(null),
      Uri uri => switch (uri.scheme) {
          'local' => Get.toNamed(uri.host),
          _ => Get.toNamed(
              TPRoute.webView,
              arguments: WebViewArgument(
                url: uri.toString(),
                forceTitle: forceTitle,
              ),
            ),
        },
    };
  }
}