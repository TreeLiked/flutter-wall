
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/base_dialog.dart';
import 'package:iap_app/common-widget/text_clickable_iitem.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';

class SimpleConfirmDialog extends StatefulWidget {
  final String title;
  final String content;
  ClickableText leftItem;
  ClickableText rightItem;

  SimpleConfirmDialog(this.title, this.content, {Key key, this.leftItem, this.rightItem}) : super(key: key);

  @override
  _SimpleConfirm createState() => _SimpleConfirm();
}

class _SimpleConfirm extends State<SimpleConfirmDialog> {
  @override
  Widget build(BuildContext context) {
//    if (Platform.isIOS) {
//      List<CupertinoDialogAction> actions = List();
//      if (widget.leftItem == null) {
//        actions.add(CupertinoDialogAction(
//          child: Text('确认'),
//          onPressed: () {
//            Navigator.of(context).pop();
//          },
//        ));
//      } else {
//        actions.add(CupertinoDialogAction(
//            child: Text(widget.leftItem.text),
//            onPressed: () => widget.leftItem.onTap()));
//      }
//      if (widget.rightItem != null) {
//        actions.add(CupertinoDialogAction(
//            child: Text(widget.rightItem.text),
//            onPressed: () => widget.rightItem.onTap()));
//      }
//      return CupertinoAlertDialog(
//          title: Text(widget.title ?? "提示"),
//          content: Text(widget.content ?? "未知错误"),
//          actions: actions);
//    } else {
    bool showCancel = true;
    if (widget.leftItem == null || widget.rightItem == null) {
      showCancel = false;
      widget.rightItem = ClickableText('确认', () {
        NavigatorUtils.goBack(context);
      });
      widget.leftItem = null;
    }
    return BaseDialog(
      title: widget.title ?? "提示",
      showCancel: showCancel,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(widget.content ?? "未知错误", style: TextStyles.textSize14),
      ),
      leftText: widget.leftItem == null ? "取消" : widget.leftItem.text,
      rightText: widget.rightItem == null ? "确认" : widget.rightItem.text,
      onPressed: () {
        if (widget.rightItem != null) {
          widget.rightItem.onTap();
        }
      },
    );
//    }
  }
}
