import 'package:flutter/material.dart';
import 'package:town_pass/util/tp_checkbox.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';

class TPCheckboxListTile extends StatelessWidget {
  final bool value;
  final void Function(bool?)? onChanged;
  final String content;

  const TPCheckboxListTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged?.call(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TPCheckbox(value: value, onChanged: onChanged),
          const SizedBox(width: 10),
          TPText(
            content,
            style: TPTextStyles.bodyRegular,
            color: TPColors.grayscale950,
          ),
        ],
      ),
    );
  }
}
