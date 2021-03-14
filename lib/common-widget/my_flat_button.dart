import 'package:flutter/material.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/theme_utils.dart';

class MyFlatButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final Function onTap;
  final double radius;

  MyFlatButton(this.text, this.textColor, {this.onTap, this.radius = 8.0});

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeUtils.isDark(context);
    return FlatButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      color: isDark ? ColorConstant.TWEET_RICH_BG_DARK : ColorConstant.TWEET_RICH_BG_2,
      child: Text(
        '$text',
        style: pfStyle.copyWith(color: textColor, letterSpacing: 1.1),
      ),
      onPressed: onTap,
    );
  }
}
