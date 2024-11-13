import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class BasicInfoEditArgument {
  final String title;
  final String currentValue;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const BasicInfoEditArgument({
    required this.title,
    required this.currentValue,
    this.validator,
    this.keyboardType,
  });
}

class BasicInfoEditViewController extends GetxController {
  final BasicInfoEditArgument arg = Get.arguments;

  final TextEditingController controller = TextEditingController();

  final RxBool enableButton = RxBool(false);

  @override
  void onInit() {
    super.onInit();

    controller.addListener(() {
      enableButton.value = (arg.validator?.call(controller.text) == null);
    });
  }
}
