import 'dart:core';

import 'package:dio/dio.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/account_edit_param.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/util/http_util.dart';

class MemberApi {
  static Future<Account> getMyAccount(String storageToken) async {
    print(Api.API_QUERY_ACCOUNT + '-------------------');
    Response response;
    try {
      httpUtil2.options.headers.putIfAbsent(
          'Authorization',
          () =>
              "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhY2NvdW50SWQiOiJlNWU1ZDdlMjAwNmM0Nzg4YjZiMjQ1MDlkZmU0ODFiMyIsImlzcyI6ImF1dGgwIiwiZXhwIjoxNTc2MjI2MTY5fQ.47TZJ2819wsOAFEgDK_2nzDgvCAmTWpW8eVvUuqlCJU");
      response = await httpUtil2.dio.post(Api.API_QUERY_ACCOUNT);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      print(json);
      dynamic json2 = json["data"];
      Account account = Account.fromJson(json2);
      return account;
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<Result> modAccount(AccountEditParam param) async {
    Response response;
    try {
      httpUtil2.options.headers.putIfAbsent(
          'Authorization',
          () =>
              "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhY2NvdW50SWQiOiJlNWU1ZDdlMjAwNmM0Nzg4YjZiMjQ1MDlkZmU0ODFiMyIsImlzcyI6ImF1dGgwIiwiZXhwIjoxNTc2MjI2MTY5fQ.47TZJ2819wsOAFEgDK_2nzDgvCAmTWpW8eVvUuqlCJU");
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
}
