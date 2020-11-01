import 'dart:core';

import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/account_display_info.dart';
import 'package:iap_app/model/account/account_edit_param.dart';
import 'package:iap_app/model/account/school/account_campus_profile.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/util/http_util.dart';

class MemberApi {
  static const String _TAG = "MemberApi";

  static Future<Account> getMyAccount(String token) async {
    Response response;
    LogUtil.e(Api.API_QUERY_ACCOUNT, tag: _TAG);
    try {
      response = await httpUtil2.dio.post(Api.API_QUERY_ACCOUNT);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      dynamic json2 = json["data"];
      print(json2);
      print(response.data);
      if (json2 == null) {
        return null;
      }
      Account account = Account.fromJson(json2);
      print(account.toJson());
      return account;
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<Account> getAccountProfile(String accountId) async {
    LogUtil.e(Api.API_QUERY_ACCOUNT_PROFILE, tag: _TAG);
    Response response;
    try {
      response = await httpUtil2.dio.post(Api.API_QUERY_ACCOUNT_PROFILE);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      print(json);
      dynamic json2 = json["data"];
      if (json2 == null) {
        return null;
      }
      Account account = Account.fromJson(json2);
      return account;
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<AccountCampusProfile> getAccountCampusProfile(String accountId) async {
    LogUtil.e(Api.API_QUERY_ACCOUNT_CAMPUS_PROFILE, tag: _TAG);

    Response response;
    try {
      response = await httpUtil2.dio.get(Api.API_QUERY_ACCOUNT_CAMPUS_PROFILE);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      print(json);
      dynamic json2 = json["data"];
      if (json2 == null) {
        return null;
      }
      AccountCampusProfile profile = AccountCampusProfile.fromJson(json2);
      return profile;
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<AccountDisplayInfo> getAccountDisplayProfile(String accountId) async {
    LogUtil.e(Api.API_QUERY_FILTERED_ACCOUNT_PROFILE, tag: _TAG);
    Response response;
    try {
      response = await httpUtil2.dio.get(
          Api.API_QUERY_FILTERED_ACCOUNT_PROFILE + "?${SharedConstant.ACCOUNT_ID_IDENTIFIER}=" + accountId);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      print(json);
      dynamic json2 = json["data"];
      if (json2 == null) {
        return null;
      }
      AccountDisplayInfo account = AccountDisplayInfo.fromJson(json2);
      return account;
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<Result> modAccount(AccountEditParam param) async {
    LogUtil.e(Api.API_ACCOUNT_MOD_BASIC, tag: _TAG);
    Response response;
    try {
      response = await httpUtil2.dio.post(Api.API_ACCOUNT_MOD_BASIC, data: param);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      print(json);
      return Result.fromJson(json);
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<Result> sendPhoneVerificationCode(String phone) async {
    Response response;
    String url = Api.API_SEND_VERIFICATION_CODE + "?p=$phone";
    LogUtil.e(url, tag: _TAG);
    try {
      response = await httpUtil2.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      print(json);
      return Result.fromJson(json);
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<Result> checkVerificationCode(String phone, String vCode) async {
    Response response;
    String url = Api.API_CHECK_VERIFICATION_CODE + "?p=$phone&c=$vCode";
    LogUtil.e(url, tag: _TAG);
    try {
      response = await httpUtil2.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      print(json);
      return Result.fromJson(json);
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<Result> checkNickRepeat(String nick) async {
    Response response;
    String url = Api.API_CHECK_NICK_REPEAT + "?n=$nick";
    LogUtil.e(url, tag: _TAG);
    try {
      response = await httpUtil2.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      print(json);
      return Result.fromJson(json);
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<Result> register(String phone, String nick, String avatarUrl, int orgId, String iCode) async {
    Response response;
    String url = Api.API_REGISTER_BY_PHONE;
    var data = {
      'phone': phone,
      'nick': nick,
      'avatarUrl': avatarUrl,
      'orgId': orgId,
      'iCode': iCode,
    };
    LogUtil.e(url, tag: _TAG);
    try {
      response = await httpUtil2.dio.post(url, data: data);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      return Result.fromJson(json);
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<Result> login(String phone) async {
    Response response;
    String url = Api.API_LOGIN_BY_PHONE;
    LogUtil.e(url, tag: _TAG);
    var data = {
      'phone': phone,
    };
    try {
      response = await httpUtil2.dio.post(url, data: data);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      print(json);
      return Result.fromJson(json);
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<Map<String, dynamic>> getAccountSetting({String passiveAccountId}) async {
    String url = Api.API_QUERY_ACCOUNT_SETTING +
        "?${SharedConstant.ACCOUNT_ID_IDENTIFIER}=" +
        (passiveAccountId ?? "");
    LogUtil.e(url, tag: _TAG);
    Response response;
    try {
      response = await httpUtil2.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      dynamic json2 = json["data"];
      if (json2 == null || json['isSuccess'] == false) {
        return null;
      }
      Map<String, dynamic> settingMap = Api.convertResponse(json2);
      print(settingMap);
      return settingMap;
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<Result> updateAccountSetting(String key, String value) async {
    Response response;
    LogUtil.e(Api.API_UPDATE_ACCOUNT_SETTING, tag: _TAG);
    try {
      var data = {"key": key, "value": value};
      response = await httpUtil2.dio.post(Api.API_UPDATE_ACCOUNT_SETTING, data: data);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      print(json);
      return Result.fromJson(json);
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }
}
