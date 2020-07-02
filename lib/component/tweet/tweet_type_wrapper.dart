import 'package:flutter/material.dart';
import 'package:iap_app/component/square_tag.dart';
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
    TweetTypeEntity typeEntity = tweetTypeMap[t];
    return SquareTag(
      '${typeEntity.zhTag}',
      prefixIcon: Icon(
        typeEntity.iconData,
        size: 16.0,
        color: typeEntity.color,
      ),
      backgroundColor: typeEntity.color.withAlpha(40),
      textStyle: TextStyle(color: typeEntity.color, fontSize: 12.0),
      horizontalPadding: 15.0,
      verticalPadding: 5.0,
      roundRadius: 8.0,
    );
    return Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        margin: EdgeInsets.only(left: leftMargin, right: rightMargin),
        decoration: BoxDecoration(
//            gradient: new LinearGradient(
//                begin: Alignment.topLeft,
//                end: Alignment.bottomRight,
//                colors: ThemeUtils.isDark(context)
//                    ? [
//                        Colors.white.withAlpha(180),
//                        tweetTypeMap[t].color.withAlpha(100),
//                      ]
//                    : [
//                        tweetTypeMap[t].color.withAlpha(100),
//                        tweetTypeMap[t].color.withAlpha(100),
////                        tweetTypeMap[t].color,
//                      ]),
            borderRadius: reverseDir
                ? const BorderRadius.only(topRight: temp, bottomLeft: temp, topLeft: temp)
                : const BorderRadius.only(topRight: temp, bottomLeft: temp, bottomRight: temp)),
        child: Text(' # ' + (tweetTypeMap[t].zhTag), style: MyDefaultTextStyle.getTweetTypeStyle(context)));
  }
}
