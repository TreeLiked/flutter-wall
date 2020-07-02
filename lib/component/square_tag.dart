import 'package:flutter/material.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/util/theme_utils.dart';

class SquareTag extends StatelessWidget {
  final Color backgroundColor;
  final Color backgroundDarkColor;
  final String text;
  final TextStyle textStyle;
  final double verticalPadding;
  final double horizontalPadding;
  final double roundRadius;
  final Widget prefixIcon;

  SquareTag(this.text,
      {this.backgroundColor = const Color(0xfff1f0f1),
      this.backgroundDarkColor = Colours.dark_bg_color_darker,
      this.verticalPadding = 1.0,
      this.horizontalPadding = 0.0,
      this.textStyle = const TextStyle(
        fontSize: 13.0,
        fontWeight: FontWeight.w300,
        color: Colors.grey,
      ),
      this.prefixIcon,
      this.roundRadius = 0});

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeUtils.isDark(context);
    return Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
        decoration: BoxDecoration(
            color: isDark ? backgroundDarkColor : backgroundColor,
            borderRadius: roundRadius != 0 ? BorderRadius.circular(roundRadius) : null),
        child: prefixIcon == null
            ? Text(text ?? "", style: textStyle)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[prefixIcon, Gaps.hGap4, Text(text ?? "", style: textStyle)],
              ));
  }
}
