import 'package:flutter/material.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';

class BottomSheetConfirm extends StatelessWidget {
  const BottomSheetConfirm({
    Key key,
    this.title,
    this.optChoice,
    this.optColor = Colors.red,
    this.cancelText = "取消",
    @required this.onTapOpt,
  }) : super(key: key);

  final String title;
  final String optChoice;
  final String cancelText;
  final Color optColor;

  final Function onTapOpt;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: SizedBox(
            height: 161.2,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 52.0,
                  child: Center(
                    child: Text(
                      title ?? TextConstant.TEXT_UN_CATCH_ERROR,
                      style: TextStyles.textSize14,
                    ),
                  ),
                ),
                Gaps.line,
                SizedBox(
                  height: 54.0,
                  width: double.infinity,
                  child: FlatButton(
                    textColor: optColor,
                    child: Text(optChoice, style: TextStyle(fontSize: Dimens.font_sp14)),
                    onPressed: () {
                      NavigatorUtils.goBack(context);
                      if (onTapOpt != null) {
                        onTapOpt();
                      }
                    },
                  ),
                ),
                Gaps.line,
                SizedBox(
                  height: 54.0,
                  width: double.infinity,
                  child: FlatButton(
                    textColor: Colours.text_gray,
                    child: Text(cancelText, style: TextStyle(fontSize: Dimens.font_sp14)),
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
