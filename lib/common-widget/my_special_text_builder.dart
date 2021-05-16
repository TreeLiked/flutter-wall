import 'dart:ui';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/painting/text_style.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/tweet_at_text.dart';
import 'package:iap_app/common-widget/tweet_link_text.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/routes/fluro_navigator.dart';

class MySpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  /// whether show background for @somebody
  final bool showAtBackground;
  final Function onTapCb;

  MySpecialTextSpanBuilder({this.showAtBackground: false, this.onTapCb});

  @override
  SpecialText createSpecialText(String flag, {TextStyle textStyle, onTap, int index}) {
    // TODO: implement createSpecialText

    if (flag == null || flag == "") return null;

    ///index is end index of start flag, so text start index should be index-(flag.length-1)
    if (isStart(flag, TweetLinkText.flag)) {
      return TweetLinkText(
          TextStyle(
              color: Colors.blue,
              wordSpacing: 1.5,
              letterSpacing: 0,
              fontSize: Dimens.font_sp15,
              decoration: TextDecoration.underline),
          onTap,
          onTapText: (String text) => NavigatorUtils.goWebViewPage(Application.context, text, text.trim()),
          start: index - (TweetLinkText.flag.length - 1),
          showAtBackground: showAtBackground);
    } else if (isStart(flag, TweetAtText.flag)) {
      return TweetAtText(
          TextStyle(color: Color(0xffFD9701), wordSpacing: 1.5, letterSpacing: 0, fontSize: Dimens.font_sp16),
          onTap,
          start: index - (TweetAtText.flag.length - 1),
          showAtBackground: showAtBackground);
    }
    return null;
  }

//  MyLinkTextSpanBuilder(
//      {this.showAtBackground: false, this.type: BuilderType.extendedText});
//
//  @override
//  TextSpan build(String data, {TextStyle textStyle, onTap}) {
//    var textSpan = super.build(data, textStyle: textStyle, onTap: onTap);
//    return textSpan;
//  }
//
//  @override
//  SpecialText createSpecialText(String flag,
//      {TextStyle textStyle, SpecialTextGestureTapCallback onTap, int index}) {

//  }
}
