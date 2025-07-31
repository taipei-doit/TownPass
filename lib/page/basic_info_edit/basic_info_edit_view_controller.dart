import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class BasicInfoEditViewController extends GetxController {
  final String title = Get.parameters['title']!;
  final String currentValue = Get.parameters['currentValue']!;
  final String? Function(String?)? validator = Get.parameters['validator'] as String? Function(String?)?;
  final TextInputType? keyboardType = Get.parameters['keyboardType'] as TextInputType?;

  final TextEditingController controller = TextEditingController();

  final RxBool enableButton = RxBool(false);

  @override
  void onInit() {
    super.onInit();

    controller.addListener(() {
      enableButton.value = (validator?.call(controller.text) == null);
    });
  }
}