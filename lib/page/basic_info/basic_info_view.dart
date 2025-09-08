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
                TPSettingListTile.navigate(
                  title: '身分證',
                  content: controller.idNumber.value,
                  onTap: () {
                    Get.toNamed(
                      TPRoute.basicInfoEdit,
                      arguments: BasicInfoEditArgument(
                        title: '身分證',
                        currentValue: controller.idNumber.value ?? '',
                        validator: (idNumber) =>
                            idNumberValidator(idNumber: idNumber ?? '')
                                ? null
                                : '',
                      ),
                    )?.then(
                      (value) => switch (value) {
                        String() => controller.updateAccount(idNumber: value),
                        Object() || null => null,
                      },
                    );
                  },
                ),
                TPSettingListTile.navigate(
                  title: '生日',
                  content: controller.birthday.value,
                  onTap: () {
                    Get.toNamed(
                      TPRoute.basicInfoEdit,
                      arguments: BasicInfoEditArgument(
                        title: '生日',
                        currentValue: controller.birthday.value ?? '',
                        keyboardType: TextInputType.datetime,
                        validator: (string) => DateFormat('yyyy/MM/dd')
                                    .tryParseStrict(string ?? '') ==
                                null
                            ? ''
                            : null,
                      ),
                    )?.then(
                      (value) => switch (value) {
                        String() => controller.updateAccount(birthday: value),
                        Object() || null => null,
                      },
                    );
                  },
                ),
                TPSettingListTile.navigate(
                  title: '電子信箱',
                  content: controller.email.value ?? '未設定',
                  onTap: () {
                    Get.toNamed(
                      TPRoute.basicInfoEdit,
                      arguments: BasicInfoEditArgument(
                        title: '電子信箱',
                        currentValue: controller.email.value ?? '',
                        keyboardType: TextInputType.emailAddress,
                        validator: (email) =>
                            EmailValidator.validate(email ?? '') ? null : '',
                      ),
                    )?.then(
                      (value) => switch (value) {
                        String() => controller.updateAccount(email: value),
                        Object() || null => null,
                      },
                    );
                  },
                ),
                TPSettingListTile.navigate(
                  title: '手機門號',
                  content: controller.phoneNumber.value ?? '未設定',
                  onTap: () {
                    Get.toNamed(
                      TPRoute.basicInfoEdit,
                      arguments: BasicInfoEditArgument(
                        title: '手機門號',
                        currentValue: controller.phoneNumber.value ?? '',
                        keyboardType: TextInputType.phone,
                        validator: (phoneNumber) =>
                            RegExp(r'^09\d{8}$').hasMatch(phoneNumber ?? '')
                                ? null
                                : '',
                      ),
                    )?.then(
                      (value) => switch (value) {
                        String() =>
                          controller.updateAccount(phoneNumber: value),
                        Object() || null => null,
                      },
                    );
                  },
                ),
                TPSettingListTile.navigate(
                  title: '通訊地址',
                  content: controller.address.value ?? '未設定',
                  onTap: () {
                    Get.toNamed(
                      TPRoute.basicInfoEdit,
                      arguments: BasicInfoEditArgument(
                        title: '通訊地址',
                        currentValue: controller.address.value ?? '',
                        validator: (address) =>
                            (address != null && address.isNotEmpty) ? null : '',
                      ),
                    )?.then(
                      (value) => switch (value) {
                        String() => controller.updateAccount(address: value),
                        Object() || null => null,
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
