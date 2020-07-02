import 'package:flutter/material.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/component/simgple_tag.dart';
import 'package:iap_app/component/square_tag.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:provider/provider.dart';

class TweetStatisticsWrapper extends StatelessWidget {
  final BaseTweet tweet;
  final bool canPraise;
  final Function onClickComment;

  TweetStatisticsWrapper(this.tweet, this.canPraise, {this.onClickComment});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          OptionItem("tweet/view", Text("${tweet.views + 1}")),
          OptionItem(null, Text("${tweet.praise == 0 ? '' : tweet.praise}"),
              prefix: LoadAssetIcon(
                tweet.loved ? PathConstant.ICON_PRAISE_ICON_PRAISE : PathConstant.ICON_PRAISE_ICON_UN_PRAISE,
                width: 17,
                height: 17,
                color: tweet.loved ? Colors.pink[100] : Colors.grey,
              ),
              onTap: () => canPraise ? updatePraise(context) : null),

          tweet.enableReply
              ? OptionItem(
                  null, Text(tweet.enableReply ? "${tweet.replyCount == 0 ? '' : tweet.replyCount}" : "评论关闭"),
                  prefix: LoadAssetIcon(PathConstant.ICON_COMMENT_ICON,
                      width: 17, height: 17, color: Colors.grey),
                  onTap: () => onClickComment == null ? null : onClickComment())
              : Text("评论关闭", style: TextStyle(color: Color(0xffCDAD00), fontSize: Dimens.font_sp13p5))
//          OptionItem("tweet/comment",
//              Text(tweet.enableReply ? "${tweet.replyCount == 0 ? '' : tweet.replyCount}" : "评论关闭")),
        ],
      ),
    );
  }

  void updatePraise(BuildContext context) async {
    if (tweet.latestPraise == null) {
      tweet.latestPraise = List();
    }
    final _tweetProvider = Provider.of<TweetProvider>(context);
    final _localAccProvider = Provider.of<AccountLocalProvider>(context);
    _tweetProvider.updatePraise(context, _localAccProvider.account, tweet.id, !tweet.loved);
    await TweetApi.operateTweet(tweet.id, 'PRAISE', tweet.loved);
    if (tweet.loved) {
      Utils.showFavoriteAnimation(context, size: 20);
      Future.delayed(Duration(milliseconds: 1600)).then((_) => Navigator.pop(context));
    }
  }
}

class OptionItem extends StatelessWidget {
  final String iconName;
  final Widget text;
  final Function onTap;
  Widget prefix;

  OptionItem(this.iconName, this.text, {this.prefix, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          iconName != null
              ? LoadAssetIcon(
                  iconName,
                  width: 20.0,
                  height: 20.0,
                  color: Colors.grey,
                )
              : prefix,
          Gaps.hGap4,
          text,
        ],
      ),
      onTap: onTap == null ? null : onTap,
    );
  }
}
