import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/util/theme_utils.dart';

class ToastUtil {
  static void showToast(BuildContext context, String text,
      {Toast length = Toast.LENGTH_LONG,  ToastGravity gravity = ToastGravity.CENTER}) {
    bool dark = false;
    if (context != null) {
      dark = ThemeUtils.isDark(context);
    }
    Fluttertoast.showToast(
      msg: '    $text    ',
      fontSize: Dimens.font_sp14,
      gravity: gravity,
      toastLength: length,
      backgroundColor: dark ? Colors.black87 : Colors.black38,
      textColor: dark ? Colors.white : Colors.white,
    );
  }

  static void showServiceExpToast(BuildContext context) {
    showToast(context, TextConstant.TEXT_SERVICE_ERROR,length: Toast.LENGTH_LONG);
  }
}
