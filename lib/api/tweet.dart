import 'dart:convert' as prefix0;
import 'dart:core' as prefix1;
import 'dart:core';
import 'dart:ffi';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/hot_tweet.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/util/api.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/http_util.dart';

class TweetApi {
  // TODO 401 未认证检测
  static Future<List<BaseTweet>> queryTweets(
      PageParam param, String accountId) async {
    print(Api.API_BASE_URL + Api.API_TWEET_QUERYY);

    Response response = await httpUtil.dio.post(
        Api.API_BASE_URL + Api.API_TWEET_QUERYY + '?acId=$accountId',
        data: param.toJson());
    Map<String, dynamic> json = Api.convertResponse(response.data);
    List<dynamic> jsonData = json["data"];
    if (CollectionUtil.isListEmpty(jsonData)) {
      return new List<BaseTweet>();
    }
    List<BaseTweet> tweetList =
        jsonData.map((m) => BaseTweet.fromJson(m)).toList();
    return tweetList;
  }

  static Future<Map<String, dynamic>> pushTweet(BaseTweet tweet) async {
    print(Api.API_BASE_URL + Api.API_TWEET_QUERYY);
    Response response = await httpUtil.dio
        .post(Api.API_BASE_URL + Api.API_TWEET_CREATE, data: tweet.toJson());

    return Api.convertResponse(response.data);
  }

  static Future<Map<String, dynamic>> requestUploadMediaLink(
      List<String> fileSuffixes, String type) async {
    StringBuffer buffer = new StringBuffer();
    fileSuffixes.forEach((f) => buffer.write("&suffix=$f"));

    String url = Api.API_BASE_URL +
        Api.API_TWEET_MEDIA_UPLOAD_REQUEST +
        "?type=$type&${SharedConstant.ACCOUNT_ID_IDENTIFIER}=" +
        Application.getAccount.id +
        buffer.toString();

    print(url);
    Response response = await httpUtil.dio.get(url);
    Map<String, dynamic> json = Api.convertResponse(response.data);
    return json;
  }

  static Future<Result> pushReply(TweetReply reply, int tweetId) async {
    print(Api.API_BASE_URL + Api.API_TWEET_REPLY_CREATE);

    Response response = await httpUtil.dio.post(
        Api.API_BASE_URL + Api.API_TWEET_REPLY_CREATE + '?tId=$tweetId',
        data: reply.toJson());
    print('----------------------------------------------${response.data}');
    Map<String, dynamic> json = Api.convertResponse(response.data);
    return Result.fromJson(json);
  }

  static Future<void> operateTweet(
      int tweetId, String type, bool positive) async {
    var param = {
      'tweetId': tweetId,
      'accountId': Application.getAccount.id,
      'type': type,
      'valid': positive
    };
    String url = Api.API_BASE_URL +
        Api.API_TWEET_OPERATION +
        '?acId=' +
        Application.getAccount.id;
    print(url);
    httpUtil.dio.post(url, data: param);
  }

  static Future<List<TweetReply>> quertTweetReply(
      int tweetId, bool needSub) async {
    String url = Api.API_BASE_URL +
        Api.API_TWEET_REPLY_QUERY +
        '?id=$tweetId&needSub=$needSub';
    print(url);
    Response response = await httpUtil.dio.get(url);
    Map<String, dynamic> json = Api.convertResponse(response.data);
    List<dynamic> jsonData = json["data"];
    if (CollectionUtil.isListEmpty(jsonData)) {
      return new List<TweetReply>();
    }
    List<TweetReply> replies =
        jsonData.map((m) => TweetReply.fromJson(m)).toList();
    return replies;
  }

  static Future<List<Account>> quertTweetPraise(int tweetId) async {
    var param = {
      'tweetIds': [tweetId],
      'type': 'PRAISE'
    };
    String url = Api.API_BASE_URL +
        Api.API_TWEET_QUERY_SINGLE +
        '?acId=' +
        Application.getAccount.id;
    print(url);
    Response response = await httpUtil.dio.post(url, data: param);
    Map<String, dynamic> json = Api.convertResponse(response.data);
    List<dynamic> jsonData = json["data"];
    if (CollectionUtil.isListEmpty(jsonData)) {
      return new List<Account>();
    }
    List<Account> accounts = jsonData.map((m) => Account.fromJson(m)).toList();
    return accounts;
  }

  //   static Future<Result> modPraise() async {
  //   print(Api.API_BASE_URL + Api.API_TWEET_REPLY_CREATE);

  //   Response response = await httpUtil.dio.post(
  //       Api.API_BASE_URL + Api.API_TWEET_REPLY_CREATE,
  //       data: reply.toJson());
  //   print('----------------------------------------------${response.data}');
  //   String jsonTemp = prefix0.json.encode(response.data);
  //   Map<String, dynamic> json = prefix0.json.decode(jsonTemp);
  //   return Result.fromJson(json);
  // }

  static Future<HotTweet> queryOrghHotTweets(int orgId) async {
    String url = Api.API_BASE_URL +
        Api.API_TWEET_HOT_QUERYY +
        '?orgId=$orgId&acId=' +
        Application.getAccount.id;
    print(url + '----------------------------------');
    Response response = await httpUtil.dio.get(url);
    Map<String, dynamic> json = Api.convertResponse(response.data);
    return HotTweet.fromJson(json);
  }

  static Future<HotTweet> queryPraise(int tweetId) async {
    print(Api.API_BASE_URL + Api.API_TWEET_HOT_QUERYY);
    Response response = await httpUtil.dio
        .get(Api.API_BASE_URL + Api.API_TWEET_HOT_QUERYY + '?tId=$tweetId');
    Map<String, dynamic> json = Api.convertResponse(response.data);
    return HotTweet.fromJson(json);
  }
}
