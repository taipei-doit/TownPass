import 'package:town_pass/bean/account.dart';
import 'package:town_pass/service/account_service.dart';
import 'package:get/get.dart';

class SuspendAccountController extends GetxController {
  // Explicitly hold the AccountService instance to avoid repeated Get.find calls.
  // This improves clarity by making the dependency explicit and potentially
  // offers a minor performance benefit by resolving the service only once.
  late final AccountService _accountService;

  @override
  void onInit() {
    super.onInit();
    // Resolve the AccountService dependency once when the controller is initialized.
    _accountService = Get.find<AccountService>();
  }

  Account? get account => _accountService.account;

  String get name => account?.realName ?? '';

  String get idNumber => account?.idNumber ?? '';
}