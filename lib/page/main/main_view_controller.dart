import 'package:get/get.dart';
import 'package:town_pass/service/shared_preferences_service.dart';
import 'package:town_pass/util/tp_bottom_navigation_factory.dart';

class MainViewController extends GetxController {
  final RxInt currentIndex = RxInt(
    switch (SharedPreferencesService().instance.getInt(SharedPreferencesService.keyHomeIndex)) {
      int sharedPreferencesIndex => sharedPreferencesIndex,
      null => TPBottomNavigationFactory.defaultIndex,
    },
  );

  @override
  void onInit() {
    super.onInit();

    // Allow overriding the initial tab index when navigating to the main route.
    // Accept either a positional int argument (Get.arguments = int) or a map
    // with an 'index' key: Get.arguments = {'index': 0}.
    final arg = Get.arguments;
    if (arg != null) {
      int? idx;
      if (arg is int) {
        idx = arg;
      } else if (arg is Map && arg['index'] is int) {
        idx = arg['index'] as int;
      }

      if (idx != null) {
        currentIndex.value = idx;
        // Persist user choice so future app launches remember last tab.
        SharedPreferencesService().instance.setInt(SharedPreferencesService.keyHomeIndex, idx);
      }
    }
  }
}
