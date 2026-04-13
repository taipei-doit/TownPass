import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum FeedbackType {
  register,
  login,
  cardUsage,
  perk,
  other,
  ;
}

class FeedbackViewController extends GetxController {
  final LayerLink dropdownMenuLayerLink = LayerLink();
  final OverlayPortalController overlayPortalController = OverlayPortalController();

  final String contactPhoneNumber = '02-27208889';

  // 改善：直接使用 FeedbackType.values 獲取所有列舉值。
  // 這樣做更簡潔、更有效率，因為避免了每次訪問時都重新創建一個 List，
  // 並且當 FeedbackType 增加新的值時，此處無需修改。
  List<FeedbackType> get feedbackTypeList => FeedbackType.values;

  final RxBool isDropdownOpened = RxBool(false);

  final Rxn<FeedbackType> feedbackType = Rxn<FeedbackType>(null);

  TextEditingController controller = TextEditingController();

  Future<void> sendFeedback() async {}

  void toggleDropdownMenu() {
    overlayPortalController.toggle();
    isDropdownOpened.value = !isDropdownOpened.value;
  }
}