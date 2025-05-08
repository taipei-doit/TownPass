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

  List<FeedbackType> get feedbackTypeList => [
        FeedbackType.register,
        FeedbackType.login,
        FeedbackType.cardUsage,
        FeedbackType.perk,
        FeedbackType.other,
      ];

  final RxBool isDropdownOpened = RxBool(false);

  final Rxn<FeedbackType> feedbackType = Rxn<FeedbackType>(null);

  TextEditingController controller = TextEditingController();

  Future<void> sendFeedback() async {}

  void toggleDropdownMenu() {
    overlayPortalController.toggle();
    isDropdownOpened.value = !isDropdownOpened.value;
  }
}
