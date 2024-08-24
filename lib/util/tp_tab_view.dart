import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TPTabView extends StatelessWidget {
  final List<String> titles;
  final List<Widget> children;
  final Function(int)? onTabChanged;

  TPTabView({
    super.key,
    required this.titles,
    required this.children,
    this.onTabChanged,
  }) {
    if (titles.length != children.length) {
      throw Exception("titles' length does not match children's length");
    }
  }

  final RxInt index = RxInt(0);

  final RxInt _previousIndex = RxInt(0);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: titles.length,
      initialIndex: index.value,
      child: Builder(
        builder: (context) {
          final TabController controller = DefaultTabController.of(context);
          return Column(
            children: [
              _TPTabBar(titles: titles),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    final int index = switch (controller.indexIsChanging) {
                      // tap
                      true => controller.index,
                      // slide
                      false => controller.animation!.value.round(),
                    };
                    if (_previousIndex.value != index) {
                      _previousIndex.value = index;
                      onTabChanged?.call(index);
                    }
                    return false;
                  },
                  child: TabBarView(
                    controller: controller,
                    children: children,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TPTabBar extends StatelessWidget {
  final List<String> titles;

  const _TPTabBar({required this.titles});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TPColors.white,
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
        indicator: const UnderlineTabIndicator(
          borderRadius: BorderRadius.all(Radius.circular(2)),
          borderSide: BorderSide(color: TPColors.primary500, width: 4),
        ),
        labelColor: TPColors.primary500,
        labelStyle: TPTextStyles.h3SemiBold,
        unselectedLabelColor: TPColors.grayscale700,
        unselectedLabelStyle: TPTextStyles.h3Regular,
        tabs: titles.map(
          (title) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: TPText(title),
            );
          },
        ).toList(),
      ),
    );
  }
}
