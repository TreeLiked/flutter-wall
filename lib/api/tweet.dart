import 'dart:convert' as prefix0;
import 'dart:core' as prefix1;
import 'dart:core';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/util/api.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/http_util.dart';

class TweetApi {
  static Future<List<BaseTweet>> queryTweets(PageParam param) async {
    print(Api.API_BASE_URL + Api.API_TWEET_QUERYY);
    print(param.toJson());
    Response response = await httpUtil.dio.get(
        Api.API_BASE_URL + Api.API_TWEET_QUERYY,
        queryParameters: param.toJson());
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
}
