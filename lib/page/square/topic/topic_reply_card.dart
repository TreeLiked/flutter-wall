import 'package:extended_text/extended_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/api/topic.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/component/bottom_sheet_confirm.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account/simple_account.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/topic/base_tr.dart';
import 'package:iap_app/page/common/report_page.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart';

class TopicReplyCardItem extends StatelessWidget {
  final MainTopicReply reply;
  final bool isDark;
  final Function hitReplyCb;
  final bool extra;
  final bool isSub;
  final bool closed;
  final SubTopicReply subTopicReply;

  const TopicReplyCardItem(this.reply, this.isDark, this.isSub, this.closed, this.hitReplyCb,
      {this.extra = true, this.subTopicReply});

  @override
  Widget build(BuildContext context) {
    print("topic reply card build");
    return !isSub ? _renderMainCard(context, reply) : _renderSubCard(context, subTopicReply);
  }

  Widget _renderMainCard(BuildContext context, MainTopicReply reply) {
    return Container(
      margin: const EdgeInsets.only(top: 15, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AccountAvatar(
                    avatarUrl: reply.author.avatarUrl,
                    size: 30,
                    onTap: () => NavigatorUtils.goAccountProfile(context, reply.author))
              ],
            ),
          ),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: GestureDetector(
                    onTap: () => _forwardAccountDetail(context, reply.author),
                    child: Text('${reply.author.nick ?? ""}',
//                        style: MyDefaultTextStyle.getTweetNickStyle(context, Dimens.font_sp15)
                    ),
                  ),
                ),
                GestureDetector(
                  child: ExtendedText("${reply.body}",
                      maxLines: 3,
                      selectionEnabled: true,
                      overFlowTextSpan: OverFlowTextSpan(children: [
                        TextSpan(text: ' \u2026 '),
                        TextSpan(
                            text: "查看更多",
                            style: const TextStyle(color: Colors.grey, fontSize: Dimens.font_sp13p5),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => BottomSheetUtil.showBottomSheetSingleReplyDetail(context, reply,
                                  onTap: () => NavigatorUtils.goBack(context)))
                      ]),
                      softWrap: true,
                      overflow: TextOverflow.fade,
                      style: MyDefaultTextStyle.getMainTextBodyStyle(isDark,
                          fontSize: SizeConstant.TWEET_REPLY_FONT_SIZE)),
//                  onLongPress: () {
//                    print("daskldsad;sa=---------------------");
//                    showModalBottomSheet(
//                      context: context,
//                      builder: (BuildContext context) {
//                        return BottomSheetConfirm(
//                            title: '操作',
//                            optChoice: '举报',
//                            optColor: Colors.redAccent,
//                            onTapOpt: () => NavigatorUtils.goReportPage(
//                                context, ReportPage.REPORT_TOPIC_REPLY, reply.topicId.toString()));
//                      },
//                    );
//                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
//                    Text('回复',
//                        style:
//                            MyDefaultTextStyle.getTweetTimeStyle(context).copyWith(color: Colours.app_main)),
                    Text(' ${TimeUtil.getShortTime(reply.sentTime)}',
                        style: MyDefaultTextStyle.getTweetTimeStyle(context)),
                  ],
                ),
                Gaps.vGap2,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    (extra && reply.replyCount != null && reply.replyCount > 0)
                        ? RichText(
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(children: [
                              TextSpan(
                                  text: !closed ? '回复   ' : '',
                                  style: MyDefaultTextStyle.getTweetReplyNickStyle(context,
                                      fontSize: Dimens.font_sp15),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = !closed ? () => hitReplyCb(reply.author, true) : null),
                              TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      Utils.showDefaultLoadingWithBounds(context, text: "正在加载");
                                      List<SubTopicReply> replies =
                                          await TopicApi.queryTopicSubReplies(reply.topicId, reply.id, 1, 20);
                                      NavigatorUtils.goBack(context);
                                      if (replies == null || replies.length == 0) {
                                        ToastUtil.showToast(context, '没有更多回复');
                                        return;
                                      }
                                      BottomSheetUtil.showBottomSheetSubTopicReplies(
                                          context, reply, closed, replies);
                                    },
                                  text: '全部 ${reply.replyCount} 条回复',
                                  style: const TextStyle(color: Color(0xcc03489d))),
                            ]),
                          )
                        : FlatButton(
                            child: Text(
                              !closed ? '回复 ' : '',
                              style: MyDefaultTextStyle.getTweetReplyNickStyle(context,
                                  fontSize: Dimens.font_sp15),
                            ),
                            onPressed: !closed ? () => hitReplyCb(reply.author, true) : null,
                          ),
//                    Text("回复",style:const TextStyle(color: Color(0xcc03489d),fontSize: Dimens.font_sp13p5)),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            flex: 0,
            child: Column(
              children: <Widget>[
                PraiseIconWidget(reply),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _renderSubCard(BuildContext context, SubTopicReply subTopicReply) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AccountAvatar(
                  avatarUrl: subTopicReply.author.avatarUrl,
                  size: 30,
                )
              ],
            ),
          ),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    margin: const EdgeInsets.only(bottom: 0),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: "${subTopicReply.author.nick}",
