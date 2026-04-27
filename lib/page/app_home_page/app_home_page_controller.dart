import 'package:town_pass/service/shared_preferences_service.dart';
import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // 控制器不再直接使用 SharedPreferences，可移除此 import

class AppHomePageController extends GetxController {
  // 將 SharedPreferences 實例的直接存取替換為 SharedPreferencesService 的注入
  // 假設 SharedPreferencesService 已在某處透過 Get.put() 註冊為單例
  late final SharedPreferencesService _prefsService;

  final RxInt currentIndex = RxInt(1);

  // 原有的 'home_index' key 現在由 SharedPreferencesService 內部管理，
  // 因此從控制器中移除，避免魔法字串和重複定義。
  // final String key = 'home_index';

  @override
  void onInit() {
    super.onInit();
    // 透過 Get.find() 取得已註冊的 SharedPreferencesService 實例
    _prefsService = Get.find<SharedPreferencesService>();

    // 使用服務層提供的方法來讀取首頁索引，將存取邏輯封裝在服務中
    currentIndex.value = _prefsService.getHomeIndex() ?? 1;
  }

  void onIndexChange(int index) {
    currentIndex.value = index;
    // 使用服務層提供的方法來儲存首頁索引，控制器無需知道底層的 SharedPreferences 操作
    _prefsService.setHomeIndex(index);
  }
}

// 以下為跨檔案修改 SharedPreferencesService.dart 的概念性變動
// 您需要在 service/shared_preferences_service.dart 檔案中加入以下程式碼

// // service/shared_preferences_service.dart
// import 'package:shared_preferences/shared_preferences.dart';

// class SharedPreferencesService {
//   // 假設這裡有 SharedPreferences 的實際實例，例如透過 GetX 的 Get.putAsync 或是其他單例模式管理
//   // 以下為一個假設的同步 getter，與原有控制器中 `SharedPreferencesService().instance` 的行為保持一致
//   SharedPreferences get instance {
//     // 實際的實作會回傳已初始化好的 SharedPreferences 實例
//     throw UnimplementedError('SharedPreferencesService.instance getter must be implemented to return a valid SharedPreferences object.');
//   }

//   // 增加一個靜態常數來管理 key，避免魔法字串
//   static const String _homeIndexKey = 'home_index';

//   // 封裝讀取 home index 的方法
//   int? getHomeIndex() {
//     return instance.getInt(_homeIndexKey);
//   }

//   // 封裝寫入 home index 的方法，返回 Future<bool> 與 setInt 的行為一致
//   Future<bool> setHomeIndex(int index) {
//     return instance.setInt(_homeIndexKey, index);
//   }
// }

// // 在應用程式啟動時 (例如 main.dart 或 GetX Binding 中)
// // 確保 SharedPreferencesService 被註冊為 GetX 服務
// // Get.put(SharedPreferencesService());
```