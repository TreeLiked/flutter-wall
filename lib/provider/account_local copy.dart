import 'package:flutter/material.dart';
import 'package:iap_app/model/account.dart';

class AccountLocalProvider extends ChangeNotifier {
  Account _account;
  // 冗余accountId
  String _accountId;

  Account get account => _account;
  String get accountId => _accountId;

  void refresh() {
    notifyListeners();
  }

  void setAccount(Account account) {
    _account = account;
    _accountId = account == null ? "" : account.id ?? "";
    refresh();
  }
}
