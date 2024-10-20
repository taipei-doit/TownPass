import 'package:get/get.dart';
import 'package:town_pass/service/shared_preferences_service.dart';

class PhoneCallUserAgreementViewController extends GetxController {
  final RxBool checkboxValue = RxBool(false);

  Future<void> agree() async {
    await SharedPreferencesService()
        .instance
        .setBool(
          SharedPreferencesService.keyPhoneCallUserAgreement,
          true,
        )
        .then(
          (_) => Get.back(),
        );
  }
}
