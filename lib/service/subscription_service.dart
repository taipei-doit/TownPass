import 'package:get/get.dart';
import 'package:town_pass/bean/subscription.dart';

class SubscriptionService extends GetxService {
  final RxList<SubscriptionItem> itemList = RxList();

  Future<SubscriptionService> init() async {
    return this;
  }

  /// 新增訂閱項目，預設產生兩筆測試用的模擬資料
  void addSubscription({required String title}) {
    final now = DateTime.now();
    itemList.addAll([
      SubscriptionItem(
        title: title,
        content: '$title內容 ' * 20,
        datetime: now,
      ),
      SubscriptionItem(
        title: title,
        content: '$title內容2 ' * 20,
        datetime: now,
      ),
    ]);
  }

  void removeSubscription({required String title}) {
    itemList.removeWhere((item) => item.title == title);
  }
}
