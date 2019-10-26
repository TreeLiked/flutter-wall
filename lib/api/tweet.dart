import 'dart:convert' as prefix0;
import 'dart:core' as prefix1;
import 'dart:core';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:iap_app/model/hot_tweet.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/util/api.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/http_util.dart';

class TweetApi {
  static Future<List<BaseTweet>> queryTweets(PageParam param) async {
    print(Api.API_BASE_URL + Api.API_TWEET_QUERYY);
    print(param.toJson().toString() +
        "=====================================================");
    Response response = await httpUtil.dio
        .post(Api.API_BASE_URL + Api.API_TWEET_QUERYY, data: param.toJson());
    String jsonTemp = prefix0.json.encode(response.data);
    Map<String, dynamic> json = prefix0.json.decode(jsonTemp);
    List<dynamic> jsonData = json["data"];
    if (CollectionUtil.isListEmpty(jsonData)) {
      return new List<BaseTweet>();
    }
    List<BaseTweet> tweetList =
        jsonData.map((m) => BaseTweet.fromJson(m)).toList();
    return tweetList;
  }

  static Future<Result> pushTweet(BaseTweet tweet) async {
    print(Api.API_BASE_URL + Api.API_TWEET_QUERYY);
    Response response = await httpUtil.dio
        .post(Api.API_BASE_URL + Api.API_TWEET_CREATE, data: tweet.toJson());

    print('----------------------------------------------');
    String jsonTemp = prefix0.json.encode(response.data);
    prefix1.print(jsonTemp);
    return Result();
  }

  static Future<Result> pushReply(TweetReply reply, int tweetId) async {
    print(Api.API_BASE_URL + Api.API_TWEET_REPLY_CREATE);

    Response response = await httpUtil.dio.post(
        Api.API_BASE_URL + Api.API_TWEET_REPLY_CREATE + '?tId=$tweetId',
        data: reply.toJson());
    print('----------------------------------------------${response.data}');
    String jsonTemp = prefix0.json.encode(response.data);
    Map<String, dynamic> json = prefix0.json.decode(jsonTemp);
    return Result.fromJson(json);
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

  static Future<HotTweet> queryOrghHotTweets(int hot) async {
    print(Api.API_BASE_URL + Api.API_TWEET_HOT_QUERYY);
    Response response = await httpUtil.dio
        .get(Api.API_BASE_URL + Api.API_TWEET_HOT_QUERYY + '?orgId=$hot');
    String jsonTemp = prefix0.json.encode(response.data);
    Map<String, dynamic> json = prefix0.json.decode(jsonTemp);
    return HotTweet.fromJson(json);
  }

  static Future<HotTweet> queryPraise(int tweetId) async {
    print(Api.API_BASE_URL + Api.API_TWEET_HOT_QUERYY);
    Response response = await httpUtil.dio
        .get(Api.API_BASE_URL + Api.API_TWEET_HOT_QUERYY + '?tId=$tweetId');
    String jsonTemp = prefix0.json.encode(response.data);
    Map<String, dynamic> json = prefix0.json.decode(jsonTemp);
    return HotTweet.fromJson(json);
  }
}
