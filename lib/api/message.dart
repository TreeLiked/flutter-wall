import 'dart:core' as prefix1;
import 'dart:core';

import 'package:dio/dio.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/http_util.dart';
import 'package:iap_app/util/string.dart';

enum MessageCategory { INTERACTION, TWEET_NEW, SYSTEM, CIRCLE_SYS, CIRCLE_INTERACTION, CIRCLE, ALL }

final msgCategoryCodeMap = {
  MessageCategory.INTERACTION: "21",
  MessageCategory.TWEET_NEW: "22",
  MessageCategory.SYSTEM: "11",
  MessageCategory.CIRCLE_INTERACTION: "31",
  MessageCategory.CIRCLE_SYS: "32",
  MessageCategory.CIRCLE: "30",
  MessageCategory.ALL: "0",
};

final codeMsgCategoryMap = {
  "21": MessageCategory.INTERACTION,
  "22": MessageCategory.TWEET_NEW,
  "11": MessageCategory.SYSTEM,
  "31": MessageCategory.CIRCLE_INTERACTION,
  "32": MessageCategory.CIRCLE_SYS,
  "30": MessageCategory.CIRCLE,
  "0": MessageCategory.ALL
};

class MessageAPI {
  static Future<List<AbstractMessage>> queryInteractionMsg(int currentPage, int pageSize) async {
    String url = Api.API_MSG_LIST_INTERACTION + "?currentPage=$currentPage";
    try {
      Response response = await httpUtil.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      bool success = json["isSuccess"];
      if (success) {
        Map<String, dynamic> pageData = json["data"];
        List<dynamic> jsonData = pageData["data"];
        if (jsonData == null || jsonData.length <= 0) {
          return [];
        }
        List<AbstractMessage> msgList = jsonData.map((m) {
          return AbstractMessage.fromJson(m);
        }).toList();
        return msgList;
      } else {
        return null;
      }
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<List<AbstractMessage>> querySystemMsg(int currentPage, int pageSize) async {
    String url = Api.API_MSG_LIST_SYSTEM + "?currentPage=$currentPage";
    try {
      Response response = await httpUtil.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      bool success = json["isSuccess"];
      if (success) {
        Map<String, dynamic> pageData = json["data"];
        List<dynamic> jsonData = pageData["data"];
        if (jsonData == null || jsonData.length <= 0) {
          return [];
        }
        List<AbstractMessage> msgList = jsonData.map((m) {
          return AbstractMessage.fromJson(m);
        }).toList();
        return msgList;
      } else {
        return null;
      }
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<List<AbstractMessage>> queryCircleSystemMsg(int currentPage, int pageSize) async {
    try {
      Response response = await httpUtil.dio.get(Api.API_MSG_LIST_CIRCLE_SYSTEM,
          queryParameters: {"currentPage": currentPage, "pageSize": pageSize});
      Map<String, dynamic> json = Api.convertResponse(response.data);
      bool success = json["isSuccess"];
      if (success) {
        Map<String, dynamic> pageData = json["data"];
        List<dynamic> jsonData = pageData["data"];
        if (jsonData == null || jsonData.length <= 0) {
          return [];
        }
        List<AbstractMessage> msgList = jsonData.map((m) {
          return AbstractMessage.fromJson(m);
        }).toList();
        return msgList;
      } else {
        return [];
      }
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return [];
  }

  static Future<Result> readAllInteractionMessage({bool pop = false}) async {
    String url = Api.API_MSG_READ_ALL_INTERACTION;
    Result r;
    try {
      Response response = await httpUtil.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      return Result.fromJson(json);
    } on DioError catch (e) {
      String error = Api.formatError(e, pop: pop);
      r.isSuccess = false;
      r.message = error;
    }
    return r;
  }

  static Future<Result> readThisMessage(int messageId) async {
    Result r;
    try {
      Response response = await httpUtil.dio.get(Api.API_MSG_READ_THIS, queryParameters: {"mId": messageId});
      Map<String, dynamic> json = Api.convertResponse(response.data);
      return Result.fromJson(json);
    } on DioError catch (e) {
      String error = Api.formatError(e);
      r.isSuccess = false;
      r.message = error;
    }
    return r;
  }

  static Future<Result> ignoreThisMessage(int messageId) async {
    Result r;
    try {
      Response response =
          await httpUtil.dio.get(Api.API_MSG_IGNORE_THIS, queryParameters: {"mId": messageId});
      Map<String, dynamic> json = Api.convertResponse(response.data);
      return Result.fromJson(json);
    } on DioError catch (e) {
      String error = Api.formatError(e);
      r = Result(isSuccess: false);
      r.message = error;
    }
    return r;
  }

  // 0 系统消息，1互动消息
  static Future<dynamic> fetchLatestMessage(MessageCategory type) async {
    try {
      String typeStr = type.toString().substring(type.toString().indexOf('.') + 1);
      Response response = await httpUtil.dio.get(Api.API_MSG_LATEST, queryParameters: {"c": typeStr});
      Map<String, dynamic> json = Api.convertResponse(response.data);
      bool success = json["isSuccess"];
      if (success) {
        if (json['data'] == null) {
          return null;
        }
        return AbstractMessage.fromJson(json['data']);
      } else {
        return null;
      }
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }

  static Future<Result> deleteInteractionMessage() async {
    String url = Api.API_MSG_READ_ALL_INTERACTION;
    Result r;
    try {
      Response response = await httpUtil.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      return Result.fromJson(json);
    } on DioError catch (e) {
      String error = Api.formatError(e);
      r.isSuccess = false;
      r.message = error;
    }
    return r;
  }

  static Future<int> queryInteractionMessageCount() async {
    String url = Api.API_MSG_INTERACTION_CNT;
    try {
      Response response = await httpUtil.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      Result r = Result.fromJson(json);
      if (r != null && r.isSuccess) {
        return json['data'];
      }
      return -1;
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return -1;
  }

  static Future<int> queryNewTweetCount(int orgId, int tweetId, String type) async {
    String url;
    if (StringUtil.isEmpty(type)) {
      url = "${Api.API_NEW_TWEET_CNT}?oId=$orgId&tId=$tweetId";
    } else {
      url = "${Api.API_NEW_TWEET_CNT}?oId=$orgId&tId=$tweetId&tType=$type";
    }
    try {
      Response response = await httpUtil.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      Result r = Result.fromJson(json);
      if (r != null && r.isSuccess) {
        return json['data'];
      }
      return -1;
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return -1;
  }

  static Future<int> querySystemMessageCount() async {
    String url = Api.API_MSG_SYSTEM_CNT;
    try {
      Response response = await httpUtil.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      Result r = Result.fromJson(json);
      if (r.isSuccess) {
        return json['data'];
      }
      return -1;
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return -1;
  }

  static Future<int> queryMsgCount(MessageCategory category) async {
    try {
      Response response = await httpUtil.dio.get(Api.API_MSG_CNT + "?t=" + Utils.getEnumValue(category));
      Map<String, dynamic> json = Api.convertResponse(response.data);
      Result r = Result.fromJson(json);
      if (r.isSuccess) {
        return json['data'] ?? 0;
      }
      return 0;
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return 0;
  }

  static Future<Map<String, int>> batchQueryMsgCount(List<String> categoryCodes) async {
    try {
      Response response =
          await httpUtil.dio.get(Api.API_MSG_CNT_BATCH, queryParameters: {"t": categoryCodes});
      Map<String, dynamic> json = Api.convertResponse(response.data);
      Result r = Result.fromJson(json);

      if (r.isSuccess) {
        Map<String, dynamic> map = json['data'];
        if (CollectionUtil.isMapEmpty(map)) {
          return {};
        }
        ;
        print(map);
        return map.map((key, value) => prefix1.MapEntry(key, value as int));
      }
      return {};
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return {};
  }

  static Future<Map<String, AbstractMessage>> batchFetchLatestMessage(List<String> categoryCodes) async {
    try {
      Response response =
          await httpUtil.dio.get(Api.API_MSG_LATEST_BATCH, queryParameters: {"t": categoryCodes});
      Map<String, dynamic> json = Api.convertResponse(response.data);
      bool success = json["isSuccess"];
      if (success) {
        Map<String, dynamic> msgs = json['data'];
        if (CollectionUtil.isMapEmpty(msgs)) {
          return {};
        }
        return msgs.map((key, value) => prefix1.MapEntry(key, AbstractMessage.fromJson(value)));
      } else {
        return {};
      }
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return {};
  }
}
