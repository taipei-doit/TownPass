import 'package:get/get.dart';

enum Language {
  traditionalChinese,
  english,
  ;
}

class LanguageViewController extends GetxController {
  // 將語系清單改為 final 欄位，確保其只被初始化一次。
  // 這提升了程式結構的清晰度，表明語系選項是固定的，
  // 並且避免了每次存取時重新創建 List 物件，略微優化了效能。
  final List<Language> languageList = [
    Language.traditionalChinese,
    Language.english,
  ];

  // TODO: update preference, update locale
  void onIndexChange(int index) {
    // 在方法內部明確從 languageList 取得對應的 Language enum 值。
    // 這使得 onIndexChange 方法的意圖更加清晰，提高了後續 TODO 邏輯的型別安全性，
    // 同時保持了原有的 API 輸入 (int index) 和行為 (若 index 超出範圍仍會拋出 RangeError)。
    final selectedLanguage = languageList[index];

    // TODO: update preference, update locale
  }
}