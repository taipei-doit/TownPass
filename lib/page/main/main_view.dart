dart
// main_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/page/main/main_view_controller.dart';
import 'package:town_pass/util/tp_bottom_navigation_factory.dart';

class MainView extends GetView<MainViewController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: TPBottomNavigationFactory.viewList,
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(controller),
    );
  }

  Widget _buildBottomNavigationBar(MainViewController controller) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x140B0D0E),
            blurRadius: 16,
            offset: Offset(0, -10),
            spreadRadius: 0,
          )
        ],
      ),
      child: Obx(
        () => BottomNavigation(controller: controller),
      ),
    );
  }
}