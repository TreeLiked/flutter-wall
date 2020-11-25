import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/component/simgple_tag.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account/tweet_account.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';

class TweetCardHeaderWrapper extends StatelessWidget {
  final TweetAccount account;
  final bool anonymous;
  final bool canClick;
  final DateTime tweetSent;
  final bool official;
  final bool myNickClickable;

  const TweetCardHeaderWrapper(this.account, this.anonymous, this.tweetSent,
      {this.canClick = true, this.official = false, this.myNickClickable = true});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: -1,
          child: _profileContainer(context),
        ),
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _nickContainer(context),
              _signatureContainer(context),
            ],
          ),
        ),
        Container(child: _timeContainer(context))
      ],
    ));
  }

  Widget _profileContainer(BuildContext context) {
    return GestureDetector(
        onTap: () => anonymous || !myNickClickable ? null : goAccountDetail(context, account, true),
        child: Container(
            margin: EdgeInsets.only(right: 10),
            child: AccountAvatar(
              cache: true,
              avatarUrl: !anonymous
                  ? (account.avatarUrl ?? PathConstant.AVATAR_FAILED)
                  : PathConstant.ANONYMOUS_PROFILE,
              size: SizeConstant.TWEET_PROFILE_SIZE,
            )));
  }

  void goAccountDetail(BuildContext context, TweetAccount account, bool up) {
    if (canClick) {
      NavigatorUtils.push(
          context,
          Routes.accountProfile +
              Utils.packConvertArgs(
                  {'nick': account.nick, 'accId': account.id, 'avatarUrl': account.avatarUrl}));
    }
  }

  Widget _nickContainer(BuildContext context) {
    if (anonymous) {
      account.nick = TextConstant.TWEET_ANONYMOUS_NICK;
    }
    return anonymous || !myNickClickable
        ? Container(
            child: Text(
            TextConstant.TWEET_ANONYMOUS_NICK + (official ? "官方" : "fff"),
            style: MyDefaultTextStyle.getTweetHeadNickStyle(context, SizeConstant.TWEET_NICK_SIZE,
                anonymous: true, bold: false),
          ))
        : GestureDetector(
            onTap: () => anonymous ? null : goAccountDetail(context, account, true),
            child: Container(
              child: Text(
                account.nick ?? TextConstant.TEXT_UN_CATCH_ERROR,
                softWrap: true,
                style: MyDefaultTextStyle.getTweetHeadNickStyle(context, SizeConstant.TWEET_NICK_SIZE,
                    bold: false),
              ),
            ));
  }

  Widget _timeContainer(BuildContext context) {
    if (tweetSent == null) {
      return Container(height: 0);
    }
    return Text(
      TimeUtil.getShortTime(tweetSent) ?? "未知",
      maxLines: 2,
      softWrap: true,
      style: MyDefaultTextStyle.getTweetTimeStyle(context),
    );
  }

  Widget _signatureContainer(BuildContext context) {
    return Container(
        child: Text(
      !anonymous
          ? (StringUtil.isEmpty(account.signature) ? "" : account.signature)
          : TextConstant.TWEET_ANONYMOUS_SIG,
      style: MyDefaultTextStyle.getTweetSigStyle(context, fontSize: SizeConstant.TWEET_TIME_SIZE),
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      maxLines: 2,
    ));
  }
}

class TweetSimpleHeader extends StatelessWidget {
  final TweetAccount account;
  final bool anonymous;
  final bool canClick;
  final DateTime tweetSent;
  final bool official;
  final bool myNickClickable;

  // 是否在右侧展示时间，否则在左侧(用户个人资料页面进来)
  final bool timeRight;

  const TweetSimpleHeader(this.account, this.anonymous, this.tweetSent,
      {this.canClick = true, this.official = false, this.myNickClickable = true, this.timeRight = true});

