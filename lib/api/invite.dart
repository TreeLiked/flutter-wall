import 'dart:core';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/university.dart';
import 'package:iap_app/model/version/pub_v.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/http_util.dart';

class InviteAPI {
  static Future<Result> checkIsInInvitation() async {
    Response response;
    String url = Api.API_IS_ON_INVITATION;
    print(url);
    Result r;
    try {
      response = await httpUtil.dio.get(Api.API_IS_ON_INVITATION);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      return Result.fromJson(json);
    } on DioError catch (e) {
      r = new Result();
      r.isSuccess = false;
      r.message = TextConstant.TEXT_SERVICE_ERROR;
      Api.formatError(e);
    }
    return r;
  }

  static Future<Result> checkCodeValid(String code) async {
    Response response;
    String url = Api.API_CHECK_INVITATION_CODE + '?c=$code';
    print(url);
    Result r;
    try {
      response = await httpUtil.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      return Result.fromJson(json);
    } on DioError catch (e) {
      r = new Result();
      r.isSuccess = false;
      r.message = TextConstant.TEXT_SERVICE_ERROR;
      Api.formatError(e);
    }
    return r;
  }

  static Future<Map<String, dynamic>> checkMyInvitation() async {
    Response response;
    String url = Api.API_MY_INVITATION;
    print(url);
    try {
      response = await httpUtil2.dio.get(Api.API_MY_INVITATION);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      print(json);
      print('-------------------------------');
      if (json['data'] != null) {
        return json['data'];
      }
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }
}
