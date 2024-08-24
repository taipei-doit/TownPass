import 'package:town_pass/page/language/language_view_controller.dart';
import 'package:town_pass/util/tp_setting_list.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

extension on Language {
  String get string {
    return switch (this) {
      Language.traditionalChinese => '繁體中文',
      Language.english => 'English',
    };
  }
}

class LanguageView extends GetView<LanguageViewController> {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TPColors.white,
      appBar: const TPAppBar(title: '語言'),
      body: TPSettingList(
        children: [
          TPSettingListTile.selectionList(
            onIndexChange: (index) => controller.onIndexChange(index),
            selections: Language.values
                .map<SettingSelectionListItem>(
                  (language) => SettingSelectionListItem(title: language.string),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
