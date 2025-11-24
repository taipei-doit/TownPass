import 'package:town_pass/service/shared_preferences_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppHomePageController extends GetxController {
  // 將 SharedPreferences 改為透過 GetX 的依賴注入取得。
  // 這假設 SharedPreferences 實例已在應用程式啟動時，例如在 main.dart 或 binding 中，
  // 使用 Get.putAsync<SharedPreferences>(() => SharedPreferences.getInstance()) 進行註冊。
  // 這樣做能讓控制器更清晰地表達其依賴，提升可測試性，並避免 `late` 初始化。
  final SharedPreferences sharedPreferences = Get.find<SharedPreferences>();

  final RxInt currentIndex = RxInt(1);

  final String key = 'home_index';

  @override
  void onInit() {
    super.onInit();
    // 由於 sharedPreferences 已在建構時透過 Get.find() 取得，
    // 此處無需再手動初始化。
    currentIndex.value = sharedPreferences.getInt(key) ?? 1;
  }

  void onIndexChange(int index) {
    currentIndex.value = index;
    sharedPreferences.setInt(key, index);
  }
}