import 'package:flutter/material.dart';
import 'package:iap_app/component/tweet/item/tweet_reply_item_simple.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';

class TweetReplyWrapperSimple extends StatelessWidget {
  final BaseTweet tweet;
  final Function showReplyInputCb;

  TweetReplyWrapperSimple(this.tweet, this.showReplyInputCb);

  @override
  Widget build(BuildContext context) {
    if (!tweet.enableReply) {
      return Container(
        margin: const EdgeInsets.only(top: 5.0),
        child: Text('评论关闭',
            style: const TextStyle(
                fontSize: SizeConstant.TWEET_DISABLE_REPLY_SIZE,
                color: ColorConstant.TWEET_DISABLE_COLOR_TEXT_COLOR)),
      );
    }
    var dirReplies = tweet.dirReplies;
    if (dirReplies == null || dirReplies.length == 0) {
      return Gaps.empty;
    }
    int len = dirReplies.length;
    int replyCount = 0;
    int totalCount = 0;
    List<Widget> trWs = new List();
    for (int i = 0; i < len; i++) {
      if (replyCount == GlobalConfig.MAX_DISPLAY_REPLY || totalCount == GlobalConfig.MAX_DISPLAY_REPLY_ALL) {
        break;
      }
      TweetReply dirTr = dirReplies[i];
      trWs.add(TweetReplyItemSimple(
          tweetAccountId: tweet.account.id,
          tweetAnonymous: tweet.anonymous,
          reply: dirTr,
          parentId: dirTr.id,
          onTapReply: (displayNick) => _sendReply(2, dirTr.id, dirTr.account.id, tarAccNick: displayNick)));
      replyCount++;
      totalCount++;
      if (replyCount == GlobalConfig.MAX_DISPLAY_REPLY || totalCount == GlobalConfig.MAX_DISPLAY_REPLY_ALL) {
        break;
      }
      if (!CollectionUtil.isListEmpty(dirTr.children)) {
        dirTr.children.forEach((tr) {
          totalCount++;
          trWs.add(TweetReplyItemSimple(
            tweetAccountId: tweet.account.id,
            tweetAnonymous: tweet.anonymous,
            reply: tr,
            parentId: dirTr.id,
            onTapReply: (displayNick) => _sendReply(2, dirTr.id, dirTr.account.id, tarAccNick: displayNick),
          ));
        });
      }
    }
    if (replyCount < tweet.replyCount) {
      return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: ListView(
                  shrinkWrap: true,
                  physics: new NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(0),
                  children: trWs),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: () => NavigatorUtils.goTweetDetail(context, tweet),
                child: Text('查看更多${tweet.replyCount - totalCount}条评论 ..',
                    style: MyDefaultTextStyle.getTweetReplyMoreTextStyle(Dimens.font_sp14, context: context)),
              ),
            )
          ]);
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListView(
          shrinkWrap: true,
          physics: new NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          children: trWs),
    );
  }

  _sendReply(int type, int parentId, String tarAccId, {String tarAccNick}) {
    if (showReplyInputCb != null) {
      TweetReply tr = new TweetReply();
      tr.tweetId = tweet.id;
      tr.type = type;
      tr.parentId = parentId;
      tr.anonymous = false;
      tr.tarAccount = Account.fromId(tarAccId);
      showReplyInputCb(tr, tarAccNick, tarAccId);
    }
  }
}
