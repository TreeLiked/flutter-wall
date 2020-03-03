import 'dart:convert';
import 'dart:core' as prefix1;
import 'dart:core';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/hot_tweet.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/topic/add_topic.dart';
import 'package:iap_app/model/topic/base_tr.dart';
import 'package:iap_app/model/topic/topic.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/http_util.dart';
import 'package:iap_app/util/string.dart';

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

  static Future<List<BaseTweet>> queryAccountTweets(PageParam pageParam, String passiveAccountId,
      {bool needAnonymous = true}) async {
    String requestUrl = Api.API_BASE_INF_URL + Api.API_TWEET_QUERY;
    Response response;
    var param = {
      'currentPage': pageParam.currentPage,
      'pageSize': pageParam.pageSize,
      'accountIds': [passiveAccountId],
      'needAnonymous': needAnonymous
    };
    try {
      response = await httpUtil.dio.post(requestUrl, data: param);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      List<dynamic> jsonData = json["data"];
      if (CollectionUtil.isListEmpty(jsonData)) {
        return new List<BaseTweet>();
      }
      List<BaseTweet> tweetList = jsonData.map((m) => BaseTweet.fromJson(m)).toList();
      return tweetList;
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<Result> deleteAccountTweets(String accountId, int tweetId) async {
    if (StringUtil.isEmpty(accountId)) {
      return Result(isSuccess: false);
    }
    String requestUrl =
        Api.API_TWEET_DELETE + "?" + SharedConstant.ACCOUNT_ID_IDENTIFIER + "=$accountId&tId=$tweetId";
    print(requestUrl);
    Response response;
    try {
      response = await httpUtil.dio.post(requestUrl);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      return Result.fromJson(json);
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<Map<String, dynamic>> requestUploadMediaLink(List<String> fileSuffixes, String type) async {
    StringBuffer buffer = new StringBuffer();
    fileSuffixes.forEach((f) => buffer.write("&suffix=$f"));
    String url = Api.API_BASE_INF_URL +
        Api.API_TWEET_MEDIA_UPLOAD_REQUEST +
        "?type=$type&${SharedConstant.ACCOUNT_ID_IDENTIFIER}=" +
        Application.getAccountId +
        buffer.toString();

    print(url);
    Response response = await httpUtil.dio.get(url);
    Map<String, dynamic> json = Api.convertResponse(response.data);
    return json;
  }

  static Future<Result> pushReply(TweetReply reply, int tweetId) async {
    print(Api.API_BASE_INF_URL + Api.API_TWEET_REPLY_CREATE);

    Response response = await httpUtil.dio
        .post(Api.API_BASE_INF_URL + Api.API_TWEET_REPLY_CREATE + '?tId=$tweetId', data: reply.toJson());
    Map<String, dynamic> json = Api.convertResponse(response.data);
    return Result.fromJson(json);
  }

  static Future<void> operateTweet(int tweetId, String type, bool positive) async {
    var param = {'tweetId': tweetId, 'accountId': Application.getAccountId, 'type': type, 'valid': positive};
    String url = Api.API_BASE_INF_URL + Api.API_TWEET_OPERATION + '?acId=' + Application.getAccountId;
    print(url);
    httpUtil.dio.post(url, data: param);
  }

  static Future<List<TweetReply>> queryTweetReply(int tweetId, bool needSub) async {
    String url = Api.API_BASE_INF_URL + Api.API_TWEET_REPLY_QUERY + '?id=$tweetId&needSub=$needSub';
    print(url);
    try {
      Response response = await httpUtil.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      List<dynamic> jsonData = json["data"];
      if (CollectionUtil.isListEmpty(jsonData)) {
        return new List<TweetReply>();
      }
      List<TweetReply> replies = jsonData.map((m) => TweetReply.fromJson(m)).toList();
      return replies;
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<List<Account>> queryTweetPraise(int tweetId) async {
    var param = {
      'tweetIds': [tweetId],
      'type': 'PRAISE'
    };
    String url = Api.API_BASE_INF_URL + Api.API_TWEET_OPT_QUERY_SINGLE + '?acId=' + Application.getAccountId;
    print(url);
    try {
      Response response = await httpUtil.dio.post(url, data: param);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      List<dynamic> jsonData = json["data"];
      if (CollectionUtil.isListEmpty(jsonData)) {
        return new List<Account>();
      }
      List<Account> accounts = jsonData.map((m) => Account.fromJson(m)).toList();
      return accounts;
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

  static Future<HotTweet> queryOrgHotTweets(int orgId) async {
    try {
      String url =
          Api.API_BASE_INF_URL + Api.API_TWEET_HOT_QUERY + '?orgId=$orgId&acId=' + Application.getAccountId;
      Response response = await httpUtil.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      return HotTweet.fromJson(json);
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<HotTweet> queryPraise(int tweetId) async {
    print(Api.API_BASE_INF_URL + Api.API_TWEET_HOT_QUERY);
    Response response =
        await httpUtil.dio.get(Api.API_BASE_INF_URL + Api.API_TWEET_HOT_QUERY + '?tId=$tweetId');
    Map<String, dynamic> json = Api.convertResponse(response.data);
    return HotTweet.fromJson(json);
  }

}
