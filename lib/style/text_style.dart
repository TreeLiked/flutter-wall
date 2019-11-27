import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/util/theme_utils.dart';

class MyDefaultTextStyle {
  static TextStyle getTweetNickStyle(double fontSize,
      {bool bold = true, bool anonymous = false}) {
    return TextStyle(
        color: !anonymous ? ColorConstant.TWEET_NICK_COLOR : Colors.grey,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal);
  }

  static TextStyle getTweetReplyNickStyle(double fontSize) {
    return TextStyle(
        color: ColorConstant.TWEET_REPLY_NICK_COLOR,
        fontSize: fontSize,
        fontWeight: FontWeight.w500);
  }

  static TextStyle getTweetReplyAnonymousNickStyle(
      BuildContext context, double fontSize) {
    return TextStyle(
        color: ThemeUtils.isDark(context) ? Colors.grey : Color(0xff363636),
        fontSize: fontSize,
        fontWeight: FontWeight.w500);
  }

  static TextStyle getTweetHeadNickStyle(double fontSize,
      {bool anonymous = false, bool bold = false}) {
    return TextStyle(
        fontSize: SizeConstant.TWEET_FONT_SIZE,
        fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
        color: !anonymous ? ColorConstant.TWEET_NICK_COLOR : Color(0xff828282));
  }

  static TextStyle getTweetTimeStyle(double fontSize) {
    return TextStyle(
      color: ColorConstant.TWEET_TIME_COLOR,
      fontSize: fontSize,
    );
  }

  static TextStyle getTweetReplyOtherStyle(double fontSize) {
    return TextStyle(
      color: Colors.black87,
      fontSize: fontSize,
    );
  }

  static Text getBottomNavTextItem(String text) {
    return Text(text, style: TextStyle(fontSize: 12));
  }
}
