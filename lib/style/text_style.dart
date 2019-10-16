import 'package:flutter/rendering.dart';
import 'package:iap_app/global/color_constant.dart';

class MyDefaultTextStyle {
  static TextStyle getTweetNickStyle(double fontSize) {
    return TextStyle(
        color: ColorConstant.TWEET_NICK_COLOR,
        fontSize: fontSize,
        fontWeight: FontWeight.bold);
  }

  static TextStyle getTweetTimeStyle(double fontSize) {
    return TextStyle(
      color: ColorConstant.TWEET_TIME_COLOR,
      fontSize: fontSize,
    );
  }
}
