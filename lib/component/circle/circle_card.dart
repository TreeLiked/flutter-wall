import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/component/stack_avatar.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/model/account/tweet_account.dart';
import 'package:iap_app/model/circle/circle.dart';
import 'package:iap_app/page/circle/circle_home.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/theme_utils.dart';

class CircleCard extends StatelessWidget {
//  final recomKey = GlobalKey<RecommendationState>();
  static const double TOP_RADIUS = 10.0;

  final Circle _circle;
  final int _index;

  BuildContext _context;
  bool isDark = false;
  bool hasDesc = false;
  double height = Random().nextInt(20) + 100.0;

  CircleCard(this._circle, this._index) {}

  @override
  Widget build(BuildContext context) {
    this._context = context;
    isDark = ThemeUtils.isDark(context);
    return cardContainer(context);
  }

  Widget cardContainer(BuildContext context) {
    Widget wd = Container(
        constraints: BoxConstraints(minHeight: 150),
        decoration: BoxDecoration(
          // boxShadow: [
          //   BoxShadow(
          //       color: Color(0xffFFFFF0), offset: Offset(1.0, 0.0), blurRadius: 2.0, spreadRadius: 0.0),
          // ],
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(TOP_RADIUS),
              topRight: Radius.circular(TOP_RADIUS),
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0)),
        ),
        // padding: EdgeInsets.only(bottom: 5.0, top: 10.0, left: 15.0, right: 20.0),
        child: GestureDetector(
            onTap: () => _forwardHome(context),
            behavior: HitTestBehavior.translucent,
            child: Column(
              children: [
                Container(
                  height: _circle.higher ? 160 : 120,
                  width: double.infinity,
                  // width: 100,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(TOP_RADIUS), topRight: Radius.circular(TOP_RADIUS)),
                      image: DecorationImage(
                          image: CachedNetworkImageProvider(_circle.cover), fit: BoxFit.cover)),
                  child: Stack(
                    children: [
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
                CircleCardBanner(_circle)
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

class CircleCardBanner extends StatefulWidget {
  final Circle _circle;

  CircleCardBanner(this._circle);

  @override
  State<StatefulWidget> createState() {
    return _CircleCardBannerState();
  }
}

class _CircleCardBannerState extends State<CircleCardBanner> {
  bool isDark = false;
  Color _bannerColor = Colors.white;
  bool _useWhiteTextColor = false;

  // void _calAndSetColors() async {
  //   PaletteGenerator paletteGenerator =
  //       await PaletteGenerator.fromImageProvider(CachedNetworkImageProvider(widget._circle.cover));
  //   Color gradientOne = paletteGenerator.colors.toList()[0];
  //   Color gradientTwo = paletteGenerator.colors.toList()[1];
  //   bool useWhiteTextColor = useWhiteForeground(gradientOne);
  //   setState(() {
  //     _bannerColor = gradientTwo;
  //     _useWhiteTextColor = false;
  //   });
  // }

  void _calAndSetFontColor() async {}

  @override
  void initState() {
    super.initState();
    // _calAndSetColors();
  }

  @override
  Widget build(BuildContext context) {
    isDark = ThemeUtils.isDark(context);

    Circle _circle = widget._circle;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 5.0, bottom: 10.0, left: 10.0, right: 10.0),
      decoration: BoxDecoration(
        color: isDark ? Color(0xff1C1C1C) : Colors.white,
        borderRadius:
            BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('# ${_circle.brief}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pfStyle.copyWith(
                  fontSize: Dimens.font_sp16p5, color: ColorConstant.getTweetBodyColor(isDark))),
          // Gaps.vGap5,
          // Text('${_circle.desc}',
          //     maxLines: 2, overflow: TextOverflow.ellipsis, style: pfStyle.copyWith(color: Colors.blueGrey)),
          Gaps.vGap5,
          Text('${_circle.view}人看过，${_circle.participants}人已加入',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pfStyle.copyWith(color: Colors.grey, fontSize: Dimens.font_sp13p5)),
          Gaps.vGap10,
          Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              StackAvatars(
                [
                  Application.getAccount.avatarUrl,
                  "https://tva1.sinaimg.cn/large/008eGmZEgy1gob9762hfjj30pr0n5wk5.jpg",
                  "https://tva1.sinaimg.cn/large/008eGmZEgy1go2fiz9279j30u01sxapv.jpg",
                  "https://tva1.sinaimg.cn/large/008eGmZEgy1go1you4ia4j30qo0qotay.jpg",
                  "https://tva1.sinaimg.cn/large/008eGmZEgy1go11zesr83j30go0fmq6w.jpg",
                  "https://tva1.sinaimg.cn/large/008eGmZEgy1go1yns7qstj30lr0ez40j.jpg"
                ],
                max: 3,
                size: 26,
                showFactor: 0.6,
                whitePadding: !isDark,
              ),
              Gaps.hGap10,
              Text(
                "刚刚加入..",
                style: pfStyle.copyWith(fontSize: Dimens.font_sp14, color: Colors.grey),
              )
            ],
          )
        ],
      ),
    );
  }
}
