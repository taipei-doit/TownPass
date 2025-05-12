import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/page/holder/holder_view_controller.dart';
import 'package:town_pass/util/tp_bottom_navigation_bar.dart';
import 'package:town_pass/util/tp_bottom_navigation_factory.dart';

class HolderView extends GetView<HolderViewController> {
  const HolderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Scaffold(
          body: IndexedStack(
            index: controller.index.value,
            children: TPBottomNavigationFactory.viewList,
          ),
          bottomNavigationBar: TPBottomNavigationBar(
            currentIndex: controller.index.value,
            onTap: (index) => controller.index.value = index,
          ),
        );
      },
    );
  }
}
