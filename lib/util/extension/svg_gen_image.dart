import 'package:flutter/material.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_svg_icon.dart';

extension TPSvgGenImageToIcon on SvgGenImage {
  /// Create [SvgIcon] from giving [SvgGenImage]
  Widget icon({String? semanticsLabel}) {
    return TPSvgIcon(
      icon: this,
      semanticsLabel: semanticsLabel,
    );
  }
}
