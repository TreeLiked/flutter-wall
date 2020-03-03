import 'dart:core';

import 'package:dio/dio.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/api/member.dart';
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

  static Future<University> queryUnis(String accountToken) async {
    Response response;
    String url = Api.API_QUERY_ORG;
    try {
      response = await httpUtil2.dio.post(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      dynamic json2 = json["data"];
      return University.fromJson(json2);
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }
}
