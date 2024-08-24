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

    Timer.periodic(
      const Duration(seconds: 3),
      (timer) async {
        timer.cancel();
        final String banners = await rootBundle.loadString(Assets.mockData.homeBanner);
        list = HomeBannerList.fromJson(jsonDecode(banners));
        isLoading = false;
      },
    );
  }
}
