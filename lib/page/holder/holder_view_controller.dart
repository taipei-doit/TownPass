import 'package:get/get.dart';
import 'package:town_pass/service/shared_preferences_service.dart';

class HolderViewController extends GetxController {
  final RxInt index = RxInt(1);

  @override
  void onInit() {
    super.onInit();
    index.value = switch (SharedPreferencesService().instance.getInt(SharedPreferencesService.keyHomeIndex)) {
      int sharedPreferencesIndex => sharedPreferencesIndex,
      null => index.value,
    };
  }
}
