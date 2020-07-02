import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/toast_util.dart';

class TRUtil {
  static void sendReplyCallback(State widget, BaseTweet tweet, TweetReply callbackReply) {}

  static TweetReply assembleReply(BaseTweet tweet, String body, bool anonymous, bool direct, {int parentId,String tarAccountId}) {
    TweetReply reply = new TweetReply();
    reply.type = direct ? 1 : 2;
    reply.tweetId = tweet.id;
    reply.anonymous = anonymous;
    reply.account = Account.fromId(Application.getAccountId);
    reply.body = body;
    if (direct) {
      reply.parentId = tweet.id;
      reply.tarAccount = Account.fromId(tweet.account.id);
    } else {
      reply.parentId = parentId;
      reply.tarAccount = Account.fromId(tarAccountId);

    }
    return reply;
  }

  static Future<void> publicReply(BuildContext context, TweetReply reply, Function callback) async {
    Utils.showDefaultLoadingWithBounds(context, text: '');
    await TweetApi.pushReply(reply, reply.tweetId).then((Result result) {
      NavigatorUtils.goBack(context);
      if (result.isSuccess) {
        TweetReply newReply = TweetReply.fromJson(result.data);
        callback(true, newReply);
      } else {
        result.toText();
        callback(false, null);
      }
    });
  }
}
