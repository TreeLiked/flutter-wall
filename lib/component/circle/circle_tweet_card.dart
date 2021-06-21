import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/component/circle/circle_body_wrapper.dart';
import 'package:iap_app/component/circle/circle_media_wrapper.dart';
import 'package:iap_app/component/simgple_tag.dart';
import 'package:iap_app/component/tweet/tweet_body_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_campus_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_extra_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_header_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_image_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_link_wrapper.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/circle_account.dart';
import 'package:iap_app/model/account/tweet_account.dart';
import 'package:iap_app/model/circle/circle.dart';
import 'package:iap_app/model/circle/circle_tweet.dart';
import 'package:iap_app/model/gender.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/page/tweet_detail.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';

class CircleTweetCard extends StatelessWidget {
//  final recomKey = GlobalKey<RecommendationState>();

  final CircleTweet _circleTweet;

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

  final int indexInList;

  CircleTweetCard(this._circleTweet,
      {this.upClickable = true,
      this.downClickable = true,
      this.onClickComment,
      this.sendReplyCallback,
      this.displayLink = false,
      this.displayComment = false,
      this.displayInstitute = false,
      this.displayExtra = true,
      this.myNickClickable = true,
      this.needLeftProfile = true,
      this.displayType = true,
      this.moreWidget,
      this.indexInList = -1,
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
        padding: EdgeInsets.only(bottom: 5.0, top: indexInList == 0 ? 12.0 : 4.0, left: 15.0, right: 20.0),
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
//                     TweetSimpleHeader(
//                         _circleTweet.account,
//                       false,
//                       _circleTweet.sentTime,
//                       myNickClickable: this.myNickClickable,
//                       timeRight: this.needLeftProfile,
//                       official: false
//                     ),
                    CircleBodyWrapper(_circleTweet.body, maxLine: 3, fontSize: Dimens.font_sp15, height: 1.6),
                    CircleMediaWrapper(_circleTweet.id, medias: _circleTweet.medias),
                    // displayLink ? TweetLinkWrapper(tweet) : Gaps.empty,

                    // 是否仅圈子可见
                    _displayOnlyInCircleWidget(),
                    // 发布时间及作者信息
                    _displayCreatorInfoWidget(),
                    // Gaps.vGap8,

//                     TweetCampusWrapper(
//                       tweet.id,
//                       tweet.account.institute,
//                       tweet.account.cla,
//                       tweet.type,
//                       tweet.anonymous,
//                       displayType: displayType,
//                     ),
//                     displayExtra
//                         ? TweetCardExtraWrapper(
//                             displayPraise: displayPraise,
//                             displayComment: displayComment,
//                             tweet: tweet,
//                             canPraise: canPraise,
//                             onClickComment: onClickComment)
//                         : Gaps.empty,
// //                    displayComment && tweet.enableReply
// //                        ? TweetCommentWrapper(
// //                      tweet,
// //                      displayReplyContainerCallback: displayReplyContainerCallback,
// //                    )
// //                        : Gaps.empty,
// //                    displayComment ? Gaps.vGap25 : Gaps.vGap10,
//                     Gaps.line
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

  Widget _displayOnlyInCircleWidget() {
    if (_circleTweet.displayOnlyCircle) {
      return Gaps.empty;
    }
    return Container(
        padding: const EdgeInsets.only(bottom: 3.0),
        child: Text(
          '仅圈内可见',
          style: pfStyle.copyWith(color: ColorConstant.TWEET_DISABLE_COLOR_TEXT_COLOR),
        ));
  }

  Widget _displayCreatorInfoWidget() {
    return Container(
        padding: const EdgeInsets.only(bottom: 3.0),
        child: RichText(
            text: TextSpan(children: [
          TextSpan(
              text: '${_circleTweet.account.nick}',
              recognizer: TapGestureRecognizer()..onTap = (() => _goAccountDetail(context)),
              style: pfStyle.copyWith(
                  fontSize: Dimens.font_sp14, color: ColorConstant.getTweetNickColor(context))),
          TextSpan(
              text: ' 发布于 ${TimeUtil.getShortTime(_circleTweet.sentTime)}',
              style: pfStyle.copyWith(
                  fontSize: Dimens.font_sp14, color: ColorConstant.getTweetTimeColor(context))),
          // TextSpan(
          //     text: '${_circleTweet.displayOnlyCircle ? ' 仅圈内可见' : ''}',
          //     style: pfStyle.copyWith(
          //         fontSize: Dimens.font_sp14, color: ColorConstant.TWEET_DISABLE_COLOR_TEXT_COLOR)),
        ])));
  }

  void _forwardDetail(BuildContext context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => TweetDetail(
    //             this.tweet,
    //             newLink: !displayLink,
    //             onDelete: onDetailDelete,
    //           )),
    // );
  }

  void _goAccountDetail(BuildContext context) {
    CircleAccount account = _circleTweet.account;
    NavigatorUtils.push(
        context,
        Routes.accountProfile +
            Utils.packConvertArgs(
                {'nick': account.nick, 'accId': account.id, 'avatarUrl': account.avatarUrl}));
  }

  Widget _profileContainer() {
    Gender gender = Gender.parseGender(_circleTweet.account.gender);
    return GestureDetector(
        onTap: () => _goAccountDetail(context),
        child: Container(
            child: AccountAvatar(
          cache: true,
          avatarUrl: _circleTweet.account.avatarUrl ?? PathConstant.AVATAR_FAILED,
          size: SizeConstant.TWEET_PROFILE_SIZE,
          gender: gender,
        )));
  }

}
