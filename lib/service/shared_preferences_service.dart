import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService extends GetxService {
  static SharedPreferences? _sharedPreferences;

  SharedPreferences get instance => _sharedPreferences!;

  Future<SharedPreferencesService> init() async {
    await SharedPreferences.getInstance().then(
      (value) => _sharedPreferences = value,
    );
    return this;
  }
}
