import 'package:flutter/material.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/shared.dart';
import 'package:iap_app/util/string.dart';

class TweetReplyUtil {
  static const String ANONYMOUS_REPLY = "匿名";
  static const String AUTHOR_TEXT = "作者";
  static const String UNKNOWN_REPLY = "未知回复";

  static String getTweetReplyAuthorText(
      Account acc, bool tweetAnonymous, bool replyAnonymous, bool isAuthor) {
    if (replyAnonymous) {
      return ANONYMOUS_REPLY;
    } else {
      if (isAuthor) {
        if (tweetAnonymous) {
          return AUTHOR_TEXT;
        }
      }
      return acc.nick ?? UNKNOWN_REPLY;
    }
  }

  static String getTweetReplyTargetAccountText(Account targetAcc, bool tweetAnonymous, bool replyAuthor) {
    if (tweetAnonymous && replyAuthor) {
      return AUTHOR_TEXT;
    }
    return targetAcc.nick ?? UNKNOWN_REPLY;
  }

  static TextStyle getTweetReplyStyle(
      bool tweetAnonymous, bool replyAnonymous, bool isAuthor, double fontSize,
      {BuildContext context}) {
    if (replyAnonymous) {
      return MyDefaultTextStyle.getTweetReplyAnonymousNickStyle(fontSize, context: context);
    } else {
//      if (isAuthor) {
//        if (tweetAnonymous) {
//          return MyDefaultTextStyle.getTweetReplyAuthorNickStyle(fontSize, context: context);
//        }
//      }
      return MyDefaultTextStyle.getTweetReplyAuthorNickStyle(fontSize, context: context);
    }
  }

  static TextStyle getReplyBodyStyle(double fontSize, {BuildContext context}) {
    return MyDefaultTextStyle.getTweetReplyBodyTextStyle(fontSize, context: context);
  }

  static TextStyle getTweetHuiFuStyle(double fontSize, {BuildContext context}) {
    return MyDefaultTextStyle.getTweetReplyHuiFuTextStyle(fontSize, context: context);
  }

  static getNickFromAccount(Account account, bool anonymous) {
    if (anonymous) {
      return TextConstant.TWEET_ANONYMOUS_NICK;
    }
    if (account != null) {
      if (!StringUtil.isEmpty(account.nick)) {
        return account.nick;
      }
    }
    return '';
  }

  static Future<String> getStorageAccountId() async {
    return await SharedPreferenceUtil.readStringValue(SharedConstant.LOCAL_ACCOUNT_ID);
  }
}
