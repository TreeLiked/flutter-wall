import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/util/theme_utils.dart';

class MyColorStyle {
  /// 推文相关
  static Color getTweetBodyColor({BuildContext context}) {
    return isLight(context: context) ? ColorConstant.TWEET_BODY_COLOR : ColorConstant.TWEET_BODY_COLOR_DARK;
  }

  /// 推文回复相关

  static Color getTweetReplyNickColor({BuildContext context}) {
    return isLight(context: context)
        ? ColorConstant.TWEET_REPLY_NICK_COLOR
        : ColorConstant.TWEET_REPLY_NICK_COLOR_DARK;
  }

  static Color getTweetReplyBodyColor({BuildContext context}) {
    return isLight(context: context)
        ? ColorConstant.TWEET_REPLY_BODY_COLOR
        : ColorConstant.TWEET_REPLY_BODY_COLOR_DARK;
  }

  static Color getTweetReplyAnonymousNickColor({BuildContext context}) {
    return isLight(context: context)
        ? ColorConstant.TWEET_REPLY_ANONYMOUS_NICK_COLOR
        : ColorConstant.TWEET_REPLY_ANONYMOUS_NICK_COLOR_DARK;
  }

  static Color getTweetReplyMoreColor({BuildContext context}) {
    return isLight(context: context)
        ? ColorConstant.TWEET_REPLY_REPLY_MORE_COLOR
        : ColorConstant.TWEET_REPLY_REPLY_MORE_COLOR_DARK;
  }

  static bool isLight({BuildContext context}) {
    return !ThemeUtils.isDark(context ?? Application.context);
  }
}
