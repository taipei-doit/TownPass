import 'package:get/get.dart';

enum Language {
  traditionalChinese,
  english,
  ;
}

class LanguageViewController extends GetxController {
  List<Language> get languageList => [
        Language.traditionalChinese,
        Language.english,
      ];

  // TODO: update preference, update locale
  void onIndexChange(int index) {

  }
}
