import 'package:town_pass/service/shared_preferences_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppHomePageController extends GetxController {
  late SharedPreferences sharedPreferences;

  final RxInt currentIndex = RxInt(1);

  final String key = 'home_index';

  @override
  void onInit() {
    super.onInit();
    sharedPreferences = SharedPreferencesService().instance;
    currentIndex.value = sharedPreferences.getInt(key) ?? 1;
  }

  void onIndexChange(int index) {
    currentIndex.value = index;
    sharedPreferences.setInt(key, index);
  }
}
