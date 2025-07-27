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

  static final List<GetPage> page = [
    GetPage(
      name: main,
      page: () => const MainView(),
      binding: BindingsBuilder(() {
        Get
          ..put<MainViewController>(MainViewController())
          ..put<PinnedServiceWidgetController>(PinnedServiceWidgetController());
      }),
    ),
    GetPage(
      name: account,
      page: () => const AccountView(),
      binding: BindingsBuilder(() {
        Get.put<AccountViewController>(AccountViewController());
      }),
    ),
    GetPage(
      name: basicInfo,
      page: () => const BasicInfoView(),
      binding: BindingsBuilder(() {
        Get.put<BasicInfoViewController>(BasicInfoViewController());
      }),
    ),
    GetPage(
      name: basicInfoEdit,
      page: () => const BasicInfoEditView(),
      binding: BindingsBuilder(() {
        Get.put<BasicInfoEditViewController>(BasicInfoEditViewController());
      }),
    ),
    GetPage(
        name: feedback,
        page: () => const FeedbackView(),
        binding: BindingsBuilder(() {
          Get.put<FeedbackViewController>(FeedbackViewController());
        })),
    GetPage(
      name: invoiceReceipt,
      page: () => const InvoiceReceiptView(),
    ),
    GetPage(
      name: language,
      page: () => const LanguageView(),
      binding: BindingsBuilder(() {
        Get.put<LanguageViewController>(LanguageViewController());
      }),
    ),
    GetPage(
      name: message,
      page: () => const MessageView(),
      binding: BindingsBuilder(() {
        Get.put<MessageViewController>(MessageViewController());
      }),
    ),
    GetPage(
      name: messageDetail,
      page: () => const MessageDetailView(),
    ),
    GetPage(
      name: onlinePolice,
      page: () => const OnlinePoliceView(),
    ),
    GetPage(
      name: phoneCallUserAgreement,
      page: () => const PhoneCallUserAgreementView(),
      binding: BindingsBuilder(() {
        Get.put<PhoneCallUserAgreementViewController>(PhoneCallUserAgreementViewController());
      }),
    ),
    GetPage(
      name: portfolioAndAuth,
      page: () => const PortfolioAndAuthView(),
    ),
    GetPage(
      name: qrCodeScan,
      page: () => const QRCodeScanView(),
      binding: BindingsBuilder(() {
        Get.put<QRCodeScanController>(QRCodeScanController());
      }),
    ),
    GetPage(
      name: serviceEdit,
      page: () => const CityServiceEditView(),
      binding: BindingsBuilder(() {
        Get.put<CityServiceEditViewController>(CityServiceEditViewController());
      }),
    ),
    GetPage(
      name: setting,
      page: () => const SettingView(),
      binding: BindingsBuilder(() {
        Get.put<SettingViewController>(SettingViewController());
      }),
    ),
    GetPage(
      name: settingStartPage,
      page: () => const AppHomePageView(),
      binding: BindingsBuilder(() {
        Get.put<AppHomePageController>(AppHomePageController());
      }),
    ),
    GetPage(
      name: subscription,
      page: () => const SubscriptionView(),
    ),
    GetPage(
      name: suspendAccount,
      page: () => const SuspendAccountView(),
      binding: BindingsBuilder(() {
        Get.put<SuspendAccountController>(SuspendAccountController());
      }),
    ),
    GetPage(
      name: webView,
      page: () => TPWebView(),
    ),
    GetPage(
      name: activityList,
      page: () => const ActivityListView(),
    ),
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
