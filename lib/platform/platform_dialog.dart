import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:iap_app/platform/base_platform_widget.dart';
class PlatformAlertDialog extends BasePlatformWidget<AlertDialog, CupertinoAlertDialog> {
  final Widget title;
  final Widget content;
  final List<Widget> actions;

  PlatformAlertDialog({this.title, this.content, this.actions});

  @override
  AlertDialog createAndroidWidget(BuildContext context) {
    return new AlertDialog(
      title: title,
      content: content,
      actions: actions,
    );
  }

  @override
  CupertinoAlertDialog createIosWidget(BuildContext context) {
    return new CupertinoAlertDialog(
      title: title,
      content: content,
      actions: actions,
    );
  }
}