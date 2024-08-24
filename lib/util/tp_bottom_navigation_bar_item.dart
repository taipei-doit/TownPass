import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/city_service/city_service_view.dart';
import 'package:town_pass/page/home/home_view.dart';
import 'package:town_pass/page/perk/perk_view.dart';
import 'package:flutter/material.dart';

class TPBottomNavigationBarItemFactory {
  static List<TPBottomNavigationBarItem> get barItems => const [
        ServiceBottomNavigationBarItem(),
        HomeBottomNavigationBarItem(),
        PerkBottomNavigationBarItem(),
        // BillBottomNavigationBarItem(),
      ];
}

sealed class TPBottomNavigationBarItem {
  const TPBottomNavigationBarItem();

  String label();

  Widget icon();

  Widget activeIcon();

  String tooltip() => label();

  StatelessWidget view();
}

class ServiceBottomNavigationBarItem extends TPBottomNavigationBarItem {
  const ServiceBottomNavigationBarItem();

  @override
  Widget icon() => Assets.svg.iconTabbarServiceDefault.svg(height: 24, width: 24);

  @override
  Widget activeIcon() => Assets.svg.iconTabbarServiceSelect.svg(height: 24, width: 24);

  @override
  String label() => '服務';

  @override
  StatelessWidget view() => const CityServiceView();
}

class HomeBottomNavigationBarItem extends TPBottomNavigationBarItem {
  const HomeBottomNavigationBarItem();

  @override
  Widget icon() => Assets.svg.iconTabbarHomeDefault.svg(height: 24, width: 24);

  @override
  Widget activeIcon() => Assets.svg.iconTabbarHomeSelect.svg(height: 24, width: 24);

  @override
  String label() => '首頁';

  @override
  StatelessWidget view() => const HomeView();
}

class PerkBottomNavigationBarItem extends TPBottomNavigationBarItem {
  const PerkBottomNavigationBarItem();

  @override
  Widget icon() => Assets.svg.iconTabbarCouponDefault.svg(height: 24, width: 24);

  @override
  Widget activeIcon() => Assets.svg.iconTabbarCouponSelect.svg(height: 24, width: 24);

  @override
  String label() => '優惠';

  @override
  StatelessWidget view() => const PerkView();
}

// class BillBottomNavigationBarItem extends TPBottomNavigationBarItem {
//   const BillBottomNavigationBarItem();
//
//   @override
//   Widget icon() => Assets.svg.iconTabbarAccountDefault.svg(height: 24, width: 24);
//
//   @override
//   Widget activeIcon() => Assets.svg.iconTabbarAccountSelect.svg(height: 24, width: 24);
//
//   @override
//   String label() => '帳務';
// }
