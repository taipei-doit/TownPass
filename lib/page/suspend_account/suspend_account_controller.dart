import 'package:town_pass/bean/account.dart';
import 'package:town_pass/service/account_service.dart';
import 'package:get/get.dart';

class SuspendAccountController extends GetxController {
  Account? get account => Get.find<AccountService>().account;

  String get name => account?.realName ?? '';

  String get idNumber => account?.idNumber ?? '';
}
