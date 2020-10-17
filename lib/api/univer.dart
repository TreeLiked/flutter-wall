import 'dart:core';

import 'package:dio/dio.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/model/account/school/institute.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/university.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/http_util.dart';

class UniversityApi {
  static Future<Result<List<Institute>>> queryUniInstitutes() async {
    Response response;
    String url = Api.API_QUERY_INSTITUTE;
    print(url);
    Result<List<Institute>> res = Result();
    try {
      response = await httpUtil2.dio.get(url);
      Result<List<dynamic>> r = Result.fromJson(response.data);
      res = Result.fromResult(r);
      if (r.isSuccess && r.data != null) {
        List<dynamic> temp = r.data;
        List<Institute> ins = temp.map((f) => Institute.fromJson(f)).toList();
        res.data = ins;
      }
    } on DioError catch (e) {
      res.isSuccess = false;
      res.message = e.message;
      Api.formatError(e);
    }
    return res;
  }

  static Future<List<University>> blurQueryUnis(String blurStr) async {
    Response response;
    String url = Api.API_BLUR_QUERY_UNIVERSITY + "?n=$blurStr";
    print(url);
    try {
      response = await httpUtil2.dio.get(url);
      List<dynamic> temp = response.data;
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
