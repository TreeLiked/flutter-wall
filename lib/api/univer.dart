import 'dart:core';

import 'package:dio/dio.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/model/account/account_edit_param.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/university.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/http_util.dart';

class UniversityApi {
  static Future<List<University>> blurQueryUnis(String blurStr) async {
    Response response;
    String url = Api.API_BLUR_QUERY_UNIVERSITY + "?n=$blurStr";
    print(url);
    try {
      response = await httpUtil2.dio.get(url);
      List<dynamic> temp = response.data;
      print(temp);
      if (CollectionUtil.isListEmpty(temp)) {
        return [];
      }
      return temp.map((f) => University.fromJson(f)).toList();
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }
}
