import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/click_item.dart';
import 'package:iap_app/res/resources.dart';
import 'package:iap_app/routes/fluro_navigator.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  var _styles = [
    FlutterLogoStyle.stacked,
    FlutterLogoStyle.markOnly,
    FlutterLogoStyle.horizontal
  ];
  var _colors = [
    Colors.red,
    Colors.green,
    Colors.brown,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.amber
  ];
  var _curves = [
    Curves.ease,
    Curves.easeIn,
    Curves.easeInOutCubic,
    Curves.easeInOut,
    Curves.easeInQuad,
    Curves.easeInCirc,
    Curves.easeInBack,
    Curves.easeInOutExpo,
    Curves.easeInToLinear,
    Curves.easeOutExpo,
    Curves.easeInOutSine,
    Curves.easeOutSine,
  ];

  // 取随机颜色
  Color _randomColor() {
    var red = Random.secure().nextInt(255);
    var greed = Random.secure().nextInt(255);
    var blue = Random.secure().nextInt(255);
    return Color.fromARGB(255, red, greed, blue);
  }

  Timer _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('about page state build');
    // 2s定时器
    _countdownTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      // https://www.jianshu.com/p/e4106b829bff
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    return Scaffold(
      appBar: const MyAppBar(
        title: "关于我们",
      ),
      body: Column(
        children: <Widget>[
          Gaps.vGap50,
          FlutterLogo(
            size: 100.0,
            colors: _colors[Random.secure().nextInt(7)],
            textColor: _randomColor(),
            style: _styles[Random.secure().nextInt(3)],
            curve: _curves[Random.secure().nextInt(12)],
          ),
          Gaps.vGap10,
          ClickItem(
              title: "Github",
              content: "请我喝咖啡",
              onTap: () {
                NavigatorUtils.goWebViewPage(
                    context, "甜甜圈", "https://gitee.com/treeliked/iap-app");
              }),
          ClickItem(
              title: "作者",
              onTap: () {
                NavigatorUtils.goWebViewPage(
                    context, "作者博客", "https://weilu.blog.csdn.net");
              }),
        ],
      ),
    );
  }
}
