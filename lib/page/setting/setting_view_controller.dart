dart
import 'package:get/get.dart';

class SettingViewController extends GetxController {
  // 使用 RxBool 管理 notification 狀態
  final RxBool _isNotificationOn = true.obs;
  bool get isNotificationOn => _isNotificationOn.value;
  set isNotificationOn(bool isOn) => _isNotificationOn.value = isOn;

  // 使用 RxBool 管理 bio authentication 狀態
  final RxBool _isBioAuthOn = true.obs;
  bool get isBioAuthOn => _isBioAuthOn.value;
  set isBioAuthOn(bool isOn) => _isBioAuthOn.value = isOn;

  DateTime get lastLoginDateTime => DateTime.now();
}