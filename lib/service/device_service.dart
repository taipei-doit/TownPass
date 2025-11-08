import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io'; 

import 'package:get/get.dart';

class DeviceService extends GetxService {
  AndroidDeviceInfo? androidDeviceInfo;
  IosDeviceInfo? iosDeviceInfo;
  WebBrowserInfo? webBrowserInfo; 
  BaseDeviceInfo? baseDeviceInfo;

  Future<DeviceService> init() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      webBrowserInfo = await deviceInfo.webBrowserInfo;
      baseDeviceInfo = webBrowserInfo; 
    } else {

      if (Platform.isAndroid) {
        androidDeviceInfo = await deviceInfo.androidInfo;
        baseDeviceInfo = androidDeviceInfo; 
      } else if (Platform.isIOS) {
        iosDeviceInfo = await deviceInfo.iosInfo;
        baseDeviceInfo = iosDeviceInfo; 
      }
    }
    return this;
  }
}