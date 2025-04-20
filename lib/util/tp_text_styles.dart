import 'package:town_pass/gen/fonts.gen.dart';
import 'package:flutter/material.dart';

/// An immutable style describing how to format and paint text within Pass App
final class TPTextStyles extends TextStyle {
  const TPTextStyles({
    super.fontSize,
    super.fontFamily,
    super.fontWeight,
    super.height,
  });

  /// H1-Regular
  /// ```
  /// fontSize: 36
  /// fontWeight: regular(w400)
  /// ```
  /// Usage:
  static const TPTextStyles h1Regular = TPTextStyles(
    fontSize: 36.0,
    fontFamily: FontFamily.pingFangTC,
    fontWeight: FontWeight.w400,
  );

  /// H1-SimiBold
  /// ```
  /// fontSize: 36
  /// fontWeight: semiBold(w600)
  /// ```
  /// Usage:
  static const TPTextStyles h1SemiBold = TPTextStyles(
    fontSize: 36,
    fontFamily: FontFamily.pingFangTC,
    fontWeight: FontWeight.w600,
  );

  /// H2-Regular
  /// ```
  /// fontSize: 24
  /// fontWeight: regular(w400)
  /// ```
  /// Usage:
  static const TPTextStyles h2Regular = TPTextStyles(
    fontSize: 24,
    fontFamily: FontFamily.pingFangTC,
    fontWeight: FontWeight.w400,
  );

  /// H2-SemiBold
  /// ```
  /// fontSize: 24
  /// fontWeight: semiBold(w600)
  /// ```
  /// Usage:
  static const TPTextStyles h2SemiBold = TPTextStyles(
    fontSize: 24,
    fontFamily: FontFamily.pingFangTC,
    fontWeight: FontWeight.w600,
  );

  /// H3-Regular 標題
  /// ```
  /// fontSize: 16
  /// fontWeight: regular(w400)
  /// ```
  /// Usage:
  static const TPTextStyles h3Regular = TPTextStyles(
    fontSize: 16,
    fontFamily: FontFamily.pingFangTC,
    fontWeight: FontWeight.w400,
  );

  /// H3-SemiBold 標題粗體
  /// ```
  /// fontSize: 16
  /// fontWeight: semiBold(w600)
  /// ```
  /// Usage:
  static const TPTextStyles h3SemiBold = TPTextStyles(
    fontSize: 16,
    fontFamily: FontFamily.pingFangTC,
    fontWeight: FontWeight.w600,
  );

  /// Body-Regular 內文
  /// ```
  /// fontSize: 14
  /// fontWeight: regular(w400)
  /// ```
  /// Usage:
  static const TPTextStyles bodyRegular = TPTextStyles(
    fontSize: 14,
    fontFamily: FontFamily.pingFangTC,
    fontWeight: FontWeight.w400,
  );

  /// Body-SemiBold 內文粗體
  /// ```
  /// fontSize: 14
  /// fontWeight: semiBold(w600)
  /// ```
  /// Usage:
  static const TPTextStyles bodySemiBold = TPTextStyles(
    fontSize: 14,
    fontFamily: FontFamily.pingFangTC,
    fontWeight: FontWeight.w600,
  );

  /// Caption 輔助說明
  /// ```
  /// fontSize: 12
  /// fontWeight: regular(w400)
  /// ```
  /// Usage:
  static const TPTextStyles caption = TPTextStyles(
    fontSize: 12,
    fontFamily: FontFamily.pingFangTC,
    fontWeight: FontWeight.w600,
  );

  static const TPTextStyles titleSemiBold = TPTextStyles(
    fontSize: 18,
    fontFamily: FontFamily.pingFangTC,
    fontWeight: FontWeight.w600,
  );
}
