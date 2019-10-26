import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/size_constant.dart';

class MyDefaultTextStyle {
  static TextStyle getTweetNickStyle(double fontSize) {
    return TextStyle(
        color: ColorConstant.TWEET_NICK_COLOR,
        fontSize: fontSize,
        fontWeight: FontWeight.bold);
  }

  static TextStyle getTweetReplyNickStyle(double fontSize) {
    return TextStyle(
        color: ColorConstant.TWEET_REPLY_NICK_COLOR,
        fontSize: fontSize,
        fontWeight: FontWeight.w400);
  }

  static TextStyle getTweetReplyAnonymousNickStyle(double fontSize) {
    return TextStyle(
        color: Color(0xff828282),
        fontSize: fontSize,
        fontWeight: FontWeight.w400);
  }

  static TextStyle getTweetHeadNickStyle(double fontSize,
      {bool anonymous = false}) {
    return TextStyle(
        fontSize: SizeConstant.TWEET_FONT_SIZE,
        fontWeight: FontWeight.bold,
        color: !anonymous ? ColorConstant.TWEET_NICK_COLOR : Color(0xff828282));
  }

  static TextStyle getTweetTimeStyle(double fontSize) {
    return TextStyle(
      color: ColorConstant.TWEET_TIME_COLOR,
      fontSize: fontSize,
    );
  }
}
