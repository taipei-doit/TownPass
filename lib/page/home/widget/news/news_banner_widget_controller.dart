# 下面放重構後的程式碼，不要用 ``` 包
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

    // 原始程式碼使用 Timer.periodic 後立即取消，效果等同於一次性的延遲執行。
    // 為了提升程式碼的可讀性與語義的清晰度，已將其重構為使用 Future.delayed，
    // 同時保留了原有的 3 秒延遲載入行為。
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