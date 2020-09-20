import 'dart:core';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/university.dart';
import 'package:iap_app/model/version/pub_v.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/http_util.dart';

class VCAPI {
  /// 检查当前的版本是否仍然可用
  static Future<Result> checkThisVersionAvailable() async {
    bool ios = Platform.isIOS;
    Response response;
    String url = Api.API_CHECK_AVAILABLE +
        "?versionId=${ios ? SharedConstant.VERSION_ID_IOS : SharedConstant.VERSION_ID_ANDROID}";
    print(url);
    try {
      response = await httpUtil.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      return Result.fromJson(json);
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<Result<PubVersion>> fetchLatestVersion() async {
    bool ios = Platform.isIOS;
    Response response;
    String url = Api.API_CHECK_UPDATE +
        "?versionId=${ios ? SharedConstant.VERSION_ID_IOS : SharedConstant.VERSION_ID_ANDROID}&platform=${ios ? 'IOS' : 'ANDROID'}";
    print(url);
    String error;
    try {
      response = await httpUtil.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      print(json.toString());
      bool success = json["isSuccess"];
      Result<PubVersion> r = new Result();
      dynamic json2 = json["data"];
      if (success) {
        // 当前版本可用
        r.isSuccess = true;
        if (json2 != null) {
          // 如果data不为空，则当前版本不是最新版
          r.data = PubVersion.fromJson(json2);
        }
      } else {
        // 当前版本不可用
        r.isSuccess = false;
        if (json2 == null) {
          return r;
        }
        PubVersion pubVersion = PubVersion.fromJson(json2);
        r.data = pubVersion;
      }
      return r;
    } on DioError catch (e) {
      error = Api.formatError(e);
    }
    return Api.genErrorResult(error);
  }
}
