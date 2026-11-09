import 'package:town_pass/bean/account.dart';
import 'package:town_pass/service/account_service.dart';
import 'package:get/get me.dart';

class SuspendAccountController extends GetxController {
  // 快取 AccountService 實例，避免每次存取 account 時都重複查找服務
  final AccountService _accountService = Get.find<AccountService>();

  /// 當前登入的帳號資訊
  Account? get account => _accountService.account;

  /// 使用者真實姓名，若無資料則傳回空字串
  String get name => account?.realName ?? '';

  /// 使用者身分證字號，若無資料則傳回空字串
  String get idNumber => account?.idNumber ?? '';
}
