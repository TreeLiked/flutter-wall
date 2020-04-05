import 'package:flutter/material.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/theme_utils.dart';

class TitleItemWrapper extends StatelessWidget {
  final Text titleText;
  final Text subTitleText;
  final Widget suffixWidget;

  TitleItemWrapper(this.titleText, {this.subTitleText, this.suffixWidget});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          titleText,
          Gaps.hGap4,
          subTitleText ?? Gaps.empty,
          suffixWidget != null
              ? Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: suffixWidget,
                  ),
                )
              : Gaps.empty
        ]);
  }
}
