import 'package:flutter/material.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/component/tweet/tweet_body_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_campus_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_extra_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_header_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_image_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_link_wrapper.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/tweet_account.dart';
import 'package:iap_app/model/gender.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/page/tweet_detail.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/util/common_util.dart';
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
  final onClickComment;
  final sendReplyCallback;

  final bool displayPraise;
  final bool canPraise;
  final bool displayComment;
  final bool displayLink;
  final bool displayExtra;
  final bool displayInstitute;
  final Widget moreWidget;
  final bool myNickClickable;
  final bool needLeftProfile;
  final bool displayType;
  BuildContext context;
  bool isDark;
  final Function onDetailDelete;

  TweetCard2(this.tweet,
      {this.upClickable = true,
      this.downClickable = true,
      this.onClickComment,
      this.sendReplyCallback,
      this.displayPraise = false,
      this.displayLink = false,
      this.displayComment = false,
      this.displayInstitute = false,
      this.displayExtra = true,
      this.canPraise = false,
      this.myNickClickable = true,
      this.needLeftProfile = true,
      this.displayType = true,
      this.moreWidget,
      this.onDetailDelete}) {
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
        padding: const EdgeInsets.only(bottom: 5.0, top: 4.0, left: 15.0, right: 20.0),
        color: isDark ? Colours.dark_bg_color : Color(0xfffffeff),
        child: GestureDetector(
          onTap: () => _forwardDetail(context),
          behavior: HitTestBehavior.translucent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              this.needLeftProfile
                  ? Flexible(
                      flex: 1,
                      child:
                          Container(padding: const EdgeInsets.only(right: 15.0), child: _profileContainer()),
                    )
                  : Gaps.empty,
              Flexible(
                flex: 5,
                fit: FlexFit.loose,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
//                    TweetTypeWrapper(tweet.type),
                    TweetSimpleHeader(
                      tweet.account,
                      tweet.anonymous,
                      tweet.sentTime,
                      myNickClickable: this.myNickClickable,
                      timeRight: this.needLeftProfile,
                      // official: tweet.account.off,
                    ),
                    TweetBodyWrapper(tweet.body, maxLine: 3, fontSize: Dimens.font_sp15, height: 1.6),
                    TweetMediaWrapper(tweet.id, medias: tweet.medias, tweet: tweet),
                    displayLink ? TweetLinkWrapper(tweet) : Gaps.empty,
                    Gaps.vGap8,

                    TweetCampusWrapper(
                      tweet.id,
                      tweet.account.institute,
                      tweet.account.cla,
                      tweet.type,
                      tweet.anonymous,
                      displayType: displayType,
                    ),
                    displayExtra
                        ? TweetCardExtraWrapper(
                            displayPraise: displayPraise,
                            displayComment: displayComment,
                            tweet: tweet,
                            canPraise: canPraise,
                            onClickComment: onClickComment)
                        : Gaps.empty,
//                    displayComment && tweet.enableReply
//                        ? TweetCommentWrapper(
//                      tweet,
//                      displayReplyContainerCallback: displayReplyContainerCallback,
//                    )
//                        : Gaps.empty,
//                    displayComment ? Gaps.vGap25 : Gaps.vGap10,
                    Gaps.line
                  ],
                ),
              )
            ],
          ),
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: <Widget>[
//              TweetCardHeaderWrapper(
//                tweet.account,
//                tweet.anonymous,
//                tweet.sentTime,
//                canClick: upClickable,
//                official: tweet.type == TweetTypeEntity.OFFICIAL.name,
//              ),
//              Gaps.vGap8,
//              TweetTypeWrapper(tweet.type),
//              Gaps.vGap5,
//              TweetBodyWrapper(tweet.body, maxLine: 5, fontSize: Dimens.font_sp15, height: 1.6),
//              TweetMediaWrapper(tweet.id, medias: tweet.medias, tweet: tweet),
//              displayLink ? TweetLinkWrapper(tweet) : Gaps.empty,
//              Gaps.vGap8,
//              TweetCampusWrapper(tweet.account.institute, tweet.account.cla),
//              displayExtra
//                  ? TweetCardExtraWrapper(
//                      displayPraise: displayPraise,
//                      displayCommnet: displayComment,
//                      tweet: tweet,
//                      displayReplyContainerCallback: displayReplyContainerCallback)
//                  : Gaps.empty,
//              displayComment && tweet.enableReply
//                  ? TweetCommentWrapper(
//                      tweet,
//                      displayReplyContainerCallback: displayReplyContainerCallback,
//                    )
//                  : Gaps.empty,
//              displayComment ? Gaps.vGap25 : Gaps.vGap10,
//              Gaps.line
//            ],
//          ),
        ));
    return wd;
  }

  void _forwardDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TweetDetail(
                this.tweet,
                newLink: !displayLink,
                onDelete: onDetailDelete,
              )),
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

  Widget _profileContainer() {
    bool anonymous = tweet.anonymous;
    Gender gender = anonymous ? Gender.UNKNOWN : Gender.parseGender(tweet.account.gender);
    return GestureDetector(
        onTap: () => anonymous || !myNickClickable ? null : goAccountDetail2(context, tweet.account, true),
        child: Container(
            child: AccountAvatar(
          cache: true,
          avatarUrl: !anonymous
              ? (tweet.account.avatarUrl ?? PathConstant.AVATAR_FAILED)
              : PathConstant.ANONYMOUS_PROFILE,
          size: SizeConstant.TWEET_PROFILE_SIZE,
          gender: gender,
        )));
  }

  void goAccountDetail2(BuildContext context, TweetAccount account, bool up) {
    NavigatorUtils.push(
        context,
        Routes.accountProfile +
            Utils.packConvertArgs(
                {'nick': account.nick, 'accId': account.id, 'avatarUrl': account.avatarUrl}));
  }
}
