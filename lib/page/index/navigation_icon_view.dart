import 'dart:async';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/bloc/count_bloc.dart';
import 'package:iap_app/res/dimens.dart';

class NavigationIconView {
  // 组件
  final BottomNavigationBarItem item;

  // 动画
  final AnimationController controller;

  final Color selColor;

  final StreamController<int> _countControl;

//  final BaseBloc bloc;

  NavigationIconView(this._countControl,
      {Icon icon,
      Widget title,
      TickerProvider vsync,
      this.selColor,
      bool badgeAble = false,
      bool pointType = false})
      : item = new BottomNavigationBarItem(
            icon: badgeAble
                ? StreamBuilder(
                    initialData: 0,
                    stream: _countControl.stream,
                    builder: (_, snapshot) => Badge(
                      elevation: 0,
//                      shape: pointType ? BadgeShape.circle,
                      padding: const EdgeInsets.all(4),
                      child: icon,
                      animationType: BadgeAnimationType.fade,
                      showBadge: snapshot.data != -1 && snapshot.data != 0,
                      badgeContent: pointType
                          ? Container(
                              height: 3,
                              width: 3,
//                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                            )
                          : Text(
                              '${snapshot.data}',
                              style: const TextStyle(color: Colors.white, fontSize: Dimens.font_sp12),
                            ),
                    ),
                  )
                : icon,
            title: title,
//            activeIcon: Icon(
//              icon.icon,
//              size: icon.size,
//              color: Colors.blueAccent,
//            )
            activeIcon: badgeAble
                ? StreamBuilder(
                    initialData: 0,
                    stream: _countControl.stream,
                    builder: (_, snapshot) => Badge(
                      elevation: 0,
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        icon.icon,
                        size: icon.size,
                        color: Colors.blueAccent,
                      ),
                      animationType: BadgeAnimationType.fade,
                      showBadge: snapshot.data != -1 && snapshot.data != 0,
                      badgeContent: pointType
                          ? Container(
                              height: 3,
                              width: 3,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                            )
                          : Text(
                              '${snapshot.data}',
                              style: const TextStyle(color: Colors.white, fontSize: Dimens.font_sp12),
                            ),
                    ),
                  )
                : Icon(
                    icon.icon,
                    size: icon.size,
                    color: Colors.blueAccent,
                  )),
        controller = new AnimationController(duration: kThemeAnimationDuration, vsync: vsync);
}
