import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_text.dart';

class TPDialog {
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
