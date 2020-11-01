import 'package:flutter/material.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';

class SimpleConfirmBottomSheet extends StatelessWidget {
  const SimpleConfirmBottomSheet(
      {Key key, @required this.onTapDelete, this.tip = "确定执行此操作，此操作不可撤销", this.confirmText = "确认"})
      : super(key: key);

  final tip;
  final confirmText;
  final Function onTapDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: SizedBox(
            height: 191.2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15.0),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    "$tip",
                    softWrap: true,
                    maxLines: 5,
                    style: TextStyles.textSize16,
                  ),
                ),
                Gaps.line,
                SizedBox(
                  height: 54.0,
                  width: double.infinity,
                  child: FlatButton(
                    textColor: Theme.of(context).errorColor,
                    child: Text("$confirmText", style: TextStyle(fontSize: Dimens.font_sp14)),
                    onPressed: () {
                      NavigatorUtils.goBack(context);
                      onTapDelete();
                    },
                  ),
                ),
                Gaps.line,
                SizedBox(
                  height: 54.0,
                  width: double.infinity,
                  child: FlatButton(
                    textColor: Colours.text_gray,
                    child: const Text("取消", style: TextStyle(fontSize: Dimens.font_sp14)),
                    onPressed: () {
                      NavigatorUtils.goBack(context);
                    },
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
