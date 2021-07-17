import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/model/account/tweet_account.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/theme_utils.dart';

class StackImageContainer extends StatelessWidget {
  static const double TOP_RADIUS = 6.0;

  final List<Widget> positionedWidgets;
  final Widget centerWidget;
  final double centerWidgetPadding;

  final String imgUrl;
  final double height;
  final double width;
  final bool hasShadow;

  final Function onTap;

  bool isDark = false;
  bool hasDesc = false;

  StackImageContainer(this.imgUrl,
      {this.positionedWidgets,
      this.centerWidget,
      this.centerWidgetPadding = 15.0,
      this.height = 60,
      this.hasShadow = true,
      this.onTap,
      this.width = 60});

  @override
  Widget build(BuildContext context) {
    if (CollectionUtil.isListEmpty(positionedWidgets) && centerWidget == null) {
      return Gaps.empty;
    }
    isDark = ThemeUtils.isDark(context);
    return cardContainer(context);
  }

  List<Widget> _getRenderItems() {
    List<Widget> widgets = List();
    if (!CollectionUtil.isListEmpty(positionedWidgets)) {
      widgets.addAll(positionedWidgets);
    }
    widgets.add(ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(TOP_RADIUS)),
      //使图片模糊区域仅在子组件区域中
      child: BackdropFilter(
        //背景过滤器
        filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0), //设置图片模糊度
        child: Container(
          height: height,
          width: width,
          decoration: hasShadow
              ? BoxDecoration(
                  color: isDark ? Colors.black45 : Colors.black26,
                )
              : null,
          child: centerWidget == null
              ? Gaps.empty
              : Center(
                  child: Padding(
                  padding: EdgeInsets.all(centerWidgetPadding),
                  child: centerWidget,
                )),
        ),
      ),
    ));
    return widgets;
  }

  Widget cardContainer(BuildContext context) {
    Widget wd = Container(
        height: height,
        width: width,
        // padding: EdgeInsets.only(bottom: 5.0, top: 10.0, left: 15.0, right: 20.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(TOP_RADIUS))),
        child: GestureDetector(
            onTap: () {
              if (onTap != null) {
                onTap();
              }
            },
            behavior: HitTestBehavior.translucent,
            child: Column(children: [
              Container(
                  height: height,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(TOP_RADIUS)),
                      image: DecorationImage(image: CachedNetworkImageProvider(imgUrl), fit: BoxFit.cover)),
                  child: Stack(
                    children: _getRenderItems(),
                  ))
            ])));
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
    return wd;
  }

  void _forwardHome(BuildContext context) {}

  Widget _profileContainer() {
    // bool anonymous = tweet.anonymous;
    // Gender gender = anonymous ? Gender.UNKNOWN : Gender.parseGender(tweet.account.gender);
    // return GestureDetector(
    //     onTap: () => anonymous || !myNickClickable ? null : goAccountDetail2(context, tweet.account, true),
    //     child: Container(
    //         child: AccountAvatar(
    //       cache: true,
    //       avatarUrl: !anonymous
    //           ? (tweet.account.avatarUrl ?? PathConstant.AVATAR_FAILED)
    //           : PathConstant.ANONYMOUS_PROFILE,
    //       size: SizeConstant.TWEET_PROFILE_SIZE,
    //       gender: gender,
    //     )));
  }

  void goAccountDetail2(BuildContext context, TweetAccount account, bool up) {
    // NavigatorUtils.push(
    //     context,
    //     Routes.accountProfile +
    //         Utils.packConvertArgs(
    //             {'nick': account.nick, 'accId': account.id, 'avatarUrl': account.avatarUrl}));
  }
}
