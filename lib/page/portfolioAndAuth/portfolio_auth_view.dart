import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/page/portfolioAndAuth/portfolio_auth_view_controller.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';

extension on ToggleTab {
  String get label {
    return switch (this) {
      ToggleTab.portfolio => '使用紀錄',
      ToggleTab.auth => '授權管理',
    };
  }

  Widget get contentWidget {
    return Center(child: TPText(label));
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
                  selectedColor: TPColors.white,
                  isSelected: ToggleTab.values.map((tab) => tab.index == controller.selectIndex).toList(),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  constraints: BoxConstraints(minWidth: toggleButtonWidth, minHeight: kToolbarHeight / 1.5),
                  onPressed: (index) {
                    if (index != controller.selectIndex) {
                      controller.selectIndex = index;
                    }
                  },
                  children: ToggleTab.values.map<Widget>((tab) => TPText(tab.label)).toList(),
                ),
              ),
            ),
            body: IndexedStack(
              index: controller.selectIndex,
              children: ToggleTab.values.map<Widget>((tab) => tab.contentWidget).toList(),
            ),
          );
        });
  }
}