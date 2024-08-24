import 'dart:io';

import 'package:town_pass/bean/account.dart';
import 'package:town_pass/service/account_service.dart';
import 'package:town_pass/service/device_service.dart';
import 'package:town_pass/service/package_service.dart';
import 'package:town_pass/util/extension/datetime.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AccountViewController extends GetxController {
  late PackageInfo packageInfo;
  final DeviceService deviceService = Get.find<DeviceService>();

  final AccountService _accountService = Get.find<AccountService>();

  Account? get account => Get.find<AccountService>().account;

  final RxnString name = RxnString();

  final RxnString phoneNumber = RxnString();

  String get appVersion => 'TPS-V ${Get.find<PackageService>().packageInfo?.version}';

  @override
  void onInit() {
    super.onInit();
    syncAccount();
  }

  void syncAccount() {
    name.value = _accountService.account?.realName ?? '';
    phoneNumber.value = _accountService.account?.phoneNumber.replaceRange(2, 7, '***') ?? '';
  }

  String mailQuery() {
    // https://pub.dev/packages/url_launcher#encoding-urls
    // apply percentage encoded to space
    return {
      'subject': '城市通相關事宜',
      'body': 'APP版本：$appVersion\n'
          '手機型號：${_model()}\n'
          'OS 版本：${_osVersion()}\n'
          '時間：${DateTime.now().format('yyyy/MM/dd hh:mm')}\n'
          '----------------------------------------------------',
    }
        .entries
        .map(
          (map) => '${Uri.encodeComponent(map.key)}=${Uri.encodeComponent(map.value)}',
        )
        .join('&');
  }

  String _model() {
    if (Platform.isAndroid) {
      return '${deviceService.androidDeviceInfo?.brand ?? ''} ${deviceService.androidDeviceInfo?.model ?? ''}';
    }
    if (Platform.isIOS) {
      return deviceService.iosDeviceInfo?.model ?? '';
    }
    return '';
  }

  String _osVersion() {
    if (Platform.isAndroid) {
      return 'Android ${deviceService.androidDeviceInfo?.version.release ?? ''}';
    }
    if (Platform.isIOS) {
      return deviceService.iosDeviceInfo?.systemVersion ?? '';
    }
    return '';
  }
}
