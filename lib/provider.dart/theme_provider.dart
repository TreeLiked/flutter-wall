import 'dart:ui';
import 'dart:ui' as prefix0;

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/styles.dart';

class ThemeProvider extends ChangeNotifier {
  static const Map<Themes, String> themes = {
    Themes.DARK: "Dark",
    Themes.LIGHT: "Light",
    Themes.SYSTEM: "System"
  };

  void syncTheme() {
    String theme = SpUtil.getString(SharedConstant.THEME);
    if (theme.isNotEmpty && theme != themes[Themes.SYSTEM]) {
      notifyListeners();
    }
  }

  void setTheme(Themes theme) {
    SpUtil.putString(SharedConstant.THEME, themes[theme]);
    notifyListeners();
  }

  getTheme({bool isDarkMode: false}) {
    String theme = SpUtil.getString(SharedConstant.THEME);
    switch (theme) {
      case "Dark":
        isDarkMode = true;
        break;
      case "Light":
        isDarkMode = false;
        break;
      default:
        break;
    }

    return ThemeData(
        errorColor: isDarkMode ? Colours.dark_red : Colours.red,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
        accentColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
        primaryIconTheme:
            IconThemeData(color: isDarkMode ? Colors.grey : Colors.black),
        // Tab指示器颜色
        indicatorColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
        // 页面背景色
        scaffoldBackgroundColor:
            isDarkMode ? Colours.dark_bg_color : Colors.white,
        // 主要用于Material背景色
        canvasColor: isDarkMode ? Colours.dark_material_bg : Colors.white,
        // 文字选择色（输入框复制粘贴菜单）
        textSelectionColor: Colours.app_main.withAlpha(70),
        textSelectionHandleColor: Colours.app_main,
        textTheme: TextTheme(
          // TextField输入文字颜色
          subhead: isDarkMode ? TextStyles.textDark : TextStyles.text,
          // Text文字样式
          body1: isDarkMode ? TextStyles.textDark : TextStyles.text,
          subtitle:
              isDarkMode ? TextStyles.textDarkGray12 : TextStyles.textGray12,
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle:
              isDarkMode ? TextStyles.textHint14 : TextStyles.textDarkGray14,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0.0,
          color: isDarkMode ? Colours.dark_bg_color : Colors.white,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        primaryTextTheme: TextTheme(
            title: isDarkMode
                ? const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w400)
                : const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400)),
        dividerTheme: DividerThemeData(
            color: isDarkMode ? Colours.dark_line : Colours.line,
            space: 0.6,
            thickness: 0.6));
  }
}

enum Themes { DARK, LIGHT, SYSTEM }
