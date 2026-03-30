import 'package:flutter/material.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_svg_icon.dart';

// 將擴充功能的名稱從 `TPSvgGenImageToIcon` 修改為 `SvgGenImageIconExtension`。
// 這個新名稱更明確地指出它是為 `SvgGenImage` 提供圖標相關功能的擴充，
// 並且移除了在擴充功能名稱中重複的 "ToIcon" 字樣，讓命名更簡潔且語義清晰。
extension SvgGenImageIconExtension on SvgGenImage {
  /// Create [TPSvgIcon] from a [SvgGenImage] instance.
  ///
  /// This extension method allows directly calling `.icon()` on an `SvgGenImage` object
  /// to get a [TPSvgIcon] widget, making it convenient for displaying SVG assets.
  ///
  /// 修正了文件中的錯字 ("giving" 改為 "given" 並進一步改為 "from a ... instance")，
  /// 同時明確指出返回的具體類型是 `TPSvgIcon` (而非泛指的 `SvgIcon`)，
  /// 並增加了對擴充功能用途的簡要說明，提升了文件的精確性和可讀性。
  Widget icon({String? semanticsLabel}) {
    return TPSvgIcon(
      icon: this,
      semanticsLabel: semanticsLabel,
    );
  }
}