import 'package:iap_app/platform/base_platform_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
class PlatformAppBar extends BasePlatformWidget<AppBar, CupertinoNavigationBar> {
  final Widget title;
  final Widget leading;
  final Widget action;

  PlatformAppBar({this.title, this.leading,this.action});

  @override
  AppBar createAndroidWidget(BuildContext context) {
    return new AppBar(
      leading: leading,
      title: title,
      actions: <Widget>[
        action
      ],
    );
  }

  @override
  CupertinoNavigationBar createIosWidget(BuildContext context) {
    return new CupertinoNavigationBar(
      leading: leading,
      middle: title,
      trailing: action,
    );
  }
}