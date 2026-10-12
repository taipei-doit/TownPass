import 'dart:convert';

import 'package:town_pass/bean/account.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AccountService extends GetxService {
  Account? _account;

  Account? get account => _account;

  Future<AccountService> init() async {
    final jsonString = await rootBundle.loadString(Assets.mockData.account);
    final accountResponse = AccountResponse.fromJson(
      jsonDecode(jsonString),
    );
    _account = accountResponse.account;
    return this;
  }

  void updateAccount(Account account) {
    _account = account;
  }
}
