import 'package:flutter/material.dart';
import 'package:iap_app/component/tweet/praise/tweet_praise_wrapper.dart';
import 'package:iap_app/component/tweet/reply/tweet_reply_wrapper_simple.dart';
import 'package:iap_app/component/tweet/tweet_statistics_wrapper.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/widget_util.dart';

class TweetCardExtraWrapper extends StatefulWidget {
  final BaseTweet tweet;
  final bool displayPraise;
  final bool canPraise;
  final bool displayComment;

  // 点击某一条评论回调 homepage textField
  final onClickComment;

  const TweetCardExtraWrapper(
      {this.tweet,
      this.onClickComment,
      this.canPraise = false,
      this.displayPraise = false,
      this.displayComment = false});

  @override
  State<StatefulWidget> createState() {
    return _TweetCardExtraWrapper();
  }
}

class _TweetCardExtraWrapper extends State<TweetCardExtraWrapper> {
  @override
  Widget build(BuildContext context) {
    BaseTweet tweet = widget.tweet;
    if (tweet == null) {
      return Gaps.empty;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Gaps.vGap12,
        TweetStatisticsWrapper(tweet,widget.canPraise,onClickComment: widget.onClickComment),
        Gaps.vGap8,
        widget.displayPraise ? TweetPraiseWrapper(tweet, prefixIcon: true) : Gaps.empty,
        widget.displayPraise ? Gaps.vGap8 : Gaps.empty,
        widget.displayComment
            ? TweetReplyWrapperSimple(tweet, widget.onClickComment)
            : Gaps.empty,
      ],
    );
  }

  void goAccountDetail(Account account, bool up) {
    NavigatorUtils.push(
        context,
        Routes.accountProfile +
            Utils.packConvertArgs(
                {'nick': account.nick, 'accId': account.id, 'avatarUrl': account.avatarUrl}));
  }
}

class OptionItem extends StatelessWidget {
  final String iconName;
  final Widget text;

  OptionItem(this.iconName, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LoadAssetIcon(
          iconName,
          width: 20.0,
          height: 20.0,
          color: Colors.grey,
        ),
        Gaps.hGap4,
        text,
      ],
    );
  }
}