  @override
  Widget build(BuildContext context) {
    if (this.timeRight) {
      return Container(
          child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _nickContainer(context),
                official ? SimpleTag("官方") : Gaps.empty,
//                  _signatureContainer(context),
              ],
            ),
          ),
          Container(child: _timeContainer(context))
        ],
      ));
    }
    // 否则从个人资料页面进来，更换header样式
    return Container(
        child: Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(margin: const EdgeInsets.only(bottom: 5.0), child: _timeLeftContainer(context))
      ],
    ));
  }

  Widget _profileContainer(BuildContext context) {
    return GestureDetector(
        onTap: () => anonymous ? null : goAccountDetail(context, account, true),
        child: Container(
            margin: EdgeInsets.only(right: 10),
            child: AccountAvatar(
              cache: true,
              avatarUrl: !anonymous
                  ? (account.avatarUrl ?? PathConstant.AVATAR_FAILED)
                  : PathConstant.ANONYMOUS_PROFILE,
              size: SizeConstant.TWEET_PROFILE_SIZE,
            )));
  }

  void goAccountDetail(BuildContext context, TweetAccount account, bool up) {
    if (canClick) {
      NavigatorUtils.push(
          context,
          Routes.accountProfile +
              Utils.packConvertArgs(
                  {'nick': account.nick, 'accId': account.id, 'avatarUrl': account.avatarUrl}));
    }
  }

  Widget _nickContainer(BuildContext context) {
    if (anonymous) {
      account.nick = TextConstant.TWEET_ANONYMOUS_NICK;
    }
    return anonymous
        ? Container(
            child: Text(
            TextConstant.TWEET_ANONYMOUS_NICK + (official ? "官方" : ""),
            style: MyDefaultTextStyle.getTweetHeadNickStyle(context, SizeConstant.TWEET_NICK_SIZE,
                anonymous: true, bold: true),
          ))
        : GestureDetector(
            onTap: () => anonymous || !myNickClickable ? null : goAccountDetail(context, account, true),
            child: Container(
              child: Text(
                account.nick ?? TextConstant.TEXT_UN_CATCH_ERROR,
                softWrap: true,
                style: MyDefaultTextStyle.getTweetHeadNickStyle(context, SizeConstant.TWEET_NICK_SIZE,
                    bold: true),
              ),
            ));
  }

  Widget _timeContainer(BuildContext context) {
    if (tweetSent == null) {
      return Container(height: 0);
    }
    return Text(
      TimeUtil.getShortTime(tweetSent) ?? "未知",
      maxLines: 2,
      softWrap: true,
      style: MyDefaultTextStyle.getTweetTimeStyle(context),
    );
  }

  Widget _timeLeftContainer(BuildContext context) {
    if (tweetSent == null) {
      return Container(height: 0);
    }
    bool dark = ThemeUtils.isDark(context);
    List<TextSpan> spans = new List();

    if (TimeUtil.sameDayAndYearMonth(tweetSent)) {
      // 当天的内容
      spans.add(
        TextSpan(
            text: '~ ' + TimeUtil.getShortTime(tweetSent) + ' ~',
            style: pfStyle.copyWith(color: Colors.amber[600], fontSize: Dimens.font_sp14)),
      );
    } else {
      if (TimeUtil.sameYear(tweetSent)) {
        // 当年的内容
        spans.add(
          TextSpan(text: '${tweetSent.day}', style: pfStyle.copyWith(fontSize: Dimens.font_sp18)),
        );
        spans.add(
          TextSpan(text: ' /', style: pfStyle.copyWith(color: Colors.grey, fontSize: Dimens.font_sp15)),
        );
        spans.add(
          TextSpan(
              text: '${tweetSent.month}月',
              style: pfStyle.copyWith(color: Colors.grey, fontSize: Dimens.font_sp15)),
        );
      } else {
        // 今年之前的内容
        spans.add(
          TextSpan(
              text: '${tweetSent.month}月${tweetSent.day}日',
              style: pfStyle.copyWith(fontSize: Dimens.font_sp18, letterSpacing: 1.2)),
        );
        spans.add(
          TextSpan(text: ' / ', style: pfStyle.copyWith(color: Colors.grey, fontSize: Dimens.font_sp15)),
        );
        spans.add(
          TextSpan(
              text: '${tweetSent.year}年',
              style: pfStyle.copyWith(color: Colors.grey, fontSize: Dimens.font_sp15)),
        );
      }
    }
    return RichText(
        text: TextSpan(
      style: pfStyle.copyWith(color: dark ? Colors.white54 : Colors.black87),
      children: spans,
    ));
  }

  Widget _signatureContainer(BuildContext context) {
    return Container(
        child: Text(
      !anonymous
          ? (StringUtil.isEmpty(account.signature) ? "" : account.signature)
          : TextConstant.TWEET_ANONYMOUS_SIG,
      style: MyDefaultTextStyle.getTweetSigStyle(context, fontSize: SizeConstant.TWEET_TIME_SIZE),
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      maxLines: 2,
    ));
  }
}
