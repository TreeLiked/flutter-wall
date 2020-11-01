import 'dart:core';

import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/util/http_util.dart';
import 'package:iap_app/util/string.dart';

class CommonApi {
  static const String _tag = "CommonApi";

  static Future<Result<List<String>>> blueQueryDataList(String url) async {
    Response response;
    Result<List<String>> res = Result();
    try {
      response = await httpUtil2.dio.get(url);
      Result<List<dynamic>> r = Result.fromJson(response.data);
      res = Result.fromResult(r);
      if (r.isSuccess && r.data != null) {
        List<dynamic> temp = r.data;
        List<String> values = temp.map((f) => f.toString()).toList();
        res.data = values;
      }
    } on DioError catch (e) {
      res.isSuccess = false;
      res.message = e.message;
      Api.formatError(e);
    }
    return res;
  }

  static Future<Map<String, dynamic>> getSplashAd() async {
    Response response;
    try {
      response = await httpUtil2.dio.get(Api.API_AD_SPLASH);
      var data = response.data;

      if (data is String) {
        LogUtil.e("getSplashAd, 无内容", tag: _tag);
        return null;
      }
      LogUtil.e("getSplashAd, $data}", tag: _tag);
      return data;
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }
}
