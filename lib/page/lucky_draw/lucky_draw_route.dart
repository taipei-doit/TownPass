import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:town_pass/page/lucky_draw/ui/draw_result_page.dart';
import 'package:town_pass/page/lucky_draw/ui/attractions_page.dart';
import 'package:town_pass/page/lucky_draw/ui/drawing_page.dart';
import 'package:town_pass/page/lucky_draw/ui/welcome_page.dart';
import 'package:town_pass/page/lucky_draw/ui/IncenseBurningPage.dart';

abstract class LuckyDrawRoute {
  static get getPage => GetPage(
        name: '/lucky_draw',
        page: () => const WelcomePage(),
        children: [
<<<<<<< HEAD
          GetPage(name: '/drawing', page: () => const IncenseBurningPage()),
=======
          GetPage(name: '/drawing', page: () => const DrawingPage()),
          GetPage(name: '/draw_result', page: () => const DrawResultPage()),
          GetPage(name: '/attractions', page: () => const AttractionListPage()),
>>>>>>> fcddd08becd5bbb93ea89bf98e10841a7cf229ff
          GetPage(name: '/welcome', page: () => const WelcomePage()),
        ],
      );
}
