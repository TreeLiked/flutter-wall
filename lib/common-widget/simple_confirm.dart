import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/base_dialog.dart';
import 'package:iap_app/common-widget/text_clickable_iitem.dart';
import 'package:iap_app/res/styles.dart';

class SimpleConfirmDialog extends StatefulWidget {
  final String title;
  final String content;
  ClickableText leftItem;
  ClickableText rightItem;

  SimpleConfirmDialog(this.title, this.content,
      {Key key, this.leftItem, this.rightItem})
      : super(key: key);
  @override
  _SimpleConfirm createState() => _SimpleConfirm();
}

class _SimpleConfirm extends State<SimpleConfirmDialog> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      List<CupertinoDialogAction> actions = List();
      if (widget.leftItem == null) {
        actions.add(CupertinoDialogAction(
          child: Text('确认'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ));
      } else {
        actions.add(CupertinoDialogAction(
            child: Text(widget.leftItem.text),
            onPressed: () => widget.leftItem.onTap()));
      }
      if (widget.rightItem != null) {
        actions.add(CupertinoDialogAction(
            child: Text(widget.rightItem.text),
            onPressed: () => widget.rightItem.onTap()));
      }
      return CupertinoAlertDialog(
          title: Text(widget.title ?? "提示"),
          content: Text(widget.content ?? "未知错误"),
          actions: actions);
    } else {
      return BaseDialog(
        title: widget.title ?? "提示",
        showCancel: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(widget.content ?? "未知错误", style: TextStyles.textSize16),
        ),
        leftText: widget.leftItem == null ? "取消" : widget.leftItem.text,
        rightText: widget.rightItem == null ? "确认" : widget.rightItem.text,
        onPressed: () {
          widget.rightItem.onTap();
        },
      );
    }
  }
}
