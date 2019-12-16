import 'package:flutter/material.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';

/// design/4商品/index.html#artboard2
class TweetDeleteBottomSheet extends StatelessWidget {
  const TweetDeleteBottomSheet({
    Key key,
    @required this.onTapDelete,
  }) : super(key: key);

  final Function onTapDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: SizedBox(
            height: 161.2,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 52.0,
                  child: const Center(
                    child: const Text(
                      "是否确认删除，此操作不可撤销",
                      style: TextStyles.textSize14,
                    ),
                  ),
                ),
                Gaps.line,
                SizedBox(
                  height: 54.0,
                  width: double.infinity,
                  child: FlatButton(
                    textColor: Theme.of(context).errorColor,
                    child: const Text("确认删除",
                        style: TextStyle(fontSize: Dimens.font_sp14)),
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
                    child: const Text("取消",
                        style: TextStyle(fontSize: Dimens.font_sp14)),
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
