import 'package:town_pass/service/shared_preferences_service.dart';
import 'package:town_pass/util/tp_bottom_navigation_bar_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class HolderViewController extends GetxController {
  final RxInt index = RxInt(1);

  List<BottomNavigationBarItem> get items => TPBottomNavigationBarItemFactory.barItems
      .map(
        (item) => BottomNavigationBarItem(
          icon: item.icon(),
          activeIcon: item.activeIcon(),
          label: item.label(),
          tooltip: item.tooltip(),
        ),
      )
      .toList();

  List<Widget> get pageList => TPBottomNavigationBarItemFactory.barItems
      .map(
        (item) => item.view(),
      )
      .toList();

  @override
  void onInit() {
    super.onInit();
    index.value = SharedPreferencesService().instance.getInt('home_index') ?? index.value;
  }
}
