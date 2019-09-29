import 'package:flutter/material.dart';

class GlobalConfig {
  static bool dark = false;
  static ThemeData td = ThemeData(
    primaryColor: Colors.white,
    scaffoldBackgroundColor: new Color(0xFFEBEBEB),
    appBarTheme: AppBarTheme(
        textTheme: TextTheme(title: TextStyle(color: Colors.black))),

    // primarySwatch: Colors.white,
  );
  static Color searchBackgroundColor = Colors.white10;
  static Color cardBackgroundColor = new Color(0xFF222222);
  static Color fontColor = Colors.white30;

  // tweet relative
  static const Color tweetNickColor = Color(0xff686F8F);
  static const Color tweetTimeColor = Color(0xffBEBEBE);
  static const Color tweetBodyColor = Colors.black;
  static const Color tweetTypeColor = Colors.blueGrey;

  static const Color DEFAULT_BAR_BACK_COLOR = Color(0xfff9f9f9);

  static const double TWEET_FONT_SIZE = 16.5;

  static const double CREATE_ICON_SIZE = 20;

  static const double CREATE_ICON_FONT_SIZE = 16;

  static const Color TEXT_DEFAULT_CLICKABLE_COLOR = Color(0xff686F8F);

  static const int TWEET_MAX_LENGTH = 256;

  // 每个页面标题字体的大小
  static const double TEXT_TITLE_SIZE = 16;
}
