import 'package:extended_text/extended_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/TweetRichWrapper.dart';
import 'package:iap_app/common-widget/my_future_builder.dart';
import 'package:iap_app/common-widget/tweet_link_text.dart';
import 'package:iap_app/common-widget/my_special_text_builder.dart';
import 'package:iap_app/common-widget/v_empty_view.dart';
import 'package:iap_app/component/tweet/tweet_body_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_comment_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_extra_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_header_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_image_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_link_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_type_wrapper.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/model/web_link.dart';
import 'package:iap_app/page/tweet_detail.dart';
import 'package:iap_app/part/recom.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/http_util.dart';
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
      this.displayPraise = false,
      this.displayComment = false,
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
        padding: const EdgeInsets.only(bottom: 5.0, top: 10.0, left: 5.0, right: 5.0),
        color: isDark ? Colours.dark_bg_color : Colors.white,
        child: GestureDetector(
          onTap: () => _forwardDetail(context),
          behavior: HitTestBehavior.translucent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TweetCardHeaderWrapper(
                tweet.account,
                tweet.anonymous,
                tweet.sentTime,
                canClick: upClickable,
                official: tweet.type == TweetTypeEntity.OFFICIAL.name,
              ),
              Gaps.vGap8,
              TweetTypeWrapper(tweet.type),
              Gaps.vGap5,
              TweetBodyWrapper(tweet.body, maxLine: 5, fontSize: Dimens.font_sp15, height: 1.6),
              TweetMediaWrapper(tweet.id, medias: tweet.medias, tweet: tweet),
              TweetLinkWrapper(tweet),
              Gaps.vGap8,
              displayExtra
                  ? TweetCardExtraWrapper(
                      displayPraise: displayPraise,
                      displayCommnet: displayComment,
                      tweet: tweet,
                      displayReplyContainerCallback: displayReplyContainerCallback)
                  : Gaps.empty,
              displayComment && tweet.enableReply
                  ? TweetCommentWrapper(
                      tweet,
                      displayReplyContainerCallback: displayReplyContainerCallback,
                    )
                  : Gaps.empty,
              displayComment ? Gaps.vGap25 : Gaps.vGap10,
              Gaps.line
            ],
          ),
        ));
    return wd;
  }

  void _forwardDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TweetDetail(this.tweet)),
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
}
