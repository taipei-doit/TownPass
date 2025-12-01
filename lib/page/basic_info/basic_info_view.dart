import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:town_pass/page/basic_info/basic_info_view_controller.dart';
import 'package:town_pass/page/basic_info_edit/basic_info_edit_view_controller.dart';
import 'package:town_pass/util/text_field_validator/id_number_validator.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_setting_list.dart';

class BasicInfoView extends GetView<BasicInfoViewController> {
  const BasicInfoView({super.key});

  /// Builds a TPSettingListTile.navigate for editable basic information fields.
  /// Encapsulates the common navigation to `TPRoute.basicInfoEdit`
  /// and handling of the update callback for various fields,
  /// improving readability and reducing repetition in the widget tree.
  TPSettingListTile _buildEditableSettingTile({
    required String title,
    required RxString fieldRx,
    required Function(String value) updateFieldCallback,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    String defaultContent = '',
  }) {
    return TPSettingListTile.navigate(
      title: title,
      content: fieldRx.value ?? defaultContent,
      onTap: () {
        Get.toNamed(
          TPRoute.basicInfoEdit,
          arguments: BasicInfoEditArgument(
            title: title,
            currentValue: fieldRx.value ?? '',
            keyboardType: keyboardType,
            validator: validator,
          ),
        )?.then(
          (value) => switch (value) {
            String() => updateFieldCallback(value),
            Object() || null => null,
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TPAppBar(title: '基本資料'),
      body: Column(
        children: [
          Obx(
            () => TPSettingList(
              children: [
                TPSettingListTile.display(
                  title: controller.name,
                  content: '',
                ),
                _buildEditableSettingTile(
                  title: '身分證',
                  fieldRx: controller.idNumber,
                  updateFieldCallback: (value) => controller.updateAccount(idNumber: value),
                  validator: (idNumber) =>
                      idNumberValidator(idNumber: idNumber ?? '') ? null : '',
                  defaultContent: '',
                ),
                _buildEditableSettingTile(
                  title: '生日',
                  fieldRx: controller.birthday,
                  updateFieldCallback: (value) => controller.updateAccount(birthday: value),
                  validator: (string) => DateFormat('yyyy/MM/dd')
                              .tryParseStrict(string ?? '') == null
                          ? ''
                          : null,
                  keyboardType: TextInputType.datetime,
                  defaultContent: '',
                ),
                _buildEditableSettingTile(
                  title: '電子信箱',
                  fieldRx: controller.email,
                  updateFieldCallback: (value) => controller.updateAccount(email: value),
                  validator: (email) =>
                      EmailValidator.validate(email ?? '') ? null : '',
                  keyboardType: TextInputType.emailAddress,
                  defaultContent: '未設定',
                ),
                _buildEditableSettingTile(
                  title: '手機門號',
                  fieldRx: controller.phoneNumber,
                  updateFieldCallback: (value) => controller.updateAccount(phoneNumber: value),
                  validator: (phoneNumber) =>
                      RegExp(r'^09\d{8}$').hasMatch(phoneNumber ?? '')
                          ? null
                          : '',
                  keyboardType: TextInputType.phone,
                  defaultContent: '未設定',
                ),
                _buildEditableSettingTile(
                  title: '通訊地址',
                  fieldRx: controller.address,
                  updateFieldCallback: (value) => controller.updateAccount(address: value),
                  validator: (address) =>
                      (address != null && address.isNotEmpty) ? null : '',
                  defaultContent: '未設定',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}