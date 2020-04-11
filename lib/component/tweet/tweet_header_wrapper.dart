import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/component/simgple_tag.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/tweet_account.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/time_util.dart';

class TweetCardHeaderWrapper extends StatelessWidget {
  final TweetAccount account;
  final bool anonymous;
  final bool canClick;
  final DateTime tweetSent;
  final bool official;

  const TweetCardHeaderWrapper(this.account, this.anonymous, this.tweetSent,
      {this.canClick = true, this.official = false});

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
            TextConstant.TWEET_ANONYMOUS_NICK,
            style: MyDefaultTextStyle.getTweetHeadNickStyle(context, SizeConstant.TWEET_NICK_SIZE,
                anonymous: true, bold: true),
          ))
        : GestureDetector(
            onTap: () => anonymous ? null : goAccountDetail(context, account, true),
            child: Container(
              child: Text(
                account.nick  ?? TextConstant.TEXT_UN_CATCH_ERROR,
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
