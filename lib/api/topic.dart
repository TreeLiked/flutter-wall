import 'dart:core' as prefix1;
import 'dart:core';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/topic/add_topic.dart';
import 'package:iap_app/model/topic/base_tr.dart';
import 'package:iap_app/model/topic/topic.dart';
import 'package:iap_app/util/http_util.dart';

class TopicApi {
  static Future<Result> createTopic(AddTopic addTopicParam) async {
    String url = Api.API_BASE_INF_URL + Api.API_TOPIC_CREATE;
    print("craete topic -> $url");
    try {
      Response response = await httpUtil.dio.post(url, data: addTopicParam.toJson());
      print(response);
      return Result.fromJson(Api.convertResponse(response.data));
    } on DioError catch (e) {
      String error = Api.formatError(e);
      Result r = new Result();
      r.isSuccess = false;
      r.message = error;
      return r;
    }
  }

  static Future<List<Topic>> queryTopics(int currentPage) async {
    String url = Api.API_BASE_INF_URL + Api.API_TOPIC_BATCH_QUERY;
    print(url);
    Response response;
    try {
      response = await httpUtil.dio.get(url + "?currentPage=$currentPage");
      Map<String, dynamic> json = Api.convertResponse(response.data);
      bool success = json["isSuccess"];
      if (success) {
        Map<String, dynamic> pageData = json["data"];
        List<dynamic> jsonData = pageData["data"];
        if (jsonData == null || jsonData.length <= 0) {
          return [];
        }
        List<Topic> topicList = jsonData.map((m) {
          return Topic.fromJson(m);
        }).toList();
        return topicList;
      }
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<Topic> queryTopicById(int topicId) async {
    String url = Api.API_BASE_INF_URL + Api.API_TOPIC_SINGLE_QUERY + "?tId=$topicId";
    print(url);
    Response response;
    try {
      response = await httpUtil.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      print(json);
      if (json['isSuccess'] == true) {
        dynamic jsonData = json["data"];
        return Topic.fromJson(jsonData);
      }
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<Result> modTopicStatus(int topicId, bool close) async {
    String url = Api.API_BASE_INF_URL + Api.API_TOPIC_STATUS_MOD + "?tId=$topicId" ;
    print("mod topic  status-> $url");
    try {
      Response response =
          await httpUtil.dio.post(url, data: {"tId": topicId, "acId": Application.getAccountId});
      print(response);
      return Result.fromJson(Api.convertResponse(response.data));
    } on DioError catch (e) {
      String error = Api.formatError(e);
      Result r = new Result();
      r.isSuccess = false;
      r.message = error;
      return r;
    }
  }

  static Future<List<MainTopicReply>> queryTopicMainReplies(int topicId, int currentPage, int pageSize,
      {String order = BaseTopicReply.QUERY_ORDER_HOT}) async {
    String url = Api.API_BASE_INF_URL + Api.API_TOPIC_REPLY_SINGLE_QUERY;
    print(url);
    var data = {"topicId": topicId, "currentPage": currentPage, "pageSize": pageSize, "order": order};
    Response response;
    try {
      response = await httpUtil.dio.post(url, data: data);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      print(json);
      bool success = json["isSuccess"];
      if (success) {
        Map<String, dynamic> pageData = json["data"];
        List<dynamic> jsonData = pageData["data"];
        if (jsonData == null || jsonData.length <= 0) {
          return [];
        }
        List<MainTopicReply> topicReplyList = jsonData.map((m) {
          return MainTopicReply.fromJson(m);
        }).toList();

        topicReplyList.forEach((m) {
          print("${m.praised}");
        });
        return topicReplyList;
      }
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<List<SubTopicReply>> queryTopicSubReplies(
      int topicId, int refId, int currentPage, int pageSize,
      {String order = BaseTopicReply.QUERY_ORDER_TIME}) async {
    String url = Api.API_BASE_INF_URL + Api.API_TOPIC_REPLY_SUB_QUERY;
    print(url);
    var data = {
      "topicId": topicId,
      "refId": refId,
      "currentPage": currentPage,
      "pageSize": pageSize,
      "order": order
    };
    Response response;
    try {
      response = await httpUtil.dio.post(url, data: data);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      print(json);
      bool success = json["isSuccess"];
      if (success) {
        Map<String, dynamic> pageData = json["data"];
        List<dynamic> jsonData = pageData["data"];
        if (jsonData == null || jsonData.length <= 0) {
          return [];
        }
        List<SubTopicReply> topicReplyList = jsonData.map((m) {
          return SubTopicReply.fromJson(m);
        }).toList();

        topicReplyList.forEach((m) {
          print("${m.praised}");
        });
        return topicReplyList;
      }
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<Result> addReply(int topicId, int refId, bool child, String tarAccountId, String body) async {
    if (topicId == null ||
        refId == null ||
        child == null ||
        tarAccountId == null ||
        body == null ||
        body.trim().length == 0) {
      Result r = new Result();
      r.isSuccess = false;
      r.message = "回复错误";
      return r;
    }
    var data = {
      "topicId": topicId,
      "refId": refId,
      "child": child,
      "tarAccId": tarAccountId,
      "body": body,
      "sentTime": DateUtil.formatDate(DateTime.now())
    };

    String url = Api.API_BASE_INF_URL + Api.API_TOPIC_ADD_REPLY;
    print(url);
    Response response;
    try {
      response = await httpUtil.dio.post(url, data: data);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      return Result.fromJson(json);
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<Result> modTopicPraiseStatus(int replyId, bool praise) async {
    String url = Api.API_BASE_INF_URL +
        (praise ? Api.API_TOPIC_REPLY_PRAISE : Api.API_TOPIC_REPLY_CANCEL_PRAISE) +
        "?replyId=$replyId";
    print(url);
    Response response;
    try {
      response = await httpUtil.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      return Result.fromJson(json);
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }








  //   static Future<Result> modPraise() async {
  //   print(Api.API_BASE_URL + Api.API_TWEET_REPLY_CREATE);

  //   Response response = await httpUtil.dio.post(
  //       Api.API_BASE_URL + Api.API_TWEET_REPLY_CREATE,
  //       data: reply.toJson());
  //   String jsonTemp = prefix0.json.encode(response.data);
  //   Map<String, dynamic> json = prefix0.json.decode(jsonTemp);
  //   return Result.fromJson(json);
  // }



}