//                          style: MyDefaultTextStyle.getTweetNickStyle(context, Dimens.font_sp14),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _forwardAccountDetail(context, subTopicReply.author),
                        ),
                        TextSpan(text: " 回复 ", style: TextStyles.textGray14),
                        TextSpan(
                          text: "${subTopicReply.tarAccount.nick}",
//                          style: MyDefaultTextStyle.getTweetNickStyle(context, Dimens.font_sp14),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _forwardAccountDetail(context, subTopicReply.tarAccount),
                        ),
                      ]),
                    )),
                ExtendedText("${subTopicReply.body}",
                    maxLines: 3,
                    selectionEnabled: true,
                    overFlowTextSpan: OverFlowTextSpan(children: [
                      TextSpan(text: ' \u2026 '),
                      TextSpan(
                          text: "查看更多",
                          style: const TextStyle(color: Colors.grey, fontSize: Dimens.font_sp13p5),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => BottomSheetUtil.showBottomSheetSingleReplyDetail(
                                context, subTopicReply,
                                onTap: () => NavigatorUtils.goBack(context)))
                    ]),
                    softWrap: true,
                    overflow: TextOverflow.fade,
                    style: MyDefaultTextStyle.getMainTextBodyStyle(isDark,
                        fontSize: SizeConstant.TWEET_REPLY_FONT_SIZE)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
//                    Text('回复',
//                        style:
//                            MyDefaultTextStyle.getTweetTimeStyle(context).copyWith(color: Colours.app_main)),
                    Text(' ${TimeUtil.getShortTime(subTopicReply.sentTime)}',
                        style: MyDefaultTextStyle.getTweetTimeStyle(context)),
                  ],
                ),
                Gaps.vGap2,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(children: [
                        TextSpan(
                            text: !closed ? '回复   ' : '',
                            style: MyDefaultTextStyle.getTweetReplyNickStyle(context,
                                fontSize: Dimens.font_sp15),
                            recognizer: TapGestureRecognizer()
                              ..onTap = !closed ? () => hitReplyCb(subTopicReply.author, true) : null),
                      ]),
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            flex: 0,
            child: Column(
              children: <Widget>[
                PraiseIconWidget(subTopicReply),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _forwardAccountDetail(BuildContext context, SimpleAccount account) {
    if (account != null) {
      NavigatorUtils.goAccountProfile(context, account);
    }
  }
}

class PraiseIconWidget extends StatefulWidget {
  final BaseTopicReply reply;

  PraiseIconWidget(this.reply);

  @override
  State<StatefulWidget> createState() {
    return _PraiseIconWidget();
  }
}

class _PraiseIconWidget extends State<PraiseIconWidget> {
  static const double iconSize = 21;

  @override
  Widget build(BuildContext context) {
    bool praised = widget.reply.praised ?? false;
    int praiseCount = widget.reply.praiseCount ?? 0;
    bool hasPraised = praised || praiseCount > 0;
    String praiseCountStr = praiseCount.toString();
    if (praiseCount < 1000) {
      praiseCountStr = praiseCount.toString();
    } else if (praiseCount < 10000) {
      praiseCountStr = "${praiseCount ~/ 1000}.${(praiseCount % 1000) ~/ 100}k+";
    } else if (praiseCount < 100000) {
      praiseCountStr = "${praiseCount ~/ 10000}.${(praiseCount % 10000) ~/ 1000}w+";
    } else {
      praiseCountStr = "10w+";
    }
    if (praiseCount != null) {}
    return GestureDetector(
        onTap: () async {
          Result r = await TopicApi.modTopicPraiseStatus(widget.reply.id, !praised);
          if (r == null) {
            ToastUtil.showServiceExpToast(context);
            return;
          } else {
            if (r.isSuccess) {
              // 异或， 不同为真
              if (r.data ^ praised) {
                // 点赞成功
                setState(() {
                  widget.reply.praised = r.data;
                  if (r.data) {
                    widget.reply.praiseCount++;
                  } else {
                    widget.reply.praiseCount--;
                  }
                });
                return;
              } else {
                ToastUtil.showToast(context, '操作失败，当前${r.data ? '已点赞' : '未点赞'}');
              }
            } else {
              ToastUtil.showToast(context, '操作失败');
            }
          }

          setState(() {
            widget.reply.praised = !widget.reply.praised;
            if (widget.reply.praised) {
              widget.reply.praiseCount++;
            } else {
              widget.reply.praiseCount--;
            }
          });
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          praised
              ? const LoadAssetIcon(
                  "topic_praise_fill",
                  color: Colours.dark_red,
                  width: iconSize,
                  height: iconSize,
                )
              : const LoadAssetIcon(
                  "topic_praise",
                  color: Colors.grey,
                  width: iconSize,
                  height: iconSize,
                ),
          hasPraised
              ? Container(
                  margin: const EdgeInsets.only(left: 2),
                  child: Text("$praiseCountStr",
                      style: praised
                          ? const TextStyle(fontSize: Dimens.font_sp14, color: Colours.dark_red)
                          : TextStyles.textGray14),
                )
              : Gaps.empty
        ]));
  }
}
