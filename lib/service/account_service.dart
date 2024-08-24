import 'dart:convert';

import 'package:town_pass/bean/account.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AccountService extends GetxService {
  Account? _account;

  Account? get account => _account;

  Future<AccountService> init() async {
    final accountResponse = AccountResponse.fromJson(
      jsonDecode(await rootBundle.loadString(Assets.mockData.account)),
    );
    _account = accountResponse.account;
    return this;
  }

  updateAccount(Account account) {
    _account = account;
  }
}
