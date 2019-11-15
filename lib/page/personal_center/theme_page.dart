import 'package:flutter/material.dart';
import 'package:flustars/flustars.dart' as flutter_stars;
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemePage extends StatefulWidget {
  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  var _list = ["跟随系统", "开启", "关闭"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await flutter_stars.SpUtil.getInstance();
    });
  }

  @override
  Widget build(BuildContext context) {
    String theme = flutter_stars.SpUtil.getString(SharedConstant.THEME);
    String themeMode;
    switch (theme) {
      case "Dark":
        themeMode = _list[1];
        break;
      case "Light":
        themeMode = _list[2];
        break;
      default:
        themeMode = _list[0];
        break;
    }
    return Scaffold(
      appBar: const MyAppBar(
        title: "夜间模式",
      ),
      body: ListView.separated(
          shrinkWrap: true,
          itemCount: _list.length,
          separatorBuilder: (_, index) {
            return const Divider();
          },
          itemBuilder: (_, index) {
            return InkWell(
              onTap: () {
                flutter_stars.SpUtil.putString(SharedConstant.THEME,
                    index == 0 ? "" : (index == 1 ? "Dark" : "Light"));
                Provider.of<ThemeProvider>(context).setTheme(index == 0
                    ? Themes.SYSTEM
                    : (index == 1 ? Themes.DARK : Themes.LIGHT));
              },
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 50.0,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(_list[index]),
                    ),
                    Opacity(
                        opacity: themeMode == _list[index] ? 1 : 0,
                        child: Icon(Icons.done, color: Colors.blue))
                  ],
                ),
              ),
            );
          }),
    );
  }
}
