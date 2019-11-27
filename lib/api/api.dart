import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:iap_app/global/global_config.dart';

class Api {
  static const String API_BASE = "http://treeliked.com";

  //  static const String API_BASE =
  // GlobalConfig.inProduction ? "http://treeliked.com" : "http://127.0.0.1";

  // static const String API_BASE_URL = "http://127.0.0.1";
  // static const String API_BASE = "http://192.168.1.199";
  // static const String API_BASE2 = "http://127.0.0.1";
  // static const String API_BASE2 = "http://192.168.10.63";

  static const String API_BASE_INF_URL = API_BASE + ":8088/iap/api";
  static const String API_BASE_MEMBER_URL = API_BASE + ":9001/trms/api";

  // tweet
  static const String API_TWEET_CREATE = "/tweet/add.do";
  static const String API_TWEET_QUERYY = "/tweet/list.json";
  static const String API_TWEET_MEDIA_UPLOAD_REQUEST =
      "/tweet/media/generate.json";

  // tweet operation
  static const String API_TWEET_OPERATION = "/tweet/opt/opt.do";
  static const String API_TWEET_QUERY_SINGLE = "/tweet/opt/querySingle.json";

  // tweet praise query
  static const String API_TWEET_PRAISE_QUERY = "/tweet/praise/list.json";
  static const String API_TWEET_HOT_QUERYY = "/tweet/listHot.json";

  // tweet reply
  static const String API_TWEET_REPLY_CREATE = "/tweet/reply/add.do";
  static const String API_TWEET_REPLY_QUERY = "/tweet/reply/list.json";

  // sms
  static const String API_SEND_VERIFICATION_CODE =
      API_BASE_INF_URL + "/sms/send.do";
  static const String API_CHECK_VERIFICATION_CODE =
      API_BASE_INF_URL + "/sms/check.do";

  // member start --------
  static const String API_QUERY_ACCOUNT =
      API_BASE_MEMBER_URL + "/account/getAccInfo.json";

  static const String API_ACCOUNT_MOD_BASIC =
      API_BASE_MEMBER_URL + "/account/edit/basic.do";

  static const String API_CHECK_NICK_REPEAT =
      API_BASE_MEMBER_URL + "/account/nickCheck.do";

  static const String API_REGISTER_BY_PHONE =
      API_BASE_MEMBER_URL + "/auth/rbp.do";

  static const String API_LOGIN_BY_PHONE = API_BASE_MEMBER_URL + "/auth/lbp.do";

  // university
  static const String API_BLUR_QUERY_UNIVERSITY =
      API_BASE_INF_URL + "/un/blurQuery.json";

  static Map<String, dynamic> convertResponse(Object reponseData) {
    String jsonTemp = json.encode(reponseData);
    return json.decode(jsonTemp);
  }

  static void formatError(DioError e) {
    print(e);
    if (e.type == DioErrorType.CONNECT_TIMEOUT) {
      // It occurs when url is opened timeout.
      print("连接超时");
    } else if (e.type == DioErrorType.SEND_TIMEOUT) {
      // It occurs when url is sent timeout.
      print("请求超时");
    } else if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
      //It occurs when receiving timeout
      print("响应超时");
    } else if (e.type == DioErrorType.RESPONSE) {
      // When the server response, but with a incorrect status, such as 404, 503...
      print("出现异常");
    } else if (e.type == DioErrorType.CANCEL) {
      // When the request is cancelled, dio will throw a error with this type.
      print("请求取消");
    } else {
      //DEFAULT Default error type, Some other Error. In this case, you can read the DioError.error if it is not null.
      print("未知错误");
    }
  }
}
