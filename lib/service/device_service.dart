import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';

class DeviceService extends GetxService {
  AndroidDeviceInfo? androidDeviceInfo;
  IosDeviceInfo? iosDeviceInfo;
  BaseDeviceInfo? baseDeviceInfo;

  Future<DeviceService> init() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    baseDeviceInfo = await deviceInfo.deviceInfo;

    if (Platform.isAndroid) {
      androidDeviceInfo = await deviceInfo.androidInfo;
    }

    if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfo.iosInfo;
    }
    return this;
  }
}
