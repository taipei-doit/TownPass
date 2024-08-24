import 'package:get/get.dart';

enum ToggleTab {
  portfolio,
  auth,
  ;
}

class PortfolioAuthViewController extends GetxController {
  List<ToggleTab> get toggles => [
        ToggleTab.portfolio,
        ToggleTab.auth,
      ];

  int _selectIndex = 0;

  int get selectIndex => _selectIndex;

  set selectIndex(int index) {
    _selectIndex = index;
    update();
  }
}
