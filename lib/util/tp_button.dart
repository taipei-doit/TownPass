import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:flutter/material.dart';

final class TPButton extends StatelessWidget {
  final bool? enable;
  final Color? backgroundColor;
  final Color? pressedBackgroundColor;
  final Color? borderColor;
  final Color? pressedBorderColor;
  final Color? textColor;
  final String? text;

  final Function? onPressed;

  const TPButton({
    super.key,
    this.enable,
    this.backgroundColor,
    this.pressedBackgroundColor,
    this.borderColor,
    this.pressedBorderColor,
    this.onPressed,
    this.textColor,
    required this.text,
  });

  const TPButton.primary({
    super.key,
    this.enable,
    this.text,
    this.onPressed,
  })  : backgroundColor = TPColors.primary500,
        pressedBackgroundColor = TPColors.primary600,
        borderColor = null,
        pressedBorderColor = null,
        textColor = TPColors.white;

  const TPButton.secondary({
    super.key,
    this.enable,
    this.text,
    this.onPressed,
  })  : backgroundColor = TPColors.white,
        pressedBackgroundColor = TPColors.primary50,
        borderColor = TPColors.primary500,
        pressedBorderColor = TPColors.primary500,
        textColor = TPColors.primary500;

  const TPButton.alarm({
    super.key,
    this.enable,
    this.text,
    this.onPressed,
  })  : backgroundColor = TPColors.red500,
        pressedBackgroundColor = TPColors.red300,
        borderColor = null,
        pressedBorderColor = null,
        textColor = TPColors.white;

  const TPButton.remainder({
    super.key,
    this.enable,
    this.text,
    this.onPressed,
  })  : backgroundColor = TPColors.secondary500,
        pressedBackgroundColor = TPColors.orange300,
        borderColor = null,
        pressedBorderColor = null,
        textColor = TPColors.white;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      clipBehavior: Clip.antiAlias,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          switch (enable) {
            true || null => backgroundColor,
            false => TPColors.grayscale100,
          },
        ),
        side: WidgetStateProperty.resolveWith<BorderSide?>(
          (Set<WidgetState> states) {
            if (enable ?? true) {
              if (states.contains(WidgetState.pressed)) {
                if (pressedBorderColor != null) {
                  return BorderSide(color: pressedBorderColor!);
                }
              }
              if (borderColor != null) {
                return BorderSide(color: borderColor!);
              }
            }
            return null;
          },
        ),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        overlayColor: WidgetStateProperty.all(pressedBackgroundColor),
        foregroundColor: WidgetStateProperty.all(
          switch (enable) {
            true || null => textColor,
            false => TPColors.grayscale500,
          },
        ),
        textStyle: WidgetStateProperty.all(TPTextStyles.h3Regular),
      ),
      onPressed: switch (enable) {
        true || null => (() => onPressed?.call()),
        false => null,
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Center(child: TPText(text)),
      ),
    );
  }
}
