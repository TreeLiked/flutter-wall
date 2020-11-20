import 'package:flutter/material.dart';
import 'package:iap_app/component/square_tag.dart';
import 'package:iap_app/component/tweet/tweet_type_wrapper.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/util/string.dart';

class TweetCampusWrapper extends StatelessWidget {
  final int tweetId;
  final String institute;
  final String cla;
  final String tweetType;
  final bool anonymous;
  final bool displayType;

  TweetCampusWrapper(this.tweetId, this.institute, this.cla, this.tweetType, this.anonymous, {this.displayType = true});

  @override
  Widget build(BuildContext context) {
    bool insEmpty = StringUtil.isEmpty(institute);
    bool claEmpty = StringUtil.isEmpty(cla);

//    if (insEmpty && claEmpty) {
//      return Gaps.empty;
//    }
    String t = insEmpty ? cla : (claEmpty ? institute : '$institute，$cla');
    return Wrap(
      runSpacing: Dimens.gap_dp4,
        spacing: Dimens.gap_dp4,
      children: <Widget>[
        displayType ? TweetTypeWrapper(tweetId, tweetType): Gaps.empty,
        // displayType ? Gaps.hGap4: Gaps.empty,
        (insEmpty && claEmpty) || anonymous
            ? Gaps.empty
            : SquareTag(
                "$t",
                backgroundColor: Color(0xffEDF1F7),
                backgroundDarkColor: Colors.black12,
                textStyle: const TextStyle(color: ColorConstant.TWEET_NICK_COLOR, fontSize: Dimens.font_sp12),
                horizontalPadding: 15.0,
                verticalPadding: 5.0,
                roundRadius: 10.0,
                // prefixIcon: Icon(
                //   Icons.school,
                //   color: ColorConstant.TWEET_NICK_COLOR,
                //   size: 16.0,
                // ),
              )
      ],
    );
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        "$t",
        style: TextStyle(fontSize: Dimens.font_sp13, letterSpacing: 0, color: Colors.grey),
      ),
    );
  }
}
