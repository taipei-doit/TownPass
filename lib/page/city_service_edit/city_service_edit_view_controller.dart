import 'package:get/get.dart';
import 'package:town_pass/page/city_service/model/my_service_model.dart';
import 'package:town_pass/page/city_service/widget/pinned_service_widget_controller.dart';

class CityServiceEditViewController extends GetxController {
  final Map<MyServiceCategory, List<MyServiceItemId>> categoryMap = {
    for (var category in MyServiceCategory.values)
      category: MyServiceItemId.values
          .where(
            (itemId) => itemId.item.category == category,
          )
          .toList(),
  }..removeWhere(
      (category, serviceList) => serviceList.isEmpty,
    );

  final RxBool isEditMode = RxBool(false);

  PinnedServiceWidgetController get pinnedServiceController => Get.find<PinnedServiceWidgetController>();

  List<MyServiceItemId>? _recordPinnedList;

  @override
  void onInit() {
    super.onInit();
    isEditMode.listen((isEditMode) {
      if (isEditMode) {
        _recordPinnedList = List.of(pinnedServiceController.pinnedList);
      }
    });
  }

  void cancelEdit() {
    if (_recordPinnedList != null) {
      Get.find<PinnedServiceWidgetController>().replaceWith(_recordPinnedList!);
      _recordPinnedList = null;
    }
    isEditMode.value = false;
  }
}
