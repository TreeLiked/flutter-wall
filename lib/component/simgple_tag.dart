import 'package:flutter/material.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/util/theme_utils.dart';

class SimpleTag extends StatelessWidget {
  final Color bgColor;
  final Color bgDarkColor;
  final Color textColor;
  final String text;
  final bool round;
  final double verticalPadding;
  final double leftMargin;

  SimpleTag(this.text,
      {this.bgColor = const Color(0xfff1f0f1),
      this.bgDarkColor = Colours.dark_bg_color_darker,
      this.textColor = Colors.grey,
      this.round = true,this.verticalPadding = 1.0, this.leftMargin = 0});

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeUtils.isDark(context);
    return Container(
        margin:  EdgeInsets.only(left: leftMargin),
//        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: verticalPadding),
        decoration: BoxDecoration(
            color: isDark ? bgDarkColor : bgColor,
            borderRadius:
                round ? BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(20)) : null),
        child: Text(
          text ?? "",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: textColor),
        ));
  }
}
