import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/util/theme_utils.dart';

class MyDefaultTextStyle {
  static TextStyle getTweetNickStyle(BuildContext context, double fontSize,
      {bool bold = true, bool anonymous = false}) {
    return TextStyle(
        color: ColorConstant.getTweetNickColor(context),
        fontSize: fontSize,

        fontWeight: bold ? FontWeight.bold : FontWeight.normal);
  }

  static TextStyle getMainTextBodyStyle(bool isDark, {double fontSize = Dimens.font_sp16}) {
    return TextStyle(color: ColorConstant.getTweetBodyColor(isDark), height: 1.6, fontSize: fontSize);
  }

  static TextStyle getSubTextBodyStyle(bool isDark, {double fontSize = Dimens.font_sp15}) {
    return TextStyle(color: ColorConstant.getSubTextBodyColor(isDark), height: 1.6, fontSize: fontSize);
  }

  static TextStyle getTweetTypeStyle(BuildContext context, {double fontSize = Dimens.font_sp16}) {
    return TextStyle(
        color: !ThemeUtils.isDark(context) ? Colors.white : ColorConstant.TWEET_TYPE_TEXT_DARK,
        fontWeight: FontWeight.w500);
  }

  static TextStyle getTweetReplyNickStyle(BuildContext context, {double fontSize = Dimens.font_sp14}) {
    return TextStyle(
        color: ColorConstant.getTweetNickColor(context), fontSize: fontSize, fontWeight: FontWeight.w400);
  }

  static TextStyle getTweetReplyAnonymousNickStyle(BuildContext context, double fontSize) {
    return TextStyle(
        color: ThemeUtils.isDark(context) ? Colors.grey : Color(0xff363636),
        fontSize: fontSize,
        fontWeight: FontWeight.w500);
  }

  static TextStyle getTweetHeadNickStyle(BuildContext context, double fontSize,
      {bool anonymous = false, bool bold = false}) {
    return TextStyle(
        fontSize: SizeConstant.TWEET_FONT_SIZE,
        fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
        color: !anonymous ? ColorConstant.getTweetNickColor(context) : Color(0xff828282));
  }

  static TextStyle getTweetSigStyle(BuildContext context, {double fontSize = Dimens.font_sp13}) {
    return TextStyle(fontSize: fontSize, color: ColorConstant.getTweetSigColor(context),fontWeight: FontWeight.w400);
  }

  static TextStyle getTweetTimeStyle(BuildContext context, {double fontSize = SizeConstant.TWEET_TIME_SIZE}) {
    return TextStyle(fontSize: fontSize, color: ColorConstant.getTweetTimeColor(context));
  }

  static TextStyle getTweetReplyOtherStyle(double fontSize) {
    return TextStyle(
      color: Colors.black87,
      fontSize: fontSize,
    );
  }

  static Text getBottomNavTextItem(String text, Color color) {
    return Text(text, style: TextStyle(fontSize: 13));
  }
}
