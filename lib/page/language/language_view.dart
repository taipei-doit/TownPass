import 'package:town_pass/page/language/language_view_controller.dart';
import 'package:town_pass/util/tp_setting_list.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 原有的 Language 列舉擴充功能 (extension on Language) 已從此檔案移除，
// 並將其定義移至 `language_view_controller.dart` 中的 `Language` 列舉定義內。
// 這樣能將列舉的顯示邏輯與列舉本身共同維護，提升程式碼的結構與可讀性，
// 且當新增語言選項時，只需在 `Language` 列舉中一併更新即可。

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