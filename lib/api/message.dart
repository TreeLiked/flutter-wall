import 'dart:core' as prefix1;
import 'dart:core';

import 'package:dio/dio.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/util/http_util.dart';
import 'package:iap_app/util/string.dart';

enum MessageCategory { INTERACTION, SYSTEM, CIRCLE_SYS }

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
//        msgList.forEach((msg) {
//          MessageType mst = msg.messageType;
//          switch (mst) {
//            case MessageType.TOPIC_REPLY:
//              print((msg as TopicReplyMessage).toJson());
//              break;
//            case MessageType.TWEET_PRAISE:
//              print((msg as TweetPraiseMessage).toJson());
//              break;
//            case MessageType.TWEET_REPLY:
//              print((msg as TweetReplyMessage).toJson());
//              break;
//            case MessageType.POPULAR:
//              // TODO: Handle this case.
//              break;
//            case MessageType.PLAIN_SYSTEM:
//              // TODO: Handle this case.
//              break;
//            case MessageType.REPORT:
//              // TODO: Handle this case.
//              break;
//          }
//        });
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
}
