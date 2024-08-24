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
  final String contactPhoneNumber = '02-27208889';

  List<FeedbackType> get feedbackTypeList => [
        FeedbackType.register,
        FeedbackType.login,
        FeedbackType.cardUsage,
        FeedbackType.perk,
        FeedbackType.other,
      ];

  FeedbackType? _selectType;

  FeedbackType? get selectType => _selectType;

  set selectType(FeedbackType? type) {
    _selectType = type;
    update();
  }

  TextEditingController controller = TextEditingController();

  Future<void> sendFeedback() async {}
}
