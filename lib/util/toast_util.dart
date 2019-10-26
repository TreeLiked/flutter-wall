import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/global/color_constant.dart';

class ToastUtil {
  static void showToast(String text,
      {bool white = true, ToastGravity gravity = ToastGravity.CENTER}) {
    Fluttertoast.showToast(
      msg: '    $text    ',
      fontSize: 13,
      gravity: gravity,
      backgroundColor:
          white ? ColorConstant.DEFAULT_BAR_BACK_COLOR : Colors.black,
      textColor: !white ? Colors.white : Colors.black87,
    );
  }
}
