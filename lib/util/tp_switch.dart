import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TPSwitchController {
  final RxBool value = RxBool(false);
  final Function(bool)? onChanged;
  bool enable = true;

  TPSwitchController(
    bool? initValue, {
    this.onChanged,
  }) {
    value.value = initValue ?? false;
  }
}

class TPSwitch extends StatelessWidget {
  final RxBool _value = RxBool(false);
  final TPSwitchController? controller;

  TPSwitch({
    super.key,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tpSwitchSize.width,
      height: tpSwitchSize.height,
      child: FittedBox(
        fit: BoxFit.fill,
        child: Obx(
          () => Switch(
            value: controller?.value.value ?? _value.value,
            onChanged: switch (controller?.enable) {
              true => (value) {
                  controller?.value.value = value;
                  controller?.onChanged?.call(value);
                },
              false => null,
              null => (value) => _value.value = value,
            },
            activeTrackColor: TPColors.primary500,
            inactiveTrackColor: TPColors.grayscale100,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            trackOutlineColor: WidgetStateProperty.resolveWith(
              (final Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return null;
                }
                return TPColors.grayscale200;
              },
            ),
            thumbColor: WidgetStateProperty.resolveWith(
              (final Set<WidgetState> states) => TPColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
