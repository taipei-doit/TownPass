import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:town_pass/bean/mosaic_tile_service.dart';
import 'package:town_pass/gen/assets.gen.dart';

class CityServiceViewController extends GetxController {
  final Rx<MosaicTileService> staticService = Rx(_defaultStaticService);

  @override
  void onInit() async {
    super.onInit();
    staticService.value = MosaicTileService.fromJson(
      jsonDecode(await rootBundle.loadString(Assets.mockData.mosaicTileService)),
    );
  }
}

/// 以備 mosaic_tile_service.json 改壞時所用。
///
/// Use when mosaic_tile_service.json is broken.
MosaicTileService get _defaultStaticService => const MosaicTileService(
      contentList: [
        MosaicTileServiceItem(
          mainText: '市政服務',
          subText: 'Service',
          url: '',
          icon: 'assets/svg/Illustrations_gov.svg',
        ),
        MosaicTileServiceItem(
          mainText: '有話要說',
          subText: '1999',
          url: '',
          icon: 'assets/svg/icon_talk.svg',
        ),
        MosaicTileServiceItem(
          mainText: '警政報警',
          subText: 'Police',
          url: '',
          icon: 'assets/svg/icon_police.svg',
        ),
        MosaicTileServiceItem(
          mainText: '防疫醫療',
          subText: 'Health',
          url: '',
          icon: 'assets/svg/icon_covid_medical.svg',
        ),
        MosaicTileServiceItem(
          mainText: '市政APP',
          subText: 'More',
          url: '',
          icon: 'assets/svg/icon_more.svg',
        ),
        MosaicTileServiceItem(
          mainText: '城市生活',
          subText: 'City Life',
          url: '',
          icon: 'assets/svg/Illustrations_chair.svg',
        ),
      ],
    );
