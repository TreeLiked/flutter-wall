import 'dart:core' as prefix1;
import 'dart:core';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/circle/circle.dart';
import 'package:iap_app/model/hot_tweet.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/http_util.dart';
import 'package:iap_app/util/string.dart';

class DictApi {
  static const String TAG = "DictApi";

  static String localAccountToken = SpUtil.getString(SharedConstant.LOCAL_ACCOUNT_TOKEN);

  static Future<List<String>> queryTweetCommentSpeaks(int tweetId) async {
    String url = Api.API_DICT_PREFIX + '/tcmtsp';
    Response response;
    try {
      LogUtil.e("------  queryTweetCommentSpeaks  ------ start", tag: TAG);
      response = await httpUtil.dio.get(url, queryParameters: {
        "tweetId": tweetId,
      });
      List<dynamic> data = (response.data);

      List<String> speaks = data.map((m) => m.toString()).toList();
      LogUtil.e("------  queryTweetCommentSpeaks  ------: $speaks", tag: TAG);

      return speaks;
    } on DioError catch (e) {
      Api.formatError(e, pop: false);
    }
    return [];
  }
}
