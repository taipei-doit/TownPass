import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_line.dart';
import 'package:town_pass/util/tp_text.dart';

// This need a overall rework
class TPDialog {
  static Future showError({String? title, String? content}) async {
    return await TPDialog.show(
      padding: const EdgeInsets.only(top: 24.0),
      barrierDismissible: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.svg.dialogWarning.svg(),
          const SizedBox(height: 30),
          if (title != null) ...[
            TPText(
              title,
              style: TPTextStyles.h2SemiBold,
              color: TPColors.grayscale950,
            ),
          ],
          if (content != null) ...[
            if (title != null) ...[
              const SizedBox(height: 16),
              TPText(
                content,
                style: TPTextStyles.bodyRegular,
                color: TPColors.grayscale950,
              ),
            ],
          ],
          const SizedBox(height: 24),
          const TPLine.horizontal(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.back(),
            child: const SizedBox(
              height: 48,
              child: Center(
                child: TPText(
                  '確認',
                  style: TPTextStyles.h3SemiBold,
                  color: TPColors.primary500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future showInfo({String? title, Widget? content}) async {
    return await TPDialog.show(
      padding: const EdgeInsets.only(top: 24.0),
      barrierDismissible: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            TPText(
              title,
              style: TPTextStyles.h2SemiBold,
              color: TPColors.grayscale950,
            ),
          ],
          if (content != null) ...[
            if (title != null) ...[
              const SizedBox(height: 16),
              content,
            ],
          ],
          const SizedBox(height: 24),
          const TPLine.horizontal(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.back(),
            child: const SizedBox(
              height: 48,
              child: Center(
                child: TPText(
                  '關閉',
                  style: TPTextStyles.h3SemiBold,
                  color: TPColors.grayscale500,
                ),
              ),
            ),
          ),
        ],
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
