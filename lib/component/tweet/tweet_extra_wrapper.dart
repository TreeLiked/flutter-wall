import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/account_util.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart';

class TweetCardExtraWrapper extends StatefulWidget {
  final BaseTweet tweet;

  // 点击某一条评论回调 homepage textField
  final displayReplyContainerCallback;

  const TweetCardExtraWrapper({this.tweet, this.displayReplyContainerCallback});

  @override
  State<StatefulWidget> createState() {
    return _TweetCardExtraWrapper();
  }
}

class _TweetCardExtraWrapper extends State<TweetCardExtraWrapper> {
  @override
  Widget build(BuildContext context) {
    print('_TweetCardExtraWrapper --------------------build');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[_extraContainer(), Gaps.vGap8, _praiseContainer(), Gaps.vGap8, _replyContainer()],
    );
  }

  Widget _praiseContainer() {
    // 最近点赞的人数
    List<Widget> items = List();

    List<InlineSpan> spans = List();
    spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              updatePraise();
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: LoadAssetIcon(
                widget.tweet.loved
                    ? PathConstant.ICON_PRAISE_ICON_PRAISE
                    : PathConstant.ICON_PRAISE_ICON_UN_PRAISE,
                width: 17,
                height: 17,
//                color: widget.tweet.loved ? Colors.lightBlue : Colors.grey
              ),
            ))));
    List<Account> praiseList = widget.tweet.latestPraise;
    if (!CollectionUtil.isListEmpty(praiseList)) {
      for (int i = 0; i < praiseList.length && i < GlobalConfig.MAX_DISPLAY_PRAISE; i++) {
        Account account = praiseList[i];
        spans.add(TextSpan(
            text: "${account.nick}" + (i != praiseList.length - 1 ? '、' : ' '),
            style: MyDefaultTextStyle.getTweetNickStyle(context, 13, bold: false),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                goAccountDetail(account, false);
              }));
      }

      if (praiseList.length > GlobalConfig.MAX_DISPLAY_PRAISE) {
        int diff = praiseList.length - GlobalConfig.MAX_DISPLAY_PRAISE;
        items.add(Text(
          " 等共$diff人刚刚赞过",
          style: TextStyle(fontSize: 13),
        ));
      }
    }
    Widget widgetT = RichText(
      text: TextSpan(children: spans),
      softWrap: true,
    );
    items.add(widgetT);

    return Wrap(
        alignment: WrapAlignment.start, crossAxisAlignment: WrapCrossAlignment.center, children: items);
  }

  void updatePraise() async {
    if (widget.tweet.latestPraise == null) {
      widget.tweet.latestPraise = List();
    }
    setState(() {
      widget.tweet.loved = !widget.tweet.loved;
      if (widget.tweet.loved) {
        Utils.showFavoriteAnimation(context);
        Future.delayed(Duration(seconds: 2)).then((_) => Navigator.pop(context));
        widget.tweet.praise++;
        widget.tweet.latestPraise.insert(0, Application.getAccount);
      } else {
        widget.tweet.praise--;
        widget.tweet.latestPraise.removeWhere((account) => account.id == Application.getAccountId);
      }
    });
    TweetApi.operateTweet(widget.tweet.id, 'PRAISE', widget.tweet.loved);
  }

  Widget _replyContainer() {
    if (widget.tweet.enableReply) {
      if (!CollectionUtil.isListEmpty(widget.tweet.dirReplies)) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _getReplyList()),
            )
          ],
        );
      } else {
        return Container(height: 0.0);
      }
    } else {
      // 评论关闭
      return Text('评论关闭', style: MyDefaultTextStyle.getTweetTimeStyle(context));
    }
  }

  List<Widget> _getReplyList() {
    if (CollectionUtil.isListEmpty(widget.tweet.dirReplies)) {
      return [];
    }
    List<Widget> list = new List();

    int displayCnt = 0;
    for (var dirTr in widget.tweet.dirReplies) {
      if (displayCnt == GlobalConfig.MAX_DISPLAY_REPLY) {
        break;
      }
      list.add(_singleReplyContainer(dirTr, true, false, parentId: dirTr.id));
      displayCnt++;
      if (!CollectionUtil.isListEmpty(dirTr.children)) {
        dirTr.children.forEach((tr) {
          list.add(_singleReplyContainer(tr, true, false, parentId: dirTr.id));
        });
      }
    }
    if (widget.tweet.replyCount > GlobalConfig.MAX_DISPLAY_REPLY) {
      list.add(_singleReplyContainer(null, false, true));
    }

    return list;
  }

  Widget _singleReplyContainer(TweetReply reply, bool isSub, bool bottom, {int parentId}) {
    if (bottom) {
      return Padding(
        padding: EdgeInsets.only(top: 5),
        child: Text(
          "查看更多 ${widget.tweet.replyCount - GlobalConfig.MAX_DISPLAY_REPLY} 条回复 ..",
          style: TextStyle(color: ColorConstant.TWEET_NICK_COLOR),
        ),
      );
    }
    bool authorAnonymous = widget.tweet.anonymous;
    String accNick = AccountUtil.getNickFromAccount(reply.account, false);
    bool isAuthorReply = (widget.tweet.account.id == reply.account.id);
    if (isAuthorReply && authorAnonymous) {
      accNick = "作者";
      reply.account.nick = "作者";
    }

    bool replyAuthor = reply.tarAccount == null || (widget.tweet.account.id == reply.tarAccount.id);
    String tarNick = AccountUtil.getNickFromAccount(reply.tarAccount, false);
    if (replyAuthor && authorAnonymous) {
      tarNick = "作者";
      if (reply.tarAccount != null) {
        reply.tarAccount.nick = "作者";
      }
    }

    bool dirReplyAnonymous = (reply.type == 1 && reply.anonymous);
    if (dirReplyAnonymous) {
      // 直接回复匿名
      reply.account.nick = TextConstant.TWEET_ANONYMOUS_REPLY_NICK;
    }
    // if (!replyAuthor) {

    return Container(
        width: double.infinity,
        padding: EdgeInsets.only(bottom: 5),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: !dirReplyAnonymous
              ? () {
                  // 只要点击评论中的某一行，都是它的子回复
                  _sendReply(2, parentId, reply.account.id, tarAccNick: accNick);
                }
              : () {
                  ToastUtil.showToast(context, '匿名评论不可回复');
                },
          child: Wrap(
            children: <Widget>[
              RichText(
                maxLines: 5,
                overflow: TextOverflow.fade,
                softWrap: true,
                text: TextSpan(children: [
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          if (!dirReplyAnonymous) {
                            goAccountDetail(reply.account, false);
                          }
                        },
                      text: dirReplyAnonymous ? TextConstant.TWEET_ANONYMOUS_REPLY_NICK : accNick,
                      style: isAuthorReply && authorAnonymous
                          ? MyDefaultTextStyle.getTweetReplyAnonymousNickStyle(context, Dimens.font_sp14)
                          : MyDefaultTextStyle.getTweetReplyNickStyle(context)),
                  TextSpan(
                      text: reply.type == 2 ? ' 回复 ' : '',
                      style: TextStyle(color: Theme.of(context).textTheme.subtitle.color)),
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          if (replyAuthor && authorAnonymous) {
                            goAccountDetail(reply.account, false);
                          }
                        },
                      text: reply.type == 2 ? tarNick : '',
                      style: replyAuthor && authorAnonymous
                          ? MyDefaultTextStyle.getTweetReplyAnonymousNickStyle(context, Dimens.font_sp14)
                          : MyDefaultTextStyle.getTweetReplyNickStyle(context)),
                  TextSpan(
                    text: ': ',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.subtitle.color, fontSize: Dimens.font_sp14),
                  ),
                  TextSpan(
                    text: reply.body,
                    style: TextStyle(
                        color: !ThemeUtils.isDark(context)
                            ? Theme.of(context).textTheme.subhead.color
                            : ColorConstant.TWEET_TIME_COLOR_DARK,
                        fontSize: Dimens.font_sp14,
                        fontWeight: FontWeight.w400),
                    // recognizer: MultiTapGestureRecognizer()
                    //   ..onLongTapDown = (_, __) {
                    //     Utils.copyTextToClipBoard(reply.body);
                    //     ToastUtil.showToast(context, '内容已复制到粘贴板');
                    // }
                  ),
                ]),
              ),
            ],
          ),
        ));
  }

  void goAccountDetail(Account account, bool up) {
    NavigatorUtils.push(
        context,
        Routes.accountProfile +
            Utils.packConvertArgs(
                {'nick': account.nick, 'accId': account.id, 'avatarUrl': account.avatarUrl}));
  }

  _sendReply(int type, int parentId, String tarAccId, {String tarAccNick}) {
    if (widget.displayReplyContainerCallback != null) {
      TweetReply tr = new TweetReply();
      tr.tweetId = widget.tweet.id;
      tr.type = type;
      tr.parentId = parentId;
      tr.anonymous = false;
      tr.tarAccount = Account.fromId(tarAccId);

      widget.displayReplyContainerCallback(tr, tarAccNick, tarAccId, _sendReplyCallback);
    }
  }

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
          TweetReply tr2 = widget.tweet.dirReplies.where((dirReply) => dirReply.id == parentId).first;
          if (tr2.children == null) {
            tr2.children = List();
          }
          tr2.children.add(tr);
        });
      }
    }
  }

  Widget _extraContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text(
                  '${widget.tweet.views}次浏览 , ${widget.tweet.praise}人觉得很赞',
                  style: TextStyle(
                      fontSize: SizeConstant.TWEET_EXTRA_SIZE,
                      color: ColorConstant.getTweetSigColor(context)),
                )),
          ],
        )
      ],
    );
  }
}
