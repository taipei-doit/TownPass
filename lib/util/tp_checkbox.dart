import 'package:flutter/material.dart';
import 'package:town_pass/util/tp_colors.dart';

class TPCheckbox extends StatelessWidget {
  final bool value;
  final void Function(bool?)? onChanged;

  const TPCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 24,
      child: Checkbox(
        activeColor: TPColors.primary500,
        side: const BorderSide(
          color: TPColors.grayscale300,
          width: 2.0,
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
