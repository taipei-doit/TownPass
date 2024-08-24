import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PackageService extends GetxService {
  PackageInfo? packageInfo;

  Future<PackageService> init() async {
    packageInfo = await PackageInfo.fromPlatform();
    return this;
  }
}
