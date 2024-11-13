import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/extension/string.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_line.dart';
import 'package:town_pass/util/tp_switch.dart';
import 'package:town_pass/util/tp_text.dart';

class TPSettingList extends StatelessWidget {
  final List<TPSettingListTile> children;

  const TPSettingList({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: children,
    );
  }
}

class TPSettingListTile extends StatelessWidget {
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final GestureTapCallback? onTap;
  final Widget? child;
  final bool? excludeFromSemantics;

  const TPSettingListTile({
    super.key,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.child,
    this.excludeFromSemantics,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      excludeFromSemantics: excludeFromSemantics ?? false,
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap?.call(),
      child: Container(
        color: backgroundColor,
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  factory TPSettingListTile.listTile({
    bool? excludeFromSemantics,
    Widget? leading,
    Widget? title,
    Widget? subtitle,
    Widget? content,
    Widget? trailing,
    EdgeInsets? padding,
    Color? backgroundColor,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
  }) {
    return TPSettingListTile(
      excludeFromSemantics: excludeFromSemantics,
      padding: padding,
      backgroundColor: backgroundColor ?? TPColors.white,
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: 16.0),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  title,
                  if (subtitle != null) ...[
                    const SizedBox(height: 1.0),
                    subtitle,
                  ],
                ],
              ],
            ),
          ),
          if (content != null) ...[
            const SizedBox(width: 8.0),
            content,
          ],
          if (trailing != null) ...[
            const SizedBox(width: 12.0),
            trailing,
          ],
        ],
      ),
    );
  }

  factory TPSettingListTile.display({
    Widget? leading,
    required String title,
    String? subtitle,
    required String content,
    Widget? trailing,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
  }) {
    return TPSettingListTile.listTile(
      excludeFromSemantics: true,
      onTap: () => onTap?.call(),
      onLongPress: () => onLongPress?.call(),
      leading: leading,
      title: title.text(
        style: TPTextStyles.h3Regular,
        color: TPColors.grayscale700,
      ),
      subtitle: subtitle?.text(
        style: TPTextStyles.bodyRegular,
        color: TPColors.grayscale700,
      ),
      content: content.text(
        style: TPTextStyles.bodyRegular,
        color: TPColors.grayscale500,
      ),
      trailing: trailing,
    );
  }

  factory TPSettingListTile.navigate({
    Widget? leading,
    required String title,
    String? subtitle,
    String? content,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
  }) {
    return TPSettingListTile.listTile(
      onTap: () => onTap?.call(),
      onLongPress: () => onLongPress?.call(),
      leading: leading,
      title: title.text(
        style: TPTextStyles.h3Regular,
        color: TPColors.grayscale700,
      ),
      subtitle: subtitle?.text(
        style: TPTextStyles.bodyRegular,
        color: TPColors.grayscale700,
      ),
      content: content?.text(
        style: TPTextStyles.bodyRegular,
        color: TPColors.grayscale500,
      ),
      trailing: Assets.svg.iconExpand.svg(),
    );
  }

  factory TPSettingListTile.header({
    Color? background,
    Widget? leading,
    required String title,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
  }) {
    return TPSettingListTile.listTile(
      excludeFromSemantics: true,
      backgroundColor: background ?? TPColors.transparent,
      onTap: () => onTap?.call(),
      onLongPress: () => onLongPress?.call(),
      title: title.text(
        style: TPTextStyles.h3SemiBold,
        color: TPColors.grayscale700,
      ),
    );
  }

  factory TPSettingListTile.switchButton({
    required String title,
    Color? background,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
    TPSwitchController? controller,
  }) {
    return TPSettingListTile.listTile(
      excludeFromSemantics: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11.5),
      backgroundColor: background,
      onTap: () => onTap?.call(),
      onLongPress: () => onLongPress?.call(),
      title: title.text(
        style: TPTextStyles.h3Regular,
        color: TPColors.grayscale700,
      ),
      trailing: TPSwitch(controller: controller),
    );
  }

  factory TPSettingListTile.line() {
    return const TPSettingListTile(
      excludeFromSemantics: true,
      padding: EdgeInsets.zero,
      child: TPLine.horizontal(
        margin: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  factory TPSettingListTile.space({double? height, Color? backgroundColor}) {
    return TPSettingListTile(
      excludeFromSemantics: true,
      backgroundColor: backgroundColor,
      padding: EdgeInsets.zero,
      child: SizedBox(height: height ?? 8.0),
    );
  }

  factory TPSettingListTile.selectionList({
    required List<SettingSelectionListItem> selections,
    int? initialIndex,
    Function(int)? onIndexChange,
  }) {
    return _SettingSelectionList(
      selections: selections,
      initialIndex: initialIndex,
      onIndexChange: (index) => onIndexChange?.call(index),
    );
  }
}

class _SettingSelectionList extends TPSettingListTile {
  final List<SettingSelectionListItem> selections;
  final int? initialIndex;
  final Function(int)? onIndexChange;

  _SettingSelectionList({
    required this.selections,
    this.initialIndex,
    this.onIndexChange,
  }) {
    currentIndex.value = initialIndex ?? 0;
    currentIndex.listen((index) => onIndexChange?.call(index));
  }

  final RxInt currentIndex = RxInt(0);

  @override
  Widget build(BuildContext context) {
    return TPSettingListTile(
      padding: EdgeInsets.zero,
      child: Obx(
        () => TPSettingList(
          children: selections
              .mapIndexed(
                (index, item) {
                  return [
                    switch (index == currentIndex.value) {
                      true => TPSettingListTile.listTile(
                          leading: item.selectedLeading,
                          title: TPText(
                            item.title,
                            style: TPTextStyles.h3SemiBold,
                            color: TPColors.primary500,
                          ),
                          trailing: Assets.svg.iconCheckFouse.svg(),
                        ),
                      false => TPSettingListTile.listTile(
                          leading: item.unselectedLeading,
                          title: TPText(
                            item.title,
                            style: TPTextStyles.h3Regular,
                            color: TPColors.grayscale950,
                          ),
                          onTap: () => currentIndex.value = index,
                        ),
                    },
                    TPSettingListTile.line()
                  ];
                },
              )
              .flattened
              .toList(),
        ),
      ),
    );
  }
}

class SettingSelectionListItem {
  final Widget? selectedLeading;
  final Widget? unselectedLeading;
  final String title;

  const SettingSelectionListItem({
    required this.title,
    this.selectedLeading,
    this.unselectedLeading,
  });
}
