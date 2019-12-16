import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationIconView {
  // 组件
  final BottomNavigationBarItem item;
  // 动画
  final AnimationController controller;

  final Color selColor;

  NavigationIconView(
      {Icon icon, Widget title, TickerProvider vsync, this.selColor})
      : item = new BottomNavigationBarItem(
          icon: icon,
          title: title,
           activeIcon: Icon(
             icon.icon,
             size: icon.size,
             color: Colors.blueAccent,
           )
        ),
        controller = new AnimationController(
            duration: kThemeAnimationDuration, vsync: vsync);
}
