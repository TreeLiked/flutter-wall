import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/base/base_plf_widget.dart';

/*
 * AppBar
 */
class PlatformAppBar
    extends BasePlatformWidget<AppBar, CupertinoNavigationBar> {
  final Widget title;
  final Widget leading;

  PlatformAppBar({this.title, this.leading});

  @override
  AppBar createAndroidWidget(BuildContext context) {
    return new AppBar(
      leading: leading,
      title: title,
    );
  }

  @override
  CupertinoNavigationBar createIosWidget(BuildContext context) {
    return new CupertinoNavigationBar(
      leading: leading,
      middle: title,
    );
  }
}
