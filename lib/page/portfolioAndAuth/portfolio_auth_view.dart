import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/page/portfolioAndAuth/portfolio_auth_view_controller.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';

extension on ToggleTab {
  /// Returns the display label for the toggle tab.
  String get label {
    return switch (this) {
      ToggleTab.portfolio => '使用紀錄',
      ToggleTab.auth => '授權管理',
    };
  }

  /// Returns the content widget associated with the toggle tab.
  /// This centralizes the tab content definition, improving maintainability.
  Widget get contentWidget {
    // For this example, the content is a simple text widget matching the label.
    // In a real application, these would typically be the actual page widgets
    // (e.g., PortfolioPage(), AuthManagementPage()).
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
                  // 使用 ToggleTab.values 來確保與枚舉定義的一致性，並簡化列表生成。
                  isSelected: List.generate(
                    ToggleTab.values.length, // 根據枚舉的總數生成選擇狀態列表
                    (index) => index == controller.selectIndex,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  constraints: BoxConstraints(minWidth: toggleButtonWidth, minHeight: kToolbarHeight / 1.5),
                  onPressed: (index) {
                    if (index != controller.selectIndex) {
                      controller.selectIndex = index;
                    }
                  },
                  // 將 ToggleTab.values 映射到其 label 以作為按鈕的內容。
                  children: ToggleTab.values.map<Widget>((tab) => TPText(tab.label)).toList(),
                ),
              ),
            ),
            body: IndexedStack(
              index: controller.selectIndex,
              // 將 ToggleTab.values 映射到其 contentWidget 以作為 IndexedStack 的內容。
              // 這樣一來，所有與 Tab 相關的內容都統一由枚舉定義。
              children: ToggleTab.values.map<Widget>((tab) => tab.contentWidget).toList(),
            ),
          );
        });
  }
}