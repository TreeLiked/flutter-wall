import 'dart:core';

import 'package:dio/dio.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/util/http_util.dart';

class CommonApi {
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
      return response.data;
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }
}
