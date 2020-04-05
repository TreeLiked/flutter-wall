import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/account_util.dart';
import 'package:iap_app/util/toast_util.dart';

class TweetReplyItemSimple extends StatelessWidget {
  static const TextSpan emptyTs = TextSpan(text: '');
  final TweetReply reply;
  final bool tweetAnonymous;
  final String tweetAccountId;
  final int parentId;
  final Function onTapAccount;
  final Function onTapReply;

  TweetReplyItemSimple(
      {@required this.tweetAccountId,
      @required this.tweetAnonymous,
      @required this.reply,
      @required this.parentId,
      @required this.onTapAccount,
      @required this.onTapReply});

  @override
  Widget build(BuildContext context) {
//    print('build reply' + reply.toJson().toString());
    bool dirReply = reply.type == 1;
    bool dirReplyAnonymous = (dirReply && reply.anonymous);

    bool isAuthorReply = reply.account.id == tweetAccountId;
    bool replyAuthor = reply.tarAccount != null && reply.tarAccount.id == tweetAccountId;
    String authorNick =
        TweetReplyUtil.getTweetReplyAuthorText(reply.account, tweetAnonymous, reply.anonymous, isAuthorReply);
    return Container(
        width: double.infinity,
        padding: EdgeInsets.only(bottom: 5.5),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: !dirReplyAnonymous
              ? () {
                  // 只要点击评论中的某一行，都是它的子回复
                  onTapReply(authorNick);
                }
              : () {
                  ToastUtil.showToast(context, '匿名评论不可回复');
                },
          child: RichText(
            maxLines: 2,
            overflow: TextOverflow.fade,
            softWrap: true,
            text: TextSpan(children: [
              TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      if (!dirReplyAnonymous) {
                        onTapAccount(reply.account, false);
                      }
                    },
                  text: authorNick,
                  style: TweetReplyUtil.getTweetReplyStyle(
                      tweetAnonymous, reply.anonymous, isAuthorReply, Dimens.font_sp14)),
              dirReply
                  ? emptyTs
                  : TextSpan(
                      text: ' 回复 ',
                      style: TweetReplyUtil.getTweetHuiFuStyle(Dimens.font_sp14, context: context)),
              dirReply
                  ? emptyTs
                  : TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          if (!(tweetAnonymous && replyAuthor)) {
                            onTapAccount(reply.tarAccount, false);
                          }
                        },
                      text: TweetReplyUtil.getTweetReplyTargetAccountText(
                          reply.tarAccount, tweetAnonymous, replyAuthor),
                      style: TweetReplyUtil.getTweetReplyStyle(
                          tweetAnonymous, reply.anonymous, isAuthorReply, Dimens.font_sp14,
                          context: context)),
              TextSpan(text: '：', style: TweetReplyUtil.getTweetHuiFuStyle(Dimens.font_sp14)),
              TextSpan(
                text: "${reply.body.trimRight()}",
                style: TweetReplyUtil.getReplyBodyStyle(Dimens.font_sp14, context: context),
              ),
            ]),
          ),
        ));
  }


}
