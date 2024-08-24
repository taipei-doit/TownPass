import 'package:get/get.dart';

class SettingViewController extends GetxController {
  bool _isNotificationOn = true;

  bool get isNotificationOn => _isNotificationOn;

  set isNotificationOn(bool isOn) {
    _isNotificationOn = isOn;
    update();
  }

  bool _isBioAuthOn = true;

  bool get isBioAuthOn => _isBioAuthOn;

  set isBioAuthOn(bool isOn) {
    _isBioAuthOn = isOn;
    update();
  }

  DateTime get lastLoginDateTime => DateTime.now();
}
