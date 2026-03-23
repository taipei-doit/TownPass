import 'package:town_pass/bean/account.dart';
import 'package:town_pass/service/account_service.dart';
import 'package:get/get.dart';

class SuspendAccountController extends GetxController {
  // 快取 AccountService 實例，避免每次存取 account 時都重複查找服務
  final AccountService _accountService = Get.find<AccountService>();

  Account? get account => _accountService.account;

  String get name => account?.realName ?? '';

  String get idNumber => account?.idNumber ?? '';
}