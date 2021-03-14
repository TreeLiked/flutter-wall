import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/component/satck_img_conatiner.dart';
import 'package:iap_app/component/simgple_tag.dart';
import 'package:iap_app/component/stack_avatar.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/model/account/tweet_account.dart';
import 'package:iap_app/model/circle/circle.dart';
import 'package:iap_app/page/circle/circle_home.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:palette_generator/palette_generator.dart';

class CircleSwiperBanner extends StatelessWidget {
  static const double TOP_RADIUS = 6.0;

  final Circle _circle;

  BuildContext _context;
  bool isDark = false;
  bool hasDesc = false;

  CircleSwiperBanner(this._circle) {}

  @override
  Widget build(BuildContext context) {
    this._context = context;
    isDark = ThemeUtils.isDark(context);
    return StackImageContainer(
      _circle.cover,
      height: 120,
      width: double.infinity,
      centerWidget: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text('${_circle.desc}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: pfStyle.copyWith(
                color: ColorConstant.MAIN_BAR_COLOR, fontSize: Dimens.font_sp14, letterSpacing: 1.1)),
      ),
      positionedWidgets: [
        Positioned(
            child: SimpleTag("美食",
                round: true, radius: 10.0, bgColor: Colors.white70, textColor: Colors.black87),
            left: 5.0,
            top: 5.0),
      ],
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CircleHome(_circle)),
      ),
    );
    return cardContainer(context);
  }

  Widget cardContainer(BuildContext context) {
    Widget wd = Container(
        height: 120,
        // padding: EdgeInsets.only(bottom: 5.0, top: 10.0, left: 15.0, right: 20.0),
        child: GestureDetector(
            onTap: () => _forwardHome(context),
            behavior: HitTestBehavior.translucent,
            child: Column(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(TOP_RADIUS)),
                      image: DecorationImage(
                          image: CachedNetworkImageProvider(_circle.cover), fit: BoxFit.cover)),
                  child: Stack(
                    children: [
                      Positioned(
                          child: SimpleTag("美食",
                              round: true, radius: 10.0, bgColor: Colors.white70, textColor: Colors.black87),
                          left: 5.0,
                          top: 5.0),
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(TOP_RADIUS), topRight: Radius.circular(TOP_RADIUS)),
                        //使图片模糊区域仅在子组件区域中
                        child: BackdropFilter(
                          //背景过滤器
                          filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0), //设置图片模糊度
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black54 : Colors.black26,
                            ),
                            child: Center(
                                child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text('${_circle.desc}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: pfStyle.copyWith(
                                      color: ColorConstant.MAIN_BAR_COLOR,
                                      fontSize: Dimens.font_sp14,
                                      letterSpacing: 1.1)),
                            )),
                          ),
                        ),
                      )
//                       BackdropFilter(
//                         filter: ImageFilter.blur(
//                           sigmaY: 20,
//                           sigmaX: 20,
//                         ),
//                         child: Container(
//                           width: double.infinity,
//                           height: double.infinity,
//                           decoration: BoxDecoration(
//                             color: ThemeUtils.isDark(context) ? Colors.black54 : Colors.white70,
// //                  borderRadius: BorderRadius.all(Radius.circular(85.0)),
//                           ),
//                         ),
//                       )
                    ],
                  ),
                ),
              ],
            )
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

  void _forwardHome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CircleHome(_circle)),
    );
  }

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
