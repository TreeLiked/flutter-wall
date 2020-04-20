import 'package:flutter/material.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';

class BottomSheetMultiSelect extends StatelessWidget {
  const BottomSheetMultiSelect({
    Key key,
    @required this.title,
    @required this.choices,
    this.cancelText = "取消",
  }) : super(key: key);

  final String title;
  final String cancelText;
  final List<MultiBottomSheetItem> choices;

  @override
  Widget build(BuildContext context) {
    int itemLen = choices.length;
    int lineCnt = itemLen + 1;

    double height = 52.0 + (itemLen * 54.0) + 54.0 + lineCnt * 2.0 + 5.0;
    return Material(
      child: SafeArea(
        child: SizedBox(height: height, child: Column(children: _renderItems(context))),
      ),
    );
  }

  List<Widget> _renderItems(BuildContext context) {
    List<Widget> widgets = List();
    widgets.add(SizedBox(
      height: 52.0,
      child: Center(
        child: Text(
          title ?? TextConstant.TEXT_UN_CATCH_ERROR,
          style: TextStyles.textSize14,
        ),
      ),
    ));
    widgets.add(Gaps.line);

    choices.forEach((item) {
      if (item != null) {
        widgets.add(item);
        widgets.add(Gaps.line);
      }
    });
    widgets.add(SizedBox(
      height: 54.0,
      width: double.infinity,
      child: FlatButton(
        textColor: Colours.text_gray,
        child: Text(cancelText, style: TextStyle(fontSize: Dimens.font_sp14)),
        onPressed: () {
          NavigatorUtils.goBack(context);
        },
      ),
    ));
    return widgets;
  }
}

class MultiBottomSheetItem extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Function onTap;

  MultiBottomSheetItem(
      {@required this.text, @required this.onTap, this.style = const TextStyle(fontSize: Dimens.font_sp14)});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54.0,
      width: double.infinity,
      child: FlatButton(
        textColor: style.color,
        child: Text(text, style: style),
        onPressed: () {
          NavigatorUtils.goBack(context);
          if (onTap != null) {
            onTap();
          }
        },
      ),
    );
  }
}
