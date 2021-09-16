import 'dart:core';

import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/util/collection.dart';
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

  static Future<int> getAlertCount(MessageType msgType) async {
    Response response;
    try {
      String type = msgType.toString().substring(msgType.toString().indexOf('.') + 1);
      response = await httpUtil.dio.get(Api.API_MSG_CNT, queryParameters: {"t": type});
      Map<String, dynamic> json = Api.convertResponse(response.data);
      if (CollectionUtil.isMapEmpty(json)) {
        return -1;
      }
      Result r = Result.fromJson(json);
      if (r.isSuccess) {
        return r.data;
      }
      LogUtil.e("getAlertCount error, ${r.toJson()}", tag: _tag);
      return -1;
    } on DioError catch (e) {
      Api.formatError(e, pop: false);
      return -1;
    }
  }
}
