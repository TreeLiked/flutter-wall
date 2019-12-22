import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/time_util.dart';

class TweetCardHeaderWrapper extends StatelessWidget {
  final Account account;
  final bool anonymous;
  final bool canClick;
  final DateTime tweetCreated;

  TweetCardHeaderWrapper(this.account, this.anonymous, this.tweetCreated, {this.canClick = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _profileContainer(context),
        Expanded(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _nickContainer(context),
                    Expanded(
                      child: Container(
                        alignment: Alignment.topRight,
                        child: _timeContainer(context),
                      ),
                    )
                  ],
                ),
                _signatureContainer(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileContainer(BuildContext context) {
    return GestureDetector(
        onTap: () => anonymous ? null : goAccountDetail(context, account, true),
        child: Container(
            margin: EdgeInsets.only(right: 10),
            child: AccountAvatar(
              avatarUrl: !anonymous
                  ? (account.avatarUrl ?? PathConstant.AVATAR_FAILED)
                  : PathConstant.ANONYMOUS_PROFILE,
              size: SizeConstant.TWEET_PROFILE_SIZE,
            )));
  }

  void goAccountDetail(BuildContext context, Account account, bool up) {
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
                account.nick ?? TextConstant.TEXT_UNCATCH_ERROR,
                style: MyDefaultTextStyle.getTweetHeadNickStyle(context, SizeConstant.TWEET_NICK_SIZE,
                    bold: true),
              ),
            ));
  }

  Widget _timeContainer(BuildContext context) {
    if (tweetCreated == null) {
      return Container(height: 0);
    }
    return Text(TimeUtil.getShortTime(tweetCreated) ?? "未知",
        style: MyDefaultTextStyle.getTweetTimeStyle(context));
  }

  Widget _signatureContainer(BuildContext context) {
    if (StringUtil.isEmpty(account.signature)) {
      return Container(height: 0);
    }
    return Container(
        margin: EdgeInsets.only(right: 20),
        child: Text(
          !anonymous ? account.signature : TextConstant.TWEET_ANONYMOUS_SIG,
          style: MyDefaultTextStyle.getTweetSigStyle(context, fontSize: SizeConstant.TWEET_TIME_SIZE),
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          maxLines: 2,
        ));
  }
}
