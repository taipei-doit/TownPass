import 'package:flutter/material.dart';
import 'package:town_pass/util/tp_bottom_navigation_factory.dart';
import 'package:town_pass/util/tp_colors.dart';

class TPBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int index)? onTap;

  const TPBottomNavigationBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: TPBottomNavigationFactory.barItemList,
        selectedItemColor: TPColors.primary500,
        unselectedItemColor: TPColors.grayscale950,
        selectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        showUnselectedLabels: true,
        currentIndex: currentIndex,
        onTap: onTap,
      ),
    );
  }
}
