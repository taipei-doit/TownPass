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
}
