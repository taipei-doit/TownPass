import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:town_pass/page/lucky_draw/ui/draw_result_page.dart';
import 'package:town_pass/page/lucky_draw/ui/attractions_page.dart';
import 'package:town_pass/page/lucky_draw/ui/drawing_page.dart';
import 'package:town_pass/page/lucky_draw/ui/welcome_page.dart';

abstract class LuckyDrawRoute {
  static get getPage => GetPage(
        name: '/lucky_draw',
        page: () => const WelcomePage(),
        children: [
          GetPage(name: '/drawing', page: () => const DrawingPage()),
          GetPage(name: '/draw_result', page: () => const DrawResultPage()),
          GetPage(name: '/attractions', page: () => const AttractionsPage()),
          GetPage(name: '/welcome', page: () => const WelcomePage()),
        ],
      );
}
