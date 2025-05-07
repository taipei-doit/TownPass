import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/service/account_service.dart';
import 'package:town_pass/service/device_service.dart';
import 'package:town_pass/service/geo_locator_service.dart';
import 'package:town_pass/service/notification_service.dart';
import 'package:town_pass/service/package_service.dart';
import 'package:town_pass/service/shared_preferences_service.dart';
import 'package:town_pass/service/subscription_service.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(
  //   widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  // );

  await initServices();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(const MyApp());
}

Future<void> initServices() async {
  await Get.putAsync<AccountService>(() async => await AccountService().init());
  await Get.putAsync<DeviceService>(() async => await DeviceService().init());
  await Get.putAsync<PackageService>(() async => await PackageService().init());
  await Get.putAsync<SharedPreferencesService>(() async => await SharedPreferencesService().init());
  await Get.putAsync<GeoLocatorService>(() async => await GeoLocatorService().init());
  await Get.putAsync<NotificationService>(() async => await NotificationService().init());

  Get.put<SubscriptionService>(SubscriptionService());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Town Pass',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: TPColors.grayscale50,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: TPColors.white,
        ),
        tabBarTheme: const TabBarTheme(
          labelColor: TPColors.primary500,
          labelStyle: TPTextStyles.h3SemiBold,
          labelPadding: EdgeInsets.symmetric(vertical: 12),
          unselectedLabelColor: TPColors.grayscale700,
          unselectedLabelStyle: TPTextStyles.h3Regular,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: UnderlineTabIndicator(
            borderRadius: BorderRadius.all(Radius.circular(2)),
            borderSide: BorderSide(color: TPColors.primary500, width: 4),
            insets: EdgeInsets.symmetric(horizontal: 16),
          ),
          indicatorAnimation: TabIndicatorAnimation.elastic,
          dividerHeight: 0,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: TPColors.primary500),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0.0,
          iconTheme: IconThemeData(size: 56),
          actionsIconTheme: IconThemeData(size: 56),
        ),
        actionIconTheme: ActionIconThemeData(
          backButtonIconBuilder: (_) => Semantics(
            excludeSemantics: true,
            child: Assets.svg.iconLeftArrow.svg(width: 24, height: 24),
          ),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: TPColors.red50,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: TPRoute.holder,
      onInit: () {
        NotificationService.requestPermission();
      },
      getPages: TPRoute.page,
    );
  }
}
