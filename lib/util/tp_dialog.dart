import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_line.dart';
import 'package:town_pass/util/tp_text.dart';

// This need a overall rework
class TPDialog {
  /// 構建標準對話框內容，包含可選的圖示、標題、內容及底部動作按鈕。
  /// 這個方法用於統一 showError 和 showInfo 的部分 UI 結構。
  ///
  /// [leadingIcon] 對話框頂部的圖示，例如警告圖示。
  /// [title] 對話框的標題文字。
  /// [contentWidget] 對話框的主體內容部件。
  /// [buttonText] 底部動作按鈕的文字。
  /// [buttonColor] 底部動作按鈕的文字顏色。
  /// [contentRequiresTitle] 判斷 [contentWidget] 是否必須在 [title] 存在時才顯示。
  ///                      這用於保留原始 showError/showInfo 中內容依賴於標題的行為。
  static Widget _buildStandardDialogBody({
    Widget? leadingIcon,
    String? title,
    Widget? contentWidget,
    required String buttonText,
    required Color buttonColor,
    bool contentRequiresTitle = true,
  }) {
    final List<Widget> children = [];

    if (leadingIcon != null) {
      children.add(leadingIcon);
      children.add(const SizedBox(height: 30));
    }

    if (title != null) {
      children.add(
        TPText(
          title,
          style: TPTextStyles.h2SemiBold,
          color: TPColors.grayscale950,
        ),
      );
    }

    // 保留原始邏輯：contentWidget 僅在 contentWidget 不為空
    // 且 (contentRequiresTitle 為 false 或 title 不為空) 時顯示。
    if (contentWidget != null && (!contentRequiresTitle || title != null)) {
      // 僅在 title 存在時才添加間距，保留原始行為
      if (title != null) {
        children.add(const SizedBox(height: 16));
      }
      children.add(contentWidget);
    }

    children.add(const SizedBox(height: 24));
    children.add(const TPLine.horizontal());
    children.add(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.back(),
        child: SizedBox(
          height: 48,
          child: Center(
            child: TPText(
              buttonText,
              style: TPTextStyles.h3SemiBold,
              color: buttonColor,
            ),
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  static Future showError({String? title, String? content}) async {
    return await TPDialog.show(
      padding: const EdgeInsets.only(top: 24.0),
      barrierDismissible: false,
      content: _buildStandardDialogBody(
        leadingIcon: Assets.svg.dialogWarning.svg(),
        title: title,
        contentWidget: content != null
            ? TPText(
                content,
                style: TPTextStyles.bodyRegular,
                color: TPColors.grayscale950,
              )
            : null,
        buttonText: '確認',
        buttonColor: TPColors.primary500,
        contentRequiresTitle: true, // 保持原始行為：內容只有在標題存在時才顯示
      ),
    );
  }

  static Future showInfo({String? title, Widget? content}) async {
    return await TPDialog.show(
      padding: const EdgeInsets.only(top: 24.0),
      barrierDismissible: false,
      content: _buildStandardDialogBody(
        title: title,
        contentWidget: content,
        buttonText: '關閉',
        buttonColor: TPColors.grayscale500,
        contentRequiresTitle: true, // 保持原始行為：內容只有在標題存在時才顯示
      ),
    );
  }

  Future showType2({required Widget asset, String? title, Widget? content}) async {
    TPDialog.show(
      content: Column(
        children: [
          asset,
          const SizedBox(height: 24),
          if (title != null && title.isNotEmpty) ...[
            TPText(title, style: TPTextStyles.h2SemiBold),
            const SizedBox(height: 16),
          ],
          content ?? const SizedBox.shrink(),
        ],
      ),
    );
  }

  static Future show({
    required Widget content,
    EdgeInsets padding = const EdgeInsets.fromLTRB(24.0, 24.0, 30.0, 24.0),
    bool barrierDismissible = true,
    bool showCloseCross = false,
  }) async {
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Stack(
          children: [
            Padding(
              padding: padding,
              child: content,
            ),
            if (showCloseCross) ...[
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Get.back(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Assets.svg.checkNCancel.svg(),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }
}