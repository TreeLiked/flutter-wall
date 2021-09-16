import 'dart:core' as prefix1;
import 'dart:core';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/model/account/circle_account.dart';
import 'package:iap_app/model/circle/circle.dart';
import 'package:iap_app/model/circle/circle_tweet.dart';
import 'package:iap_app/model/circle_query_param.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/http_util.dart';

class CircleApi {
  static const String TAG = "CircleApi";

  static String localAccountToken = SpUtil.getString(SharedConstant.LOCAL_ACCOUNT_TOKEN);

  static Future<List<Circle>> queryCircles(CircleQueryParam param) async {
    String url = Api.API_CIRCLE_INDEX_LIST;
    Response response;
    try {
      response = await httpUtil.dio.post(url, data: param.toJson());
      Map<String, dynamic> json = Api.convertResponse(response.data);
      List<dynamic> jsonData = json["data"];
      if (CollectionUtil.isListEmpty(jsonData)) {
        return new List<Circle>();
      }
      List<Circle> tweetList = jsonData.map((m) => Circle.fromJson(m)).toList();
      LogUtil.e("------queryCircles------, : ${tweetList.map((e) => e.id)}", tag: TAG);

      return tweetList;
    } on DioError catch (e) {
      Api.formatError(e, pop: false);
    }
    return [];
  }

  static Future<List<Circle>> queryUserCircles() async {
    String url = Api.API_CIRCLE_LIST_ME;
    Response response;
    try {
      response = await httpUtil.dio.get(url);
      List<dynamic> jsonData = response.data;
      if (CollectionUtil.isListEmpty(jsonData)) {
        return <Circle>[];
      }
      List<Circle> tweetList = jsonData.map((m) => Circle.fromJson(m)).toList();
      return tweetList;
    } on DioError catch (e) {
      Api.formatError(e, pop: false);
    }
    return [];
  }

  static Future<Circle> queryCircleDetail(int circleId) async {
    String url = Api.API_CIRCLE_QUERY_SINGLE_DETAIL;

    Response response;
    try {
      response = await httpUtil.dio.get(url, queryParameters: {
        "cId": circleId,
      });
      Map<String, dynamic> json = Api.convertResponse(response.data);

      Circle circle = Circle.fromJson(json);
      LogUtil.e("------queryCircleDetail------, : ${circle.toJson()}", tag: TAG);
      return circle;
    } on DioError catch (e) {
      Api.formatError(e, pop: false);
    }
    return null;
  }

  static Future<Map<String, dynamic>> pushCircle(Circle circle) async {
    Result r;
    try {
      Response response = await httpUtil.dio.post(Api.API_CIRCLE_CREATE, data: circle.toJson());
      return Api.convertResponse(response.data);
    } on DioError catch (e) {
      String error = Api.formatError(e);
      r = Api.genErrorResult(error);
    }
    return r.toJson();
  }

  /// ---------- 与账户相关联 -----------
  static Future<Result> applyJoinCircle(int circleId, {bool reApply = false}) async {
    Response response;
    Result r;
    try {
      response = await httpUtil.dio
          .get(Api.API_CIRCLE_APPLY_JOIN, queryParameters: {"cId": circleId, "retry": reApply});
      Map<String, dynamic> json = Api.convertResponse(response.data);
      r = Result.fromJson(json);
    } on DioError catch (e) {
      r = Api.genErrorResult(Api.formatError(e));
    }
    return r;
  }

  static Future<Result> handleCircleApply(int approvalId, int msgId, bool agree) async {
    Response response;
    Result r;
    try {
      response = await httpUtil.dio.get(Api.API_CIRCLE_APPLY_HANDLE,
          queryParameters: {"approvalId": approvalId, "msgId": msgId, "yn": agree});
      Map<String, dynamic> json = Api.convertResponse(response.data);
      r = Result.fromJson(json);
    } on DioError catch (e) {
      r = Api.genErrorResult(Api.formatError(e));
    }
    return r;
  }

  static Future<List<CircleAccount>> queryCircleAccounts(
      int circleId, String nickLike, PageParam param) async {
    Response response;
    Map<String, dynamic> data = {
      "circleId": circleId,
      "nickLike": nickLike,
      "param": param,
    };
    try {
      response = await httpUtil.dio.post(Api.API_CIRCLE_ACCOUNT_LIST, data: data);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      List<dynamic> jsonData = json["data"];
      if (CollectionUtil.isListEmpty(jsonData)) {
        return [];
      }
      List<CircleAccount> accList = jsonData.map((m) => CircleAccount.fromJson(m)).toList();
      LogUtil.e("------queryCircleAccounts------, : ${accList.map((e) => e.id)}", tag: TAG);
      return accList;
    } on DioError catch (e) {
      Api.formatError(e, pop: false);
    }
    return [];
  }

  static Future<CircleAccount> querySingleCircleAccount(int circleId, String accId) async {
    Response response;
    try {
      response = await httpUtil.dio
          .get(Api.API_CIRCLE_ACCOUNT_SINGLE, queryParameters: {"cId": circleId, "aId": accId});
      Map<String, dynamic> json = Api.convertResponse(response.data);
      if (CollectionUtil.isMapEmpty(json)) {
        return null;
      }
      return CircleAccount.fromJson(json);
    } on DioError catch (e) {
      Api.formatError(e, pop: false);
    }
    return null;
  }

  static Future<Result> updateUserRole(int circleId, String targetAccId, CircleAccountRole targetRole) async {
    Response response;
    try {
      String role = targetRole.toString().substring(targetRole.toString().indexOf('.') + 1);
      response = await httpUtil.dio.post(Api.API_CIRCLE_UPDATE_ROLE,
          data: {"circleId": circleId, "targetAccId": targetAccId, "targetAccRole": role});
      Map<String, dynamic> json = Api.convertResponse(response.data);
      if (CollectionUtil.isMapEmpty(json)) {
        return null;
      }
      return Result.fromJson(json);
    } on DioError catch (e) {
      return Api.genErrorResult(Api.formatError(e, pop: false));
    }
  }

  /// tweet rel
  static Future<Map<String, dynamic>> pushTweet(CircleTweet tweet) async {
    Result r;
    try {
      Response response = await httpUtil.dio.post(Api.API_CIRCLE_TWEET_CRATE, data: tweet.toJson());
      return Api.convertResponse(response.data);
    } on DioError catch (e) {
      String error = Api.formatError(e);

      r = Api.genErrorResult(error);
    }
    return r.toJson();
  }

  static Future<List<CircleTweet>> queryTweets(int sortType, int circleId, PageParam param) async {
    String url = Api.API_CIRCLE_TWEET_LIST;
    Response response;
    Map<String, dynamic> args = {
      "orgId": Application.getOrgId,
      "circleId": circleId,
      "currentPage": param.currentPage,
      "pageSize": param.pageSize,
      "sortType": sortType
    };
    print(args);
    try {
      response = await httpUtil.dio.post(url, data: args);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      List<dynamic> jsonData = json["data"];
      if (CollectionUtil.isListEmpty(jsonData)) {
        return [];
      }
      List<CircleTweet> tweetList = jsonData.map((m) => CircleTweet.fromJson(m)).toList();
      LogUtil.e("------queryCircleTweets------, : ${tweetList.map((e) => e.id)}", tag: TAG);
      return tweetList;
    } on DioError catch (e) {
      Api.formatError(e, pop: false);
    }
    return [];
  }
}
