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
import 'package:town_pass/page/card/card_view_controller.dart';
import 'package:town_pass/page/city_service/city_service_view_controller.dart';
import 'package:town_pass/page/city_service/widget/pinned_service_widget_controller.dart';
import 'package:town_pass/page/city_service_edit/city_service_edit_view.dart';
import 'package:town_pass/page/city_service_edit/city_service_edit_view_controller.dart';
import 'package:town_pass/page/feedback/feedback_view.dart';
import 'package:town_pass/page/feedback/feedback_view_controller.dart';
import 'package:town_pass/page/home/home_view_controller.dart';
import 'package:town_pass/page/home/subscription/subscription_view.dart';
import 'package:town_pass/page/invoice_receipt/invoice_receipt_view.dart';
import 'package:town_pass/page/language/language_view.dart';
import 'package:town_pass/page/language/language_view_controller.dart';
import 'package:town_pass/page/message/message_view.dart';
import 'package:town_pass/page/message/message_view_controller.dart';
import 'package:town_pass/page/message_detail/message_detail_view.dart';
import 'package:town_pass/page/perk/perk_view_controller.dart';
import 'package:town_pass/page/portfolioAndAuth/portfolio_auth_view.dart';
import 'package:town_pass/page/setting/setting_view.dart';
import 'package:town_pass/page/setting/setting_view_controller.dart';
import 'package:town_pass/page/suspend_account/suspend_account_controller.dart';
import 'package:town_pass/page/suspend_account/suspend_account_view.dart';
import 'package:town_pass/page/holder/holder_view.dart';
import 'package:town_pass/util/tp_web_view.dart';
import 'package:town_pass/page/holder/holder_view_controller.dart';
import 'package:get/get.dart';

abstract class TPRoute {
  static const String holder = '/';
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
  static const String portfolioAndAuth = '/portfolio_and_auth';
  static const String service = '/service';
  static const String serviceEdit = '/service_edit';
  static const String setting = '/setting';
  static const String settingStartPage = '/setting_start_page';
  static const String subscription = '/subscription';
  static const String suspendAccount = '/suspend_account';
  static const String webView = '/web_view';

  static final List<GetPage> page = [
    GetPage(
      name: holder,
      page: () => const HolderView(),
      binding: BindingsBuilder(() {
        Get
          ..put<HolderViewController>(HolderViewController())
          ..put<HomeViewController>(HomeViewController())
          ..put<CardViewController>(CardViewController())
          ..put<CityServiceViewController>(CityServiceViewController())
          ..put<PerkViewController>(PerkViewController())
          ..put<PinnedServiceWidgetController>(PinnedServiceWidgetController());
          // ..put<BillViewController>(BillViewController())
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
      name: portfolioAndAuth,
      page: () => const PortfolioAndAuthView(),
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
}
