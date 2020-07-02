import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/imgae_container.dart';
import 'package:iap_app/common-widget/my_special_text_builder.dart';
import 'package:iap_app/global/oss_canstant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/hot_tweet.dart';
import 'package:iap_app/model/media.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/part/stateless.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/widget_util.dart';

class TweetHotCard extends StatelessWidget {
  final HotTweet ht;
  final int index;
  final Function onTap;
  BuildContext context;

  TweetHotCard(this.ht, this.index, this.onTap);

  bool isDark;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    isDark = ThemeUtils.isDark(context);
    if (ht == null) {
      return Gaps.empty;
    }
    if (!ht.anonymous && ht.account == null) {
      return Gaps.empty;
    }

    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Container(
            height: 100,
            padding: EdgeInsets.only(top: index == 0 ? 7.0 : 3.0, bottom: 7.0),
            child: Row(
              children: <Widget>[
                Flexible(flex: 2, child: _renderLeft()),
                Flexible(flex: 8, child: _renderMiddle()),
                Flexible(flex: 2, child: _renderRight()),
              ],
            )));
  }

  _renderLeft() {
    int idx = index + 1;
    String idxStr = idx.toString();
    if (idx < 10) {
      idxStr = '0$idx';
    }
    return Container(
      padding: const EdgeInsets.only(top: 10.0),
      margin: const EdgeInsets.only(left: 16.0),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text(
              idxStr,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Dimens.font_sp16,
                  color: index <= 3
                      ? Colors.red
                      : (index <= 6 ? Colors.amber : Theme.of(context).textTheme.subtitle1.color)),
            ),
          ),
          Container(
              child: ht.upTrend
                  ? Icon(
                      Icons.arrow_upward,
                      color: Colors.redAccent,
                      size: 16,
                    )
                  : Icon(
                      Icons.arrow_downward,
                      color: Colors.lightGreen,
                      size: 16,
                    )),
        ],
      ),
    );
  }

  _renderMiddle() {
    bool anonymous = ht.anonymous;
    String type = ht.type;
    if (tweetTypeMap[type] == null) {
      type = fallbackTweetType;
    }
    bool hasBody = !StringUtil.isEmpty(ht.body);
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      hasBody
          ? Expanded(
              flex: -1,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                children: <Widget>[
                  ExtendedText(
                    "${ht.body}",
                    maxLines: 2,
                    specialTextSpanBuilder: MySpecialTextSpanBuilder(),
                    selectionEnabled: false,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(fontSize: Dimens.font_sp15),
                  ),
                ],
              ))
          : Gaps.empty,
      Gaps.vGap2,
      Flexible(
        flex: 1,
        fit: FlexFit.loose,
        child: RichText(
          softWrap: true,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(children: [
            WidgetSpan(
                child: ClipOval(
              child: CachedNetworkImage(
                  imageUrl: ht.account == null
                      ? PathConstant.ANONYMOUS_PROFILE
                      : ht.anonymous ? PathConstant.ANONYMOUS_PROFILE : ht.account.avatarUrl,
                  fit: BoxFit.cover,
                  height: 16.0,
                  width: 16.0),
            )),
            TextSpan(
                text: ' ' + (!anonymous ? ht.account.nick ?? "" : TextConstant.TWEET_ANONYMOUS_NICK),
                style: MyDefaultTextStyle.getTweetNickStyle(Dimens.font_sp13p5,
                    bold: false, anonymous: anonymous, context: context)),
            TextSpan(
                text: ' 发表于${TimeUtil.getShortTime(ht.sentTime)}',
                style: TextStyle(color: Colors.grey, fontSize: Dimens.font_sp13p5)),
          ]),
        ),
      ),
      Gaps.vGap4,
      Flexible(
        flex: 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '# ' + tweetTypeMap[type].zhTag.toString(),
              style: TextStyle(
                  color: tweetTypeMap[type].color, fontSize: Dimens.font_sp12, fontWeight: FontWeight.w500),
            ),
            Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  '热度 ${ht.hot}',
                  style: TextStyle(color: Colors.grey, fontSize: Dimens.font_sp12),
                ))
          ],
        ),
      ),
    ]));
  }

  _renderRight() {
    String oriCoverUrl = (ht.cover != null && ht.cover.mediaType == Media.TYPE_IMAGE) ? ht.cover.url : null;

    bool hasLink = !StringUtil.isEmpty(ht.body) && StringUtil.getFirstUrlInStr(ht.body) != null;
    return oriCoverUrl != null || hasLink
        ? Container(
            margin: const EdgeInsets.only(right: 15.0),
            width: double.infinity,
            alignment: Alignment.topCenter,
            child: oriCoverUrl != null
                ? Container(
                    width: double.infinity,
                    alignment: Alignment.center,
//                    padding: const EdgeInsets.only(right: 5.0),
                    child: ClipRRect(
                      clipBehavior: Clip.antiAlias,
                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      child: AspectRatio(
                          aspectRatio: 1,
                          child: CachedNetworkImage(
                            imageUrl: oriCoverUrl + OssConstant.THUMBNAIL_SUFFIX,
                            placeholder: (context, url) => CupertinoActivityIndicator(),
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                const LoadAssetImage(PathConstant.IMAGE_FAILED),
                          )),
                    ))
                : Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    width: 30.0,
                    height: 30.0,
                    child: Icon(
                      Icons.link,
                      size: 25,
                      color: Colors.grey,
                    ),
                  ))
        : Gaps.empty;
  }
}
