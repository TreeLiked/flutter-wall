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
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:iap_app/model/message/topic_reply_message.dart';
import 'package:iap_app/model/message/tweet_praise_message.dart';
import 'package:iap_app/model/message/tweet_reply_message.dart';
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

class MessageAPI {
  static Future<List<AbstractMessage>> queryInteractionMsg(int currentPage, int pageSize) async {
    String url = Api.API_MSG_LIST_INTERACTION + "?currentPage=$currentPage";
    print(url);
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
        msgList.forEach((msg) {
          MessageType mst = msg.messageType;
          switch (mst) {
            case MessageType.TOPIC_REPLY:
              print((msg as TopicReplyMessage).toJson());
              break;
            case MessageType.TWEET_PRAISE:
              print((msg as TweetPraiseMessage).toJson());
              break;
            case MessageType.TWEET_REPLY:
              print((msg as TweetReplyMessage).toJson());
              break;
            case MessageType.POPULAR:
              // TODO: Handle this case.
              break;
            case MessageType.PLAIN_SYSTEM:
              // TODO: Handle this case.
              break;
            case MessageType.REPORT:
              // TODO: Handle this case.
              break;
          }
        });
        return msgList;
      } else {
        return null;
      }
    } on DioError catch (e) {
      String error = Api.formatError(e);
      print(error);
    }
    return null;
  }
}
