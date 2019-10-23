import 'package:flutter/material.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';

class ThemeConstant {
  static String appName = "Social app";

  //Colors for theme
  static Color lightPrimary = Color(0xffffffff);
  static Color darkPrimary = Colors.black;
  static Color lightAccent = Colors.blue;
  static Color darkAccent = Colors.blueAccent;
  static Color lightBG = Color(0xffffffff);
  static Color darkBG = Colors.black;
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
      color: Colors.white,
      textTheme: TextTheme(
        title: TextStyle(
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
        title: TextStyle(
          color: lightBG,
          fontSize: GlobalConfig.TEXT_TITLE_SIZE,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
