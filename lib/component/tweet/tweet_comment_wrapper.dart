import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';

class TweetCommentWrapper extends StatefulWidget {
  final BaseTweet tweet;

  // 点击回复框，回调home page textField
  final displayReplyContainerCallback;

  TweetCommentWrapper(this.tweet, {this.displayReplyContainerCallback});

  @override
  State<StatefulWidget> createState() {
    return _TweetCommentWrapper();
  }
}

class _TweetCommentWrapper extends State<TweetCommentWrapper> {
  @override
  Widget build(BuildContext context) {
    return _commentContainer();
  }

  Widget _commentContainer() {
    if (widget.tweet.enableReply && widget.displayReplyContainerCallback != null) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _sendReply(1, widget.tweet.id, widget.tweet.account.id),
        child: Container(
          decoration: BoxDecoration(
              color: ThemeUtils.isDark(context) ? Color(0xff363738) : Color(0xfff2f3f4),
              borderRadius: const BorderRadius.all(const Radius.circular(6.6))),
          padding: const EdgeInsets.all(8.8),
          child: Row(
            children: <Widget>[
              AccountAvatar(
                  cache: true,
                  avatarUrl: Application.getAccount.avatarUrl,
                  size: SizeConstant.TWEET_PROFILE_SIZE * 0.75),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(TextConstant.TWEET_CARD_REPLY_HINT,
                        style: TextStyle(
                          fontSize: SizeConstant.TWEET_TIME_SIZE - 1,
                          color: ColorConstant.getTweetSigColor(context),
                        ))),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  /*
   * tarAccNick 显示在输入框中的回复， tarAccId 目标账户推送
   * type 1=> 评论， 2=> 子回复
   */
  _sendReply(int type, int parentId, String tarAccId, {String tarAccNick}) {
    TweetReply tr = new TweetReply();
    tr.tweetId = widget.tweet.id;
    tr.type = type;
    tr.parentId = parentId;
    tr.anonymous = false;
    tr.tarAccount = Account.fromId(tarAccId);
    widget.displayReplyContainerCallback(tr, tarAccNick, tarAccId);
  }
}
