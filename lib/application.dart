import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/account.dart';

class Application {
  static Router router;
  static GlobalKey<NavigatorState> key = GlobalKey();
  static SharedPreferences sp;
  static double screenWidth;
  static double screenHeight;
  // static GetIt getIt = GetIt.instance;

  static int _ordId;
  static String _orgName;

  static Account _account;

  static Account get getAccount {
    return _account;
  }

  static int get getOrgId {
    return _ordId;
  }

  static String get getOrgName {
    return _orgName;
  }

  static initSp() async {
    sp = await SharedPreferences.getInstance();
  }

  static setupLocator() {
    // getIt.registerSingleton(NavigateService());
  }

  static void setAccount(Account acc) {
    _account = acc;
  }

  static void setOrgId(int orgId) {
    _ordId = orgId;
  }

  static void setOrgName(String name) {
    _orgName = name;
  }
}
