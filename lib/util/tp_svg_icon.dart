import 'package:flutter/material.dart';
import 'package:town_pass/gen/assets.gen.dart';

/// Make simple svg icon widget, form Assets.svg.{icon}.svg, honors
/// IconTheme's color and size attribute.
class TPSvgIcon extends StatelessWidget {
  final SvgGenImage icon;
  final String? semanticsLabel;

  const TPSvgIcon({
    super.key,
    required this.icon,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    return icon.svg(
      semanticsLabel: semanticsLabel,
      height: iconTheme.size,
      width: iconTheme.size,
      colorFilter: _buildColorFilter(iconTheme.color), // Extracted for better structure
    );
  }

  /// Builds a ColorFilter based on the provided color,
  /// applying a srcIn blend mode if the color is not null.
  ColorFilter? _buildColorFilter(Color? color) {
    return switch (color) {
      Color c => ColorFilter.mode(
          c,
          BlendMode.srcIn,
        ),
      null => null,
    };
  }
}