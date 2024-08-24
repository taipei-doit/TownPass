import 'package:town_pass/page/holder/holder_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HolderView extends GetView<HolderViewController> {
  const HolderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.index.value,
          children: controller.pageList,
        ),
      ),
      bottomNavigationBar: Container(
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
          () => BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: controller.items,
            selectedItemColor: const Color(0xFF2EB6C7),
            unselectedItemColor: const Color(0xFF000000),
            selectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            showUnselectedLabels: true,
            currentIndex: controller.index.value,
            onTap: (index) {
              controller.index.value = index;
            },
          ),
        ),
      ),
    );
  }
}
