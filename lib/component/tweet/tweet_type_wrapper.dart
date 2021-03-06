import 'package:flutter/material.dart';
import 'package:iap_app/component/square_tag.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/theme_utils.dart';

class TweetTypeWrapper extends StatelessWidget {
  final int tweetId;
  final String type;
  final double leftMargin;
  final double rightMargin;
  final bool reverseDir;

  const TweetTypeWrapper(this.tweetId, this.type, {this.leftMargin = 0.0, this.rightMargin = 0.0, this.reverseDir = false});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    const Radius temp = Radius.circular(7.5);
    String t = type;
    if (tweetTypeMap[type] == null) {
      t = fallbackTweetType;
    }
    TweetTypeEntity typeEntity = tweetTypeMap[t];

    bool isDark = ThemeUtils.isDark(context);
    return GestureDetector(

      onTap: ()=> NavigatorUtils.push(context, Routes.tweetTypeInfProPlf + "?tweetId=$tweetId&tweetType=$type"),
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.3),
            decoration: BoxDecoration(
              color: isDark ? Colors.black12 : Color(0xffF3F6F8),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    decoration: BoxDecoration(
                        color: isDark ? typeEntity.color.withAlpha(139) : typeEntity.color,
                        shape: BoxShape.circle),
                    padding: const EdgeInsets.all(5.0),
                    child: Text("#",
                        style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.white, fontSize: Dimens.font_sp12))),
                Gaps.hGap4,
                Text('${typeEntity.zhTag}..',
                    style: TextStyle(color: typeEntity.color, fontSize: Dimens.font_sp12))
              ],
            )));
    // return SquareTag(
    //   '${typeEntity.zhTag}',
    //   prefixIcon: Container(
    //     decoration: BoxDecoration(
    //       shape: BoxShape.circle,
    //       color: Colors.lightBlueAccent
    //     ),
    //     child: Text("#", style: TextStyle(color: Colors.white),),
    //   ),
    //   backgroundColor: Colors.grey.withAlpha(100),
    //   textStyle: TextStyle(color: typeEntity.color, fontSize: 12.0),
    //   horizontalPadding: 15.0,
    //   verticalPadding: 5.0,
    //   roundRadius: 4.0,
    // );
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
