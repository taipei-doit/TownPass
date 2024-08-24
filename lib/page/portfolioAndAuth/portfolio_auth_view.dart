import 'package:town_pass/page/portfolioAndAuth/portfolio_auth_view_controller.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

extension on ToggleTab {
  String get string {
    return switch (this) {
      ToggleTab.portfolio => '使用紀錄',
      ToggleTab.auth => '授權管理',
    };
  }
}

class PortfolioAndAuthView extends StatelessWidget {
  const PortfolioAndAuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final double toggleButtonWidth = (Get.width - 32) / 2;
    return GetBuilder(
        init: Get.put<PortfolioAuthViewController>(PortfolioAuthViewController()),
        builder: (controller) {
          return Scaffold(
            appBar: TPAppBar(
              title: '歷程與授權管理',
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: ToggleButtons(
                  color: Colors.cyan,
                  borderColor: Colors.cyan,
                  fillColor: Colors.cyan,
                  selectedColor: const Color(0xFFFFFFFF),
                  isSelected: List.generate(
                    controller.toggles.length,
                    (index) => index == controller.selectIndex,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  constraints: BoxConstraints(minWidth: toggleButtonWidth, minHeight: kToolbarHeight / 1.5),
                  onPressed: (index) {
                    if (index != controller.selectIndex) {
                      controller.selectIndex = index;
                    }
                  },
                  children: controller.toggles.map<Widget>((e) => Text(e.string)).toList(),
                ),
              ),
            ),
            body: IndexedStack(
              index: controller.selectIndex,
              children: const [
                Center(child: Text('使用紀錄')),
                Center(child: Text('授權管理')),
              ],
            ),
          );
        });
  }
}
