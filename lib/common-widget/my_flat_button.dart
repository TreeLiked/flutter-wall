import 'package:flutter/material.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/theme_utils.dart';

class MyFlatButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final Function onTap;
  final double radius;

  Color fillColor;
  bool disabled;
  double horizontalPadding;

  MyFlatButton(this.text, this.textColor,
      {this.onTap, this.radius = 8.0, this.disabled = false, this.fillColor, this.horizontalPadding = 10.0});

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeUtils.isDark(context);
    return TextButton(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(pfStyle.copyWith(fontSize: Dimens.font_sp16p5)),
        enableFeedback: true,
        foregroundColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.focused) && !states.contains(MaterialState.pressed)) {
              //获取焦点时的颜色
              return Colors.blue;
            } else if (states.contains(MaterialState.pressed)) {
              //按下时的颜色
              return Colors.white70;
            }
            //默认状态使用灰色
            return disabled ? Colors.grey : textColor;
          },
        ),
        //背景颜色
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          // //设置按下时的背景颜色
          // if (states.contains(MaterialState.pressed)) {
          //   return Colors.blue[200];
          // }
          //默认不使用背景颜色
          // return null;
          return fillColor == null
              ? (isDark ? ColorConstant.TWEET_RICH_BG_DARK : ColorConstant.TWEET_RICH_BG_2)
              : disabled
                  ? (isDark ? ColorConstant.TWEET_RICH_BG_DARK : Color(0xfff5f5f5))
                  : (isDark ? ColorConstant.TWEET_RICH_BG_DARK : fillColor);
        }),
        //设置水波纹颜色
        // overlayColor: MaterialStateProperty.all(Colors.yellow),
        //设置按钮内边距
        padding:
            MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5.0)),
        //设置按钮的大小

        //设置边框
        // side: MaterialStateProperty.all(BorderSide(color: Colors.grey, width: 1)),
        //外边框装饰 会覆盖 side 配置的样式
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius))),
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        // color: fillColor == null
        //     ? (isDark ? ColorConstant.TWEET_RICH_BG_DARK : ColorConstant.TWEET_RICH_BG_2)
        //     : fillColor,
      ),

      child: Text(
        '$text',
        // style: pfStyle.copyWith(color: disabled ? Colors.grey : textColor, letterSpacing: 1.1)
      ),
      // disabledColor: Color(0xffF5F5F5),
      // disabledTextColor: Colors.black,
      onPressed: disabled ? null : onTap,
    );
  }
}
