import 'package:flutter/material.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/style/text_style.dart';

class ThemeConstant {
  static String appName = "Social app";

  //Colors for theme
  static Color lightPrimary = Color(0xfffffeff);
  static Color darkPrimary = Colors.black;
  static Color lightAccent = Colors.blue;
  static Color darkAccent = Colors.blueAccent;

  static Color lightBG = Color(0xffFFFFFF);
  // 暗色模式appbar颜色
  static Color darkBG = Color(0xff121314);
  static Color badgeColor = Colors.red;

  static ThemeData lightTheme = ThemeData(
    backgroundColor: lightBG,
    primaryColor: lightPrimary,
    accentColor: lightAccent,
    cursorColor: lightAccent,
    scaffoldBackgroundColor: lightBG,
    bottomAppBarTheme: BottomAppBarTheme(color: Colors.black87),
    appBarTheme: AppBarTheme(
      elevation: 0,
      color: lightPrimary,
      textTheme: TextTheme(
        title: pfStyle.copyWith(

          color: darkBG,
          fontSize: GlobalConfig.TEXT_TITLE_SIZE,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: darkBG,
    primaryColor: darkPrimary,
    accentColor: darkAccent,
    scaffoldBackgroundColor: darkBG,
    cursorColor: darkAccent,
    appBarTheme: AppBarTheme(
      elevation: 0,
      textTheme: TextTheme(
        title: pfStyle.copyWith(
          color: lightBG,
          fontSize: GlobalConfig.TEXT_TITLE_SIZE,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
