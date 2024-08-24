import 'package:town_pass/bean/account.dart';
import 'package:town_pass/service/account_service.dart';
import 'package:get/get.dart';

class BasicInfoViewController extends GetxController {
  final AccountService _accountService = Get.find<AccountService>();

  // final Account? _account = Get.find<AccountService>().account;

  String get account => _accountService.account?.account ?? '';

  String get name => _accountService.account?.realName ?? '';

  final RxnString idNumber = RxnString();

  final RxnString birthday = RxnString();

  final RxnString email = RxnString();

  final RxnString phoneNumber = RxnString();

  final RxnString address = RxnString();

  @override
  void onInit() {
    super.onInit();
    syncAccount();
  }

  void syncAccount() {
    idNumber.value = _accountService.account?.idNumber;
    birthday.value = _accountService.account?.birthday;
    email.value = _accountService.account?.email;
    phoneNumber.value = _accountService.account?.phoneNumber;
    address.value = _accountService.account?.residentAddress;
  }

  void updateAccount({
    String? idNumber,
    String? birthday,
    String? email,
    String? phoneNumber,
    String? address,
  }) {
    Get.find<AccountService>().updateAccount(
      Account(
        id: _accountService.account?.id ?? '',
        account: _accountService.account?.account ?? '',
        username: _accountService.account?.username ?? '',
        realName: _accountService.account?.realName ?? '',
        idNumber: idNumber ?? _accountService.account?.idNumber ?? '',
        email: email ?? _accountService.account?.email ?? '',
        phoneNumber: phoneNumber ?? _accountService.account?.phoneNumber ?? '',
        birthday: birthday ?? _accountService.account?.birthday ?? '',
        memberType: _accountService.account?.memberType ?? '',
        verifyLevel: _accountService.account?.verifyLevel ?? '',
        addressList: _accountService.account?.addressList ?? [],
        residentAddress: address ?? _accountService.account?.residentAddress ?? '',
        citizen: _accountService.account?.citizen ?? true,
        nativePeople: _accountService.account?.nativePeople ?? true,
        cityInternetUid: _accountService.account?.cityInternetUid ?? '',
      ),
    );
    syncAccount();
  }
}
