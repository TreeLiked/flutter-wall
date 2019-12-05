import 'dart:core';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/account_edit_param.dart';
import 'package:iap_app/model/account/account_profile.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/util/http_util.dart';

class MemberApi {
  static Future<Account> getMyAccount(String token) async {
    print(Api.API_QUERY_ACCOUNT + '-------------------');
    Response response;
    try {
      if (httpUtil2.options.headers.containsKey("Authorization")) {
        httpUtil2.options.headers.update('Authorization', (_) => token);
      } else {
        httpUtil2.options.headers.putIfAbsent('Authorization', () => token);
      }
      response = await httpUtil2.dio.post(Api.API_QUERY_ACCOUNT);
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

  static Future<Account> getAccountProfile(String accountId) async {
    print(Api.API_QUERY_ACCOUNT_PROFILE + '-------------------');
    String token = SpUtil.getString(SharedConstant.LOCAL_ACCOUNT_TOKEN);
    Response response;
    try {
      if (httpUtil2.options.headers.containsKey("Authorization")) {
        httpUtil2.options.headers.update('Authorization', (_) => token);
      } else {
        httpUtil2.options.headers.putIfAbsent('Authorization', () => token);
      }
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

  static Future<Result> modAccount(AccountEditParam param) async {
    String token = SpUtil.getString(SharedConstant.LOCAL_ACCOUNT_TOKEN);
    Response response;
    try {
      if (httpUtil2.options.headers.containsKey("Authorization")) {
        httpUtil2.options.headers.update('Authorization', (_) => token);
      } else {
        httpUtil2.options.headers.putIfAbsent('Authorization', () => token);
      }
      response =
          await httpUtil2.dio.post(Api.API_ACCOUNT_MOD_BASIC, data: param);
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
    print(url);
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

  static Future<Result> checkVerificationCode(
      String phone, String vCode) async {
    Response response;
    String url = Api.API_CHECK_VERIFICATION_CODE + "?p=$phone&c=$vCode";
    print(url);
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
    print(url);
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

  static Future<Result> register(
      String phone, String nick, String avatarUrl, int orgId) async {
    Response response;
    String url = Api.API_REGISTER_BY_PHONE;
    var data = {
      'phone': phone,
      'nick': nick,
      'avatarUrl': avatarUrl,
      'orgId': orgId,
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

  static Future<Result> login(String phone) async {
    Response response;
    String url = Api.API_LOGIN_BY_PHONE;
    print(url);
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
}
