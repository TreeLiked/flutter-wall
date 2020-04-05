import 'package:flutter/material.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/theme_utils.dart';

class TweetTypeWrapper extends StatelessWidget {
  final String type;
  final double leftMargin;
  final double rightMargin;
  final bool reverseDir;

  const TweetTypeWrapper(this.type, {this.leftMargin = 0.0, this.rightMargin = 0.0, this.reverseDir = false});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    const Radius temp = Radius.circular(7.5);
    String t = type;
    if (tweetTypeMap[type] == null) {
      t = fallbackTweetType;
    }
    return Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        margin: EdgeInsets.only(left: leftMargin, right: rightMargin),
        decoration: BoxDecoration(
            gradient: new LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: ThemeUtils.isDark(context)
                    ? [
                        Colors.white.withAlpha(180),
                        tweetTypeMap[t].color.withAlpha(100),
                      ]
                    : [
                        tweetTypeMap[t].color,
                        tweetTypeMap[t].color.withAlpha(188),
                      ]),
            borderRadius: reverseDir
                ? const BorderRadius.only(topRight: temp, bottomLeft: temp, topLeft: temp)
                : const BorderRadius.only(topRight: temp, bottomLeft: temp, bottomRight: temp)),
        child: Text(' # ' + (tweetTypeMap[t].zhTag), style: MyDefaultTextStyle.getTweetTypeStyle(context)));
  }
}
