import 'package:flutter/material.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/v_empty_view.dart';
import 'package:iap_app/component/tweet/tweet_comment_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_extra_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_header_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_image_wrapper.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/page/tweet_detail.dart';
import 'package:iap_app/part/recom.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';

class TweetCard2 extends StatelessWidget {
//  final recomKey = GlobalKey<RecommendationState>();

  final BaseTweet tweet;

  double sw;
  double sh;
  double maxWidthSinglePic;

  // space header 可点击
  final bool upClickable;

  // 点赞账户可点击
  final bool downClickable;

  // 点击回复框，回调home page textField
  final displayReplyContainerCallback;
  final sendReplyCallback;

  final bool displayPraise;
  final bool displayComment;
  final bool displayExtra;
  final Widget moreWidget;

  BuildContext context;
  bool isDark;

  TweetCard2(this.tweet,
      {this.upClickable = true,
      this.downClickable = true,
      this.displayReplyContainerCallback,
      this.sendReplyCallback,
      this.displayPraise = true,
      this.displayComment = true,
      this.displayExtra = true,
      this.moreWidget}) {
    this.sw = Application.screenWidth;
    this.sh = Application.screenHeight;
    this.maxWidthSinglePic = sw * 0.75;
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    isDark = ThemeUtils.isDark(context);
    return cardContainer2(context);
  }

  Widget cardContainer2(BuildContext context) {
    Widget wd = Container(
        padding: const EdgeInsets.only(bottom: 0, top: 5),
        color: isDark ? Colours.dark_bg_color : Colors.white,
        child: GestureDetector(
          onTap: () => _forwardDetail(context),
          behavior: HitTestBehavior.translucent,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TweetCardHeaderWrapper(
                      tweet.account,
                      tweet.anonymous,
                      tweet.gmtCreated,
                      canClick: upClickable,
                      official: tweet.type == TweetTypeEntity.OFFICIAL.name,
                    ),
                    Gaps.vGap8,
                    _typeContainer(context),
                    Gaps.vGap5,
                    _bodyContainer(context),
                    TweetMediaWrapper(medias: tweet.medias),
                    Gaps.vGap8,
                    displayPraise
                        ? TweetCardExtraWrapper(
                            tweet: tweet, displayReplyContainerCallback: displayReplyContainerCallback)
                        : VEmptyView(0),
                    Gaps.vGap8,
                    displayComment && tweet.enableReply
                        ? TweetCommentWrapper(
                            tweet,
                            displayReplyContainerCallback: displayReplyContainerCallback,
                          )
                        : VEmptyView(0),
                    displayComment ? Gaps.vGap30 : Gaps.vGap10,
                    Gaps.line
                  ],
                ),
              ),
            ],
          ),
        ));
    return wd;
  }

  void _forwardDetail(BuildContext context) {
    Navigator.push(
      context,

      MaterialPageRoute(builder: (context) => TweetDetail(this.tweet)),
//      MaterialPageRoute(builder: (context) => TweetDetail(this.tweet)),
    );
  }

  void goAccountDetail(BuildContext context, Account account, bool up) {
    if ((up && upClickable) || (!up && downClickable)) {
      NavigatorUtils.push(
          context,
          Routes.accountProfile +
              Utils.packConvertArgs(
                  {'nick': account.nick, 'accId': account.id, 'avatarUrl': account.avatarUrl}));
    }
  }

  Widget _bodyContainer(BuildContext context) {
    String body = tweet.body;
    return !StringUtil.isEmpty(body)
        ? Container(
            child: Wrap(children: <Widget>[
            Row(children: <Widget>[
              Expanded(
                  child: Text(body.trim(),
                      softWrap: true,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 10,
                      style: MyDefaultTextStyle.getMainTextBodyStyle(isDark)))
            ])
          ]))
        : Container(height: 0);
  }

  Widget _typeContainer(BuildContext context) {
    const Radius temp = Radius.circular(7.5);
    return Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
            color: (!ThemeUtils.isDark(context)
                    ? tweetTypeMap[tweet.type].color
                    : tweetTypeMap[tweet.type].color.withAlpha(100)) ??
                Colors.blueAccent,
            borderRadius: BorderRadius.only(topRight: temp, bottomLeft: temp, bottomRight: temp)),
        child: Text(' # ' + (tweetTypeMap[tweet.type].zhTag ?? TextConstant.TEXT_UN_CATCH_TWEET_TYPE),
            style: MyDefaultTextStyle.getTweetTypeStyle(context)));
  }
}
