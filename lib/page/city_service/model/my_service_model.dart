import 'package:town_pass/page/city_service/model/my_service_item_model.dart';

abstract class MyServiceModel {
  static List<MyServiceCategory> get categoryList => const [
        MyServiceCategory(
          title: '市政服務',
          serviceList: [
            MyServiceItemId.dedicatedLine,
            MyServiceItemId.districtOffice,
            MyServiceItemId.reportIssue,
            MyServiceItemId.reservation,
            MyServiceItemId.iVoting,
            MyServiceItemId.dashboard,
            MyServiceItemId.survey,
            MyServiceItemId.police,
            MyServiceItemId.neighborhood,
          ],
        ),
        MyServiceCategory(
          title: '防疫醫療',
          serviceList: [
            MyServiceItemId.vaccineAppointment,
            MyServiceItemId.medicalAppointment,
          ],
        ),
        MyServiceCategory(
          title: '城市生活',
          serviceList: [
            MyServiceItemId.cityRadio,
            MyServiceItemId.familyCenter,
            MyServiceItemId.greenMap,
            MyServiceItemId.petFriendlyMap,
            MyServiceItemId.waterMeter,
            MyServiceItemId.essentialGoods,
            MyServiceItemId.library,
          ],
        ),
        MyServiceCategory(
          title: '探索臺北',
          serviceList: [
            MyServiceItemId.locationSearch,
            MyServiceItemId.zoo,
          ],
        ),
      ];
}

class MyServiceCategory {
  final String title;
  final List<MyServiceItemId> serviceList;

  const MyServiceCategory({
    required this.title,
    required this.serviceList,
  });
}