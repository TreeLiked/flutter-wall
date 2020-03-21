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
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/http_util.dart';
import 'package:iap_app/util/string.dart';

class UnlikeAPI {
  static const String UNLIKE_ACCOUNT_API = Api.API_BASE_INF_URL + "/unlikeAcc";
  static const String UNLIKE_ACCOUNT_ADD = UNLIKE_ACCOUNT_API + "/add.do";

  static Future<Result> unlikeAccount(String targetAccountId) async {
    if (StringUtil.isEmpty(targetAccountId)) {
      return Result(isSuccess: false);
    }

    print(UNLIKE_ACCOUNT_ADD);
    Response response;
    try {
      response = await httpUtil.dio.post(UNLIKE_ACCOUNT_ADD, data: targetAccountId);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      return Result.fromJson(json);
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }
}
