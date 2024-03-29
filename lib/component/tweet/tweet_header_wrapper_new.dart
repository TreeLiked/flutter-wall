import 'package:city_pickers/city_pickers.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/component/simgple_tag.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account/tweet_account.dart';
import 'package:iap_app/model/gender.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';

class TweetCardHeaderWrapperNew extends StatelessWidget {
  final TweetAccount account;
  final bool anonymous;
  final bool canClick;
  final DateTime tweetSent;
  final bool official;
  final bool myNickClickable;

  const TweetCardHeaderWrapperNew(this.account, this.anonymous, this.tweetSent,
      {this.canClick = true,
      this.official = false,
      this.myNickClickable = true});

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
        onTap: () => anonymous || !myNickClickable
            ? null
            : goAccountDetail(context, account, true),
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
              Utils.packConvertArgs({
                'nick': account.nick,
                'accId': account.id,
                'avatarUrl': account.avatarUrl
              }));
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
            style: MyDefaultTextStyle.getTweetHeadNickStyle(
                context, SizeConstant.TWEET_NICK_SIZE,
                anonymous: true, bold: false),
          ))
        : GestureDetector(
            onTap: () =>
                anonymous ? null : goAccountDetail(context, account, true),
            child: Container(
              child: Text(
                account.nick ?? TextConstant.TEXT_UN_CATCH_ERROR,
                softWrap: true,
                style: MyDefaultTextStyle.getTweetHeadNickStyle(
                    context, SizeConstant.TWEET_NICK_SIZE,
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
      style: MyDefaultTextStyle.getTweetSigStyle(context,
          fontSize: SizeConstant.TWEET_TIME_SIZE),
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      maxLines: 1,
    ));
  }
}

class TweetSimpleHeaderNew extends StatelessWidget {
  final TweetAccount account;
  final bool anonymous;
  final bool canClick;
  final DateTime tweetSent;
  final bool official;
  final bool myNickClickable;

  // 是否在右侧展示时间，否则在左侧(用户个人资料页面进来)
  final bool timeRight;

  const TweetSimpleHeaderNew(this.account, this.anonymous, this.tweetSent,
      {this.canClick = true,
      this.official = false,
      this.myNickClickable = true,
      this.timeRight = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: [
            Expanded(child: _nickContainer(context)),
            official ? SimpleTag("官方") : Gaps.empty,
            Expanded(
                child: Container(
                    alignment: Alignment.centerRight,
                    child: _timeContainer(context)))
          ],
        ),
        _signatureContainer(context),
      ],

      // Container(child: _timeContainer(context))
    );
  }

  void goAccountDetail2(BuildContext context, TweetAccount account, bool up) {
    NavigatorUtils.push(
        context,
        Routes.accountProfile +
            Utils.packConvertArgs({
              'nick': account.nick,
              'accId': account.id,
              'avatarUrl': account.avatarUrl
            }));
  }

  void goAccountDetail(BuildContext context, TweetAccount account, bool up) {
    if (canClick) {
      NavigatorUtils.push(
          context,
          Routes.accountProfile +
              Utils.packConvertArgs({
                'nick': account.nick,
                'accId': account.id,
                'avatarUrl': account.avatarUrl
              }));
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
            style: MyDefaultTextStyle.getTweetHeadNickStyle(
                context, SizeConstant.TWEET_NICK_SIZE,
                anonymous: true, bold: true),
          ))
        : GestureDetector(
            onTap: () => anonymous || !myNickClickable
                ? null
                : goAccountDetail(context, account, true),
            child: Container(
              child: Text(
                account.nick ?? TextConstant.TEXT_UN_CATCH_ERROR,
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MyDefaultTextStyle.getTweetHeadNickStyle(
                    context, SizeConstant.TWEET_NICK_SIZE,
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

  Widget _signatureContainer(BuildContext context) {
    String sig;
    if (anonymous) {
      sig = "签名不可见";
    } else if (account == null || StringUtil.isEmpty(account.signature)) {
      sig = "这个用户很懒, 什么也没有留下";
    } else {
      sig = account.signature;
    }
    return Text(sig,
        style: MyDefaultTextStyle.getTweetSigStyle(context,
            fontSize: SizeConstant.TWEET_TIME_SIZE),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: false);
  }
}
