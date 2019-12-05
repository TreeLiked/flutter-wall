import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/util/theme_utils.dart';

class ToastUtil {
  static void showToast(BuildContext context, String text,
      {ToastGravity gravity = ToastGravity.CENTER}) {
    bool dark = false;
    if (context != null) {
      dark = ThemeUtils.isDark(context);
    }
    Fluttertoast.showToast(
      msg: '    $text    ',
      fontSize: 13,
      gravity: gravity,
      backgroundColor: dark ? Colors.black87 : Colors.white70,
      textColor: dark ? Colors.white : Colors.black,
    );
  }
}
