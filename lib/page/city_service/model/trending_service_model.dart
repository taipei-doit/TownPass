import 'package:flutter/material.dart';
import 'package:town_pass/gen/assets.gen.dart';

abstract final class TrendingServiceModel {
  static List<TrendingService> get serviceList {
    return [
      TrendingService(
        title: '找地點',
        icon: Assets.svg.iconLocationSearch.svg(),
        url: 'https://taipei-pass-service.vercel.app/surrounding-service/',
      ),
      TrendingService(
        icon: Assets.svg.iconDashboardReports.svg(),
        title: '市政資訊儀表板',
        url: 'https://dashboard.gov.taipei/',
        forceWebViewTitle: '市政資訊儀表板',
      ),
      TrendingService(
        icon: Assets.svg.iconLocationSearch.svg(),
        title: '施工資訊',
        url: '',
      ),
      // 在此列表後加入新熱門按鈕
      // add new trending service button here
    ];
  }
}

class TrendingService {
  final Widget icon;
  final String title;
  final String url;
  final String? forceWebViewTitle;

  const TrendingService({
    required this.icon,
    required this.title,
    required this.url,
    this.forceWebViewTitle,
  });
}
