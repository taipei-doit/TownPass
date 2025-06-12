import 'package:flutter/material.dart';
import 'package:town_pass/gen/assets.gen.dart';

class OfficialServiceModel {
  static final List<OfficialServiceItem> contentList = [
    OfficialServiceItem(
      mainText: '市政服務',
      subText: 'Service',
      icon: Assets.svg.illustrationsGov.svg(),
      url: '',
    ),
    OfficialServiceItem(
      mainText: '有話要說',
      subText: '1999',
      icon: Assets.svg.iconTalk.svg(),
      url: 'https://taipei-pass-service.vercel.app/citizen-report/',
    ),
    OfficialServiceItem(
      mainText: '警政報案',
      subText: 'Police',
      icon: Assets.svg.iconPolice.svg(),
      url: 'local://online_police',
    ),
    OfficialServiceItem(
      mainText: '防疫醫療',
      subText: 'Health',
      icon: Assets.svg.iconCovidMedical.svg(),
      url: '',
    ),
    OfficialServiceItem(
      mainText: '市政APP',
      subText: 'More',
      icon: Assets.svg.iconMore.svg(),
      url: '',
    ),
    OfficialServiceItem(
      mainText: '城市生活',
      subText: 'City Life',
      icon: Assets.svg.illustrationsChair.svg(),
      url: '',
    ),
  ];
}

class OfficialServiceItem {
  final String mainText;
  final String? subText;
  final Widget icon;
  final String url;

  const OfficialServiceItem({
    required this.mainText,
    this.subText,
    required this.icon,
    required this.url,
  });
}
