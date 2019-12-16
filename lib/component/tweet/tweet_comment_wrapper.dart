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

  // 点击回复框，回调home page textfield
  final displayReplyContainerCallback;

  // 回复callback
  final sendDisplayCallback;

  TweetCommentWrapper(this.tweet,
      {this.displayReplyContainerCallback, this.sendDisplayCallback});

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
    if (widget.tweet.enableReply &&
        widget.displayReplyContainerCallback != null) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _sendReply(1, widget.tweet.id, widget.tweet.account.id),
        child: Container(
          decoration: BoxDecoration(
              color: ThemeUtils.isDark(context)
                  ? Color(0xff363738)
                  : Color(0xfff2f3f4),
              borderRadius: const BorderRadius.all(const Radius.circular(10))),
          padding: EdgeInsets.all(9),
          child: Row(
            children: <Widget>[
              AccountAvatar(
                  cache: true,
                  avatarUrl: Application.getAccount.avatarUrl,
                  size: SizeConstant.TWEET_PROFILE_SIZE * 0.75),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      TextConstant.TWEET_CARD_REPLY_HINT,
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
    widget.displayReplyContainerCallback(
        tr, tarAccNick, tarAccId, _sendReplyCallback);
  }

  /*
   * 发送了评论，结果回调
   */
  _sendReplyCallback(TweetReply tr) {
    print('评论回复结果回调 ！！！！！！！！！！！！！！！！！！！！！！！！！！！！');
    if (tr == null) {
      ToastUtil.showToast(
        context,
        '回复失败，请稍后重试',
        gravity: ToastGravity.TOP,
      );
    } else {
      if (tr.type == 1) {
        // 设置到直接回复
        setState(() {
          if (widget.tweet.dirReplies == null) {
            widget.tweet.dirReplies = List();
          }
          widget.tweet.dirReplies.add(tr);
        });
      } else {
        // 子回复
        int parentId = tr.parentId;
        setState(() {
          TweetReply tr2 = widget.tweet.dirReplies
              .where((dirReply) => dirReply.id == parentId)
              .first;
          if (tr2.children == null) {
            tr2.children = List();
          }
          tr2.children.add(tr);
        });
      }
    }
  }
}
