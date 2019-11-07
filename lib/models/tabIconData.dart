import 'package:flutter/material.dart';

class TabIconData {
  String imagePath;
  String selctedImagePath;
  bool isSelected;
  int index;
  AnimationController animationController;

  TabIconData({
    this.imagePath = '',
    this.index = 0,
    this.selctedImagePath = "",
    this.isSelected = false,
    this.animationController,
  });

  static List<TabIconData> tabIconsList = [
    TabIconData(
      imagePath: 'assets/images/tab/tab_1.png',
      selctedImagePath: 'assets/images/tab/tab_1s.png',
      index: 0,
      isSelected: true,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/images/tab/tab_2.png',
      selctedImagePath: 'assets/images/tab/tab_2s.png',
      index: 1,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/images/tab/tab_3.png',
      selctedImagePath: 'assets/images/tab/tab_3s.png',
      index: 2,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/images/tab/tab_4.png',
      selctedImagePath: 'assets/images/tab/tab_4s.png',
      index: 3,
      isSelected: false,
      animationController: null,
    ),
  ];
}