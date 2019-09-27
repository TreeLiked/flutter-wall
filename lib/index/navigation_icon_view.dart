import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationIconView {
  // 组件
  final BottomNavigationBarItem item;
  // 动画
  final AnimationController controller;

  NavigationIconView({Widget icon, Widget title, TickerProvider vsync})
      : item = new BottomNavigationBarItem(icon: icon, title: title),
        controller = new AnimationController(
            duration: kThemeAnimationDuration, vsync: vsync);
}
