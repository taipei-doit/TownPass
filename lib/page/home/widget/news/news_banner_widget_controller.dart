import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:town_pass/bean/home_banner.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NewsBannerWidgetController extends GetxController {
  final CarouselSliderController controller = CarouselSliderController();

  int _carouselIndex = 0;

  int get carouselIndex => _carouselIndex;

  set carouselIndex(int index) {
    _carouselIndex = index;
    update();
  }

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    update();
  }

  HomeBannerList? list;

  @override
  void onInit() {
    super.onInit();

    // 原有的 Timer.periodic 在執行一次後立即取消，
    // 其行為等同於一個延遲一次性執行 (one-shot) 的操作。
    // 將其替換為 Future.delayed，能更清晰地表達延遲載入的意圖，
    // 並避免了設置一個週期性定時器卻立即取消的冗餘操作。
    Future.delayed(
      const Duration(seconds: 3),
      () async {
        final String banners = await rootBundle.loadString(Assets.mockData.homeBanner);
        list = HomeBannerList.fromJson(jsonDecode(banners));
        isLoading = false;
      },
    );
  }
}