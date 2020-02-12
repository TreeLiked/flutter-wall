import 'package:extended_text/extended_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/simple_account.dart';
import 'package:iap_app/model/topic/base_tr.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/image_utils.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/widget_util.dart';

class TopicReplyCardItem extends StatelessWidget {
  final MainTopicReply reply;
  final bool isDark;

  const TopicReplyCardItem(this.reply, this.isDark);

  @override
  Widget build(BuildContext context) {
    print("topic reply card build");
    return _renderMainCard(context, reply.child, reply);
  }

  Widget _renderMainCard(BuildContext context, bool isChild, MainTopicReply reply) {
    bool hasChildren = !CollectionUtil.isListEmpty(reply.subReplies) && reply.replyCount > 0;
    return Container(
        margin: const EdgeInsets.only(top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: ExtendedText("${reply.body}",
                      maxLines: 3,
                      selectionEnabled: true,
                      overFlowTextSpan: OverFlowTextSpan(children: <TextSpan>[
                        TextSpan(text: ' \u2026 '),
                        TextSpan(
                            text: "查看更多",
                            style: const TextStyle(color: Colors.grey, fontSize: Dimens.font_sp13p5),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
//                                launch("https://github.com/fluttercandies/extended_text");
                                BottomSheetUtil.showBottomSheetText(context, reply.body,
                                    authorNick: reply.author.nick);
                              })
                      ]),
                      softWrap: true,
                      overflow: TextOverflow.fade,
                      style: MyDefaultTextStyle.getMainTextBodyStyle(isDark,
                          fontSize: SizeConstant.TWEET_REPLY_FONT_SIZE)),
                ),
                Expanded(
                  flex: 1,
                  child: PraiseIconWidget(reply),
                ),
              ],
            ),
            Gaps.vGap4,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                AccountAvatar(avatarUrl: reply.author.avatarUrl, size: 20),
                Gaps.hGap4,
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(children: [
                    TextSpan(
                        text: '${reply.author.nick ?? ""}',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _forwardAccountDetail(context, reply.author),
                        style: MyDefaultTextStyle.getTweetNickStyle(context, SizeConstant.TWEET_TIME_SIZE)),
                    TextSpan(
                        text: ' 回复于 ${TimeUtil.getShortTime(reply.sentTime)}',
                        style: MyDefaultTextStyle.getTweetTimeStyle(context))
                  ]),
                ),
              ],
            ),
            hasChildren ? _renderSubCard(context, reply) : Gaps.empty,
            Gaps.vGap10,
          ],
        ));
  }

  Widget _renderSubCard(BuildContext context, MainTopicReply mainTopicReply) {
    SubTopicReply reply = mainTopicReply.subReplies[0];
    if (reply == null) {
      return Gaps.empty;
    }
    bool hasMore = mainTopicReply.replyCount > 0;
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Expanded(
              flex: 1,
              child: Gaps.empty,
            ),
            Expanded(
              flex: 9,
              child: ExtendedText("${reply.body}" * 100,
                  maxLines: 2,
                  overFlowTextSpan: OverFlowTextSpan(children: <TextSpan>[
                    TextSpan(text: '  \u2026  '),
                    TextSpan(
                        text: "查看更多",
                        style: const TextStyle(color: Colors.grey, fontSize: Dimens.font_sp13p5),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
//                                launch("https://github.com/fluttercandies/extended_text");
                            BottomSheetUtil.showBottomSheetText(context, reply.body,
                                authorNick: reply.author.nick);
                          })
                  ]),
                  softWrap: true,
                  overflow: TextOverflow.fade,
                  style: MyDefaultTextStyle.getMainTextBodyStyle(isDark,
                      fontSize: SizeConstant.TWEET_REPLY_FONT_SIZE)),
            ),
            Expanded(
              flex: 2,
              child: PraiseIconWidget(reply),
            ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Gaps.empty,
              ),
              Expanded(
                flex: 11,
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(children: [
                    WidgetSpan(child: AccountAvatar(avatarUrl: reply.author.avatarUrl, size: 18)),
                    TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _forwardAccountDetail(context, reply.author),
                        text: ' ${reply.author.nick ?? ""}',
                        style: MyDefaultTextStyle.getTweetNickStyle(context, SizeConstant.TWEET_TIME_SIZE)),
                    TextSpan(text: ' 回复 ', style: MyDefaultTextStyle.getTweetTimeStyle(context)),
                    TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _forwardAccountDetail(context, reply.tarAccount),
                        text: '${reply.tarAccount.nick ?? ""}',
                        style: MyDefaultTextStyle.getTweetNickStyle(context, SizeConstant.TWEET_TIME_SIZE)),
                    TextSpan(
                        text: ' 于 ${TimeUtil.getShortTime(reply.sentTime)}',
                        style: MyDefaultTextStyle.getTweetTimeStyle(context)),
                  ]),
                ),
              ),
            ],
          ),
          Gaps.vGap5,
          hasMore
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Gaps.empty,
                    ),
                    Expanded(
                      flex: 11,
                      child: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(children: [
                          TextSpan(
                              text: '查看全部 ${mainTopicReply.replyCount} 条回复', style: TextStyles.textGray14),
                          WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Icon(
                                Icons.arrow_right,
                                size: 20,
                                color: ThemeUtils.getIconColor(context),
                              ))
                        ]),
                      ),
                    ),
                  ],
                )
              : Gaps.empty
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
    bool praised = widget.reply.praised;
    bool hasPraised = praised || widget.reply.praiseCount > 0;
    int praiseCount = widget.reply.praiseCount;
    String praiseCountStr = praiseCount.toString();
    if (praiseCount != null) {}
    // TODO: implement build
    return GestureDetector(
        onTap: () {
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
                  child: Text("${widget.reply.praiseCount}", style: TextStyles.textGray14),
                )
              : Gaps.empty
        ]));
  }
}
