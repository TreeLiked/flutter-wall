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
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/theme_utils.dart';

class TweetReplyWrapperSimple extends StatelessWidget {
  final BaseTweet tweet;
  final Function showReplyInputCb;

  TweetReplyWrapperSimple(this.tweet, this.showReplyInputCb);

  @override
  Widget build(BuildContext context) {
    if (!tweet.enableReply) {
      return Gaps.empty;
    }
    var dirReplies = tweet.dirReplies;
    if (dirReplies == null || dirReplies.length == 0) {
      return Gaps.empty;
    }
    int len = dirReplies.length;
    int totalCount = 0;
    List<Widget> trWs = new List();
    bool isDark = ThemeUtils.isDark(context);
    TextStyle style =
        isDark ? MyDefaultTextStyle.tweetReplyStyleDark() : MyDefaultTextStyle.tweetReplyStyleLight();

    for (int i = 0; i < len; i++) {
      if (totalCount == GlobalConfig.MAX_DISPLAY_REPLY) {
        break;
      }
      TweetReply dirTr = dirReplies[i];
      trWs.add(TweetReplyItemSimple(
          tweetAccountId: tweet.account.id,
          tweetAnonymous: tweet.anonymous,
          reply: dirTr,
          parentId: dirTr.id,
          onTapReply: (displayNick) =>
              _sendReply(2, dirTr.id, dirTr.account.id, tweet.account.id, tarAccNick: displayNick),
          bodyStyle: style));
      totalCount++;
      if (!CollectionUtil.isListEmpty(dirTr.children)) {
        dirTr.children.forEach((tr) {
          if (totalCount != GlobalConfig.MAX_DISPLAY_REPLY_ALL) {
            totalCount++;
            trWs.add(TweetReplyItemSimple(
              tweetAccountId: tweet.account.id,
              tweetAnonymous: tweet.anonymous,
              reply: tr,
              parentId: dirTr.id,
              onTapReply: (displayNick) =>
                  _sendReply(2, dirTr.id, tweet.account.id, tr.account.id, tarAccNick: displayNick),
              bodyStyle: style,
            ));
          }
        });
      }
    }
    if (totalCount < tweet.replyCount) {
      return Container(
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
//            color: ColorConstant.TWEET_RICH_BG,
            borderRadius: BorderRadius.circular(8.0)),
        child: Column(
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
                      style:
                          MyDefaultTextStyle.getTweetReplyMoreTextStyle(Dimens.font_sp14, context: context)),
                ),
              )
            ]),
      );
    }
    return Container(
      padding: const EdgeInsets.all(5.0),
//      decoration: BoxDecoration(
//        color: ColorConstant.TWEET_RICH_BG,
//        borderRadius: BorderRadius.circular(8.0)
//      ),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListView(
          shrinkWrap: true,
          physics: new NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          children: trWs),
    );
  }

  _sendReply(int type, int parentId, String tarAccId, String replierId, {String tarAccNick}) {
    if (showReplyInputCb != null) {
      TweetReply tr = new TweetReply();
      tr.tweetId = tweet.id;
      tr.type = type;
      tr.parentId = parentId;
      tr.anonymous = false;
      tr.tarAccount = Account.fromId(tarAccId);
      tr.account = Account.fromId(replierId);
      showReplyInputCb(tr, tarAccNick, tarAccId);
    }
  }
}
