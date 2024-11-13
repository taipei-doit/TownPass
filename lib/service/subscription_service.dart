import 'package:get/get.dart';
import 'package:town_pass/bean/subscription.dart';

class SubscriptionService extends GetxService {
  final RxList<SubscriptionItem> itemList = RxList();

  Future<SubscriptionService> init() async {
    return this;
  }

  void addSubscription({required String title}) {
    itemList.addAll([
      SubscriptionItem(
        title: title,
        content: '$title內容 ' * 20,
        datetime: DateTime.now(),
      ),
      SubscriptionItem(
        title: title,
        content: '$title內容2 ' * 20,
        datetime: DateTime.now(),
      ),
    ]);
  }

  void removeSubscription({required String title}) {
    itemList.removeWhere((item) => item.title == title);
  }
}
