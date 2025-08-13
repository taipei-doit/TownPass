dart
import 'package:flutter/material.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Make simple svg icon widget, form Assets.svg.{icon}.svg, honors
/// IconTheme's color and size attribute.
class TPSvgIcon extends StatelessWidget {
  final SvgGenImage icon;
  final String? semanticsLabel;
  final double? size;
  final Color? color;

  const TPSvgIcon({
    super.key,
    required this.icon,
    this.semanticsLabel,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final iconSize = size ?? constraints.biggest.shortestSide;
        return SvgPicture.asset(
          icon.path,
          semanticsLabel: semanticsLabel,
          height: iconSize,
          width: iconSize,
          colorFilter: color != null
              ? ColorFilter.mode(color!, BlendMode.srcIn)
              : null,
        );
      },
    );
  }
}