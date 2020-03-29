import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/routes/fluro_navigator.dart';

class Api {
  static const bool devInf = false;
  static const bool devMem = false;
  static const String API_BASE_AL = "https://almond-donuts.iutr.tech";
  static const String API_BASE_TR = "https://member.iutr.tech";

  static const String API_BASE_INF_DEV = "http://192.168.31.235:8088";
  static const String API_BASE_MEM_DEV = "http://127.0.0.1:9001";

  static const String API_BASE_INF_URL = (devInf ? API_BASE_INF_DEV : API_BASE_AL) + "/iap/api";
  static const String API_BASE_MEMBER_URL = (devMem ? API_BASE_MEM_DEV : API_BASE_TR) + "/trms/api";

  // topic
  static const String API_TOPIC_CREATE = "/topic/addNormal.do";
  static const String API_TOPIC_STATUS_MOD = "/topic/close.do";
  static const String API_TOPIC_BATCH_QUERY = "/topic/listOfUni.json";
  static const String API_TOPIC_SINGLE_QUERY = "/topic/get.json";

  static const String API_TOPIC_REPLY_SINGLE_QUERY = "/topic/reply/list.json";
  static const String API_TOPIC_ADD_REPLY = "/topic/reply/add.do";
  static const String API_TOPIC_REPLY_SUB_QUERY = "/topic/reply/listSubs.json";

  static const String API_TOPIC_REPLY_PRAISE = "/topic/reply/praise.do";
  static const String API_TOPIC_REPLY_CANCEL_PRAISE = "/topic/reply/cancelPraise.do";

  // tweet
  static const String API_TWEET_CREATE = "/tweet/add.do";
  static const String API_TWEET_DELETE = API_BASE_INF_URL + "/tweet/d.do";
  static const String API_TWEET_QUERY_SIN = "/tweet/listSingle.json";
  static const String API_TWEET_QUERY = "/tweet/list.json";
  static const String API_TWEET_QUERY2 = "/tweet/listUni.json";
  static const String API_TWEET_MEDIA_UPLOAD_REQUEST = "/tweet/media/generate.json";

  // tweet operation
  static const String API_TWEET_OPERATION = "/tweet/opt/opt.do";
  static const String API_TWEET_OPT_QUERY_SINGLE = "/tweet/opt/querySingle.json";

  // tweet praise query
  static const String API_TWEET_PRAISE_QUERY = "/tweet/praise/list.json";
  static const String API_TWEET_HOT_QUERY = "/tweet/listHot.json";

  // tweet reply
  static const String API_TWEET_REPLY_CREATE = "/tweet/reply/add.do";
  static const String API_TWEET_REPLY_QUERY = "/tweet/reply/list.json";

  // sms
  static const String API_SEND_VERIFICATION_CODE = API_BASE_INF_URL + "/sms/send.do";
  static const String API_CHECK_VERIFICATION_CODE = API_BASE_INF_URL + "/sms/check.do";

  // member start --------
  static const String API_QUERY_ACCOUNT = API_BASE_MEMBER_URL + "/account/getAccInfo.json";

  static const String API_QUERY_ACCOUNT_PROFILE = API_BASE_MEMBER_URL + "/account/getProfileInfo.json";

  static const String API_QUERY_FILTERED_ACCOUNT_PROFILE = API_BASE_MEMBER_URL + "/account/getShowInfo.json";

  static const String API_QUERY_ACCOUNT_SETTING = API_BASE_MEMBER_URL + "/account/getSettings.json";

  static const String API_UPDATE_ACCOUNT_SETTING = API_BASE_MEMBER_URL + "/account/edit/setting.do";

  static const String API_ACCOUNT_MOD_BASIC = API_BASE_MEMBER_URL + "/account/edit/basic.do";

  static const String API_CHECK_NICK_REPEAT = API_BASE_MEMBER_URL + "/account/nickCheck.do";

  static const String API_REGISTER_BY_PHONE = API_BASE_MEMBER_URL + "/auth/rbp.do";

  static const String API_LOGIN_BY_PHONE = API_BASE_MEMBER_URL + "/auth/lbp.do";

  // university
  static const String API_BLUR_QUERY_UNIVERSITY = API_BASE_MEMBER_URL + "/un/blurQuery.json";

  static const String API_QUERY_ORG = API_BASE_MEMBER_URL + "/org/getAccUniversity.json";

  // device
  static const String API_UPDATE_DEVICE_INFO = API_BASE_INF_URL + "/device/update.do";
  static const String API_REMOVE_DEVICE_INFO = API_BASE_INF_URL + "/device/signOut.do";

  // notification message
  static const String API_MSG_LIST_INTERACTION = API_BASE_INF_URL + "/message/listInteractions.json";
  static const String API_MSG_LIST_SYSTEM = API_BASE_INF_URL + "/message/listSystems.json";
  static const String API_MSG_READ_ALL_INTERACTION = API_BASE_INF_URL + "/message/interactionsAllRead.do";
  static const String API_MSG_READ_ALL_SYSTEM = API_BASE_INF_URL + "/message/systemsAllRead.do";
  static const String API_MSG_READ_THIS = API_BASE_INF_URL + "/message/read.do";

  static const String API_MSG_INTERACTION_CNT = API_BASE_INF_URL + "/message/interactionAlertCount.json";
  static const String API_MSG_SYSTEM_CNT = API_BASE_INF_URL + "/message/systemAlertCount.json";

  static const String API_MSG_LATEST = API_BASE_INF_URL + "/message/latest.json";

  // version update

  static const String API_CHECK_UPDATE = API_BASE_INF_URL + "/version/checkUpdate";
  static const String API_CHECK_AVAILABLE = API_BASE_INF_URL + "/version/available";
  static const String API_AGREEMENT = "https://almond-donuts.iutr.tech/terms.html";
  static const String API_SHARE = "https://almond-donuts.iutr.tech/download.html";

  static Map<String, dynamic> convertResponse(Object responseData) {
    try {
      String jsonTemp = json.encode(responseData);
      return json.decode(jsonTemp);
    } on Error {}
    return null;
  }

  static String formatError(DioError e) {
    print(e);
    NavigatorUtils.goBack(Application.context);
    if (e.type == DioErrorType.CONNECT_TIMEOUT) {
      // It occurs when url is opened timeout.
      print("连接超时");
      return "连接超时";
    } else if (e.type == DioErrorType.SEND_TIMEOUT) {
      // It occurs when url is sent timeout.
      print("请求超时");
      return "请求超时";
    } else if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
      //It occurs when receiving timeout
      print("响应超时");
      return "响应超时";
    } else if (e.type == DioErrorType.RESPONSE) {
      // When the server response, but with a incorrect status, such as 404, 503...
      print("出现异常$e");
      return "出现异常";
    } else if (e.type == DioErrorType.CANCEL) {
      // When the request is cancelled, dio will throw a error with this type.
      print("请求取消");
      return "请求取消";
    } else {
      //DEFAULT Default error type, Some other Error. In this case, you can read the DioError.error if it is not null.
      print("未知错误$e");
      return "未知错误";
    }
  }
}
