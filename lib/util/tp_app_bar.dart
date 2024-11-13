import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_constant.dart';
import 'package:town_pass/util/tp_text.dart';

// appbar leading IconButton cannot be change
class TPAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final String? title;
  final List<Widget>? actions;
  final bool? showLogo;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TPAppBarController? controller;

  const TPAppBar({
    super.key,
    this.showLogo,
    this.backgroundColor,
    this.foregroundColor,
    this.leading,
    this.bottom,
    this.title,
    this.actions,
    this.controller,
  });

  @override
  Size get preferredSize => Size.fromHeight(kTPToolbarHeight + (bottom?.preferredSize.height ?? 0));

  TPAppBarController get _titleController => controller ?? TPAppBarController(title);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      key: key,
      leading: leading,
      title: _titleWidget(),
      actions: actions ?? [const SizedBox(width: 56)],
      backgroundColor: backgroundColor ?? TPColors.white,
      foregroundColor: foregroundColor ?? TPColors.grayscale700,
      elevation: 0,
      centerTitle: true,
      bottom: bottom,
      surfaceTintColor: Colors.transparent,
    );
  }

  Widget _titleWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLogo ?? false) ...[
          SizedBox(
            width: 24,
            height: 24,
            child: Semantics(excludeSemantics: true, child: Assets.svg.logoS.svg()),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Obx(
            () => TPText(
              _titleController.title.value,
              style: TPTextStyles.h3SemiBold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

class TPAppBarController {
  final RxnString title = RxnString();

  TPAppBarController([String? title]) {
    this.title.value = title;
  }
}
