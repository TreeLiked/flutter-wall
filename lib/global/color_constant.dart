import 'package:flutter/cupertino.dart';
import 'package:iap_app/util/theme_utils.dart';

class ColorConstant {
  static const Color TWEET_NICK_COLOR = Color(0xff708090);
  static const Color TWEET_NICK_COLOR_DARK = Color(0xff898989);

  static const Color TWEET_SIG_COLOR = Color(0xff828282);
  static const Color TWEET_SIG_COLOR_DARK = Color(0xff787878);

  static const Color TWEET_TIME_COLOR = Color(0xffBEBEBE);
  static const Color TWEET_TIME_COLOR_DARK = Color(0xff707070);

  static const Color TWEET_TYPE_TEXT_DARK = Color(0xff3f3f3f);

  static const Color TWEET_REPLY_NICK_COLOR = Color(0xff696d7d);

  static const Color TWEET_EXTRA_COLOR = Color(0xffBEBEBE);

  static const Color TWEET_TYPE_COLOR = Color(0xffffe978);

  static const Color TWEET_REPLY_FONT_COLOR = Color(0xff000000);

  static const Color DEFAULT_BACK_COLOR = Color(0xffeef2f6);

  static const Color DEFAULT_BAR_BACK_COLOR = Color(0xffE7E8EA);

  static const Color QQ_BLUE = Color(0xff19a9fc);

  static const Color MAIN_BAR_COLOR = Color(0xfff9f9f9);

  static Color getTweetNickColor(BuildContext context) {
    return ThemeUtils.isDark(context)
        ? TWEET_NICK_COLOR_DARK
        : TWEET_NICK_COLOR;
  }

  static Color getTweetSigColor(BuildContext context) {
    return ThemeUtils.isDark(context) ? TWEET_SIG_COLOR_DARK : TWEET_SIG_COLOR;
  }

  static Color getTweetTimeColor(BuildContext context) {
    return ThemeUtils.isDark(context)
        ? TWEET_TIME_COLOR_DARK
        : TWEET_TIME_COLOR;
  }
}
