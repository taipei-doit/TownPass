import 'package:town_pass/util/tp_colors.dart';
import 'package:flutter/material.dart';

class TPCard extends StatelessWidget {
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final double? cornerRadius;
  final Widget child;

  const TPCard({
    super.key,
    this.backgroundColor,
    this.padding,
    this.cornerRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: backgroundColor ?? TPColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cornerRadius ?? 3)),
        shadows: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
