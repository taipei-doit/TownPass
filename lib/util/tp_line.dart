import 'package:town_pass/util/tp_colors.dart';
import 'package:flutter/material.dart';

/// Create strait line, use with [TPLine.horizontal()] or [TPLine.vertical()]
final class TPLine extends StatelessWidget {
  /// 線條顏色
  ///
  /// Color of the line.
  final Color? color;

  /// 線條外邊距，預設為 [EdgeInsets.zero]。
  ///
  /// Margin around the line. Default is [EdgeInsets.zero].
  final EdgeInsetsGeometry? margin;

  /// 線條粗細度，預設為 [1.0]。
  ///
  /// Thickness  of the line. Default is [1.0].
  final double? thickness;

  /// 方向，決定線條為水平或垂直。
  ///
  /// Axis of the line, either horizontal or vertical
  final _Axis _axis;

  /// A horizontal line
  const TPLine.horizontal({
    super.key,
    this.color,
    this.thickness,
    this.margin,
  }) : _axis = _Axis.horizontal;

  /// A vertical line
  const TPLine.vertical({
    super.key,
    this.color,
    this.thickness,
    this.margin,
  }) : _axis = _Axis.vertical;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: switch (_axis) {
        _Axis.horizontal => Divider(
            height: 0.0,
            thickness: thickness ?? 1.0,
            color: color ?? TPColors.grayscale100,
          ),
        _Axis.vertical => VerticalDivider(
            width: 0.0,
            thickness: thickness ?? 1.0,
            color: color ?? TPColors.grayscale100,
          ),
      },
    );
  }
}

enum _Axis {
  horizontal,
  vertical,
  ;
}
