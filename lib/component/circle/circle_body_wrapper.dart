import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iap_app/common-widget/my_special_text_builder.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/string.dart';

class CircleBodyWrapper extends StatelessWidget {
  final String body;
  final double fontSize;
  final double height;
  final bool selectable;
  final int maxLine;

  const CircleBodyWrapper(this.body,
      {this.fontSize = Dimens.font_sp15, this.maxLine = -1, this.height = -1, this.selectable = false});

  @override
  Widget build(BuildContext context) {
    if (StringUtil.isEmpty(body)) {
      return Gaps.empty;
    }
    return Container(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: ExtendedText("${body.contains("@") ? body : body.trimRight()}",
            maxLines: maxLine == -1 ? null : maxLine,
            softWrap: true,
            textAlign: TextAlign.left,
            specialTextSpanBuilder: MySpecialTextSpanBuilder(
                showAtBackground: false,
                onTapCb: (String text) {
                  if (text != null && text.length > 0) {
                    if (text.startsWith("http")) {
                      NavigatorUtils.goWebViewPage(context, text, text.trim());
                    }
                  }
                }),
            selectionEnabled: selectable,
            overflowWidget: maxLine == -1
                ? null
                : TextOverflowWidget(
                    fixedOffset: Offset.zero,
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(".. 查看全部",
                              style: TextStyle(color: ColorConstant.getTweetNickColor(context), fontSize: Dimens.font_sp13))
                        ])),
            style: height == -1
                ? MyDefaultTextStyle.getTweetBodyStyle(context)
                : MyDefaultTextStyle.getTweetBodyStyle(context).copyWith(height: height)));
  }
}
