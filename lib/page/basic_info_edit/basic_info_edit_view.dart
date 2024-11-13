import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/page/basic_info_edit/basic_info_edit_view_controller.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_button.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';

class BasicInfoEditView extends GetView<BasicInfoEditViewController> {
  const BasicInfoEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TPAppBar(
        title: controller.arg.title,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              container: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TPText(
                    controller.arg.title,
                    style: TPTextStyles.h3SemiBold,
                  ),
                  TPText(controller.arg.currentValue),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Semantics(
              container: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    excludeSemantics: true,
                    child: TPText(
                      '請輸入新${controller.arg.title}',
                      style: TPTextStyles.h3SemiBold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.controller,
                    validator: controller.arg.validator,
                    decoration: InputDecoration(
                      hintText: '請輸入新${controller.arg.title}',
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: TPColors.primary500, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    keyboardType: controller.arg.keyboardType,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => TPButton.primary(
                enable: controller.enableButton.value,
                text: '確認',
                onPressed: () {
                  Get.back(result: controller.controller.text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
