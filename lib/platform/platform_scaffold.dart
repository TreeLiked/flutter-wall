import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:iap_app/platform/base_platform_widget.dart';
import 'package:iap_app/platform/platform_appbar.dart';

/**
 * 脚手架
 */
class PlatformScaffold extends BasePlatformWidget<Scaffold, CupertinoPageScaffold> {
  PlatformScaffold({this.appBar, this.body});

  final PlatformAppBar appBar;
  final Widget body;

  @override
  Scaffold createAndroidWidget(BuildContext context) {
    return Scaffold(
      appBar: appBar.createAndroidWidget(context),
      body: body,
    );
  }

  @override
  CupertinoPageScaffold createIosWidget(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: appBar.createIosWidget(context),
      child: body,
    );
  }
}
