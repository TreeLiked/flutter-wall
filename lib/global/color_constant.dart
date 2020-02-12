import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/util/theme_utils.dart';

class ColorConstant {
  // 昵称颜色
  static const Color TWEET_NICK_COLOR = Color(0xff708090);
  static const Color TWEET_NICK_COLOR_DARK = Color(0xff898989);

  // 推文body颜色
  static const Color TWEET_BODY_COLOR = Color(0xff000000);
  static const Color TWEET_BODY_COLOR_DARK = Color(0xff909090);

  // sub text 副文本颜色
  static const Color SUB_TEXT_COLOR = Color(0xff4f4f4f);
  static const Color SUB_TEXT_COLOR_DARK = Color(0xff808080);

  // 推文签名颜色
  static const Color TWEET_SIG_COLOR = Color(0xff828282);
  static const Color TWEET_SIG_COLOR_DARK = Color(0xff787878);

  // 推文时间颜色
  static const Color TWEET_TIME_COLOR = Color(0xffADADAD);
  static const Color TWEET_TIME_COLOR_DARK = Color(0xff707070);

  static const Color TWEET_TYPE_TEXT_DARK = Colors.white60;

  // 回复昵称颜色
  static const Color TWEET_REPLY_NICK_COLOR = Color(0xff696d7d);

  static const Color DEFAULT_BACK_COLOR = Color(0xffeef2f6);

  static const Color DEFAULT_BAR_BACK_COLOR = Color(0xfff9f9f9);
  static const Color DEFAULT_BAR_BACK_COLOR_DARK = Color(0xff333333);

  static const Color QQ_BLUE = Color(0xff19a9fc);

  static const Color MAIN_BAR_COLOR = Color(0xfff9f9f9);

  static Color getTweetNickColor(BuildContext context) {
    return ThemeUtils.isDark(context) ? TWEET_NICK_COLOR_DARK : TWEET_NICK_COLOR;
  }

  static Color getTweetBodyColor(bool isDark) {
    return isDark ? TWEET_BODY_COLOR_DARK : TWEET_BODY_COLOR;
  }

  static Color getSubTextBodyColor(bool isDark) {
    return isDark ? SUB_TEXT_COLOR_DARK : SUB_TEXT_COLOR;
  }

  static Color getTweetSigColor(BuildContext context) {
    return ThemeUtils.isDark(context) ? TWEET_SIG_COLOR_DARK : TWEET_SIG_COLOR;
  }

  static Color getTweetTimeColor(BuildContext context) {
    return ThemeUtils.isDark(context) ? TWEET_TIME_COLOR_DARK : TWEET_TIME_COLOR;
  }
}
