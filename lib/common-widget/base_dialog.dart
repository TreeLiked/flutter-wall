import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/v_empty_view.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/theme_utils.dart';

/// 自定义dialog的模板
class BaseDialog extends StatelessWidget {
  const BaseDialog(
      {Key key,
      this.title,
      this.leftText = "取消",
      this.rightText = "确认",
      this.onPressed,
      this.showCancel = true,
      this.hiddenTitle: false,
      @required this.child})
      : super(key: key);

  final String title;
  final Function onPressed;
  final Widget child;
  final bool hiddenTitle;
  final bool showCancel;
  final String leftText;
  final String rightText;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //创建透明层
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      // 键盘弹出收起动画过渡
      body: AnimatedContainer(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).viewInsets.bottom,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInCubic,
        child: Container(
            decoration: BoxDecoration(
              color: ThemeUtils.getDialogBackgroundColor(context),
              borderRadius: BorderRadius.circular(8.0),
            ),
            width: 270.0,
            padding: const EdgeInsets.only(top: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Offstage(
                  offstage: hiddenTitle,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      hiddenTitle ? "" : title,
                      style: TextStyles.textBold18,
                    ),
                  ),
                ),
                Flexible(child: child),
                Gaps.vGap8,
                Gaps.line,
                Row(
                  children: <Widget>[
                    showCancel
                        ? Expanded(
                            child: SizedBox(
                              height: 48.0,
                              child: FlatButton(
                                child: Text(
                                  leftText,
                                  style: TextStyle(fontSize: Dimens.font_sp15),
                                ),
                                textColor: Colours.text_gray,
                                onPressed: () {
                                  NavigatorUtils.goBack(context);
                                },
                              ),
                            ),
                          )
                        : VEmptyView(0),
                    const SizedBox(
                      height: 48.0,
                      width: 0.6,
                      child: const VerticalDivider(),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 48.0,
                        child: FlatButton(
                          child: Text(
                            rightText,
                            style: TextStyle(fontSize: Dimens.font_sp15),
                          ),
                          textColor: Theme.of(context).primaryColor,
                          onPressed: () {
                            onPressed();
                          },
                        ),
                      ),
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}
