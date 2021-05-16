import 'package:extended_text/extended_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/my_special_text_builder.dart';
import 'package:iap_app/component/bottom_sheet_confirm_multi.dart';
import 'package:iap_app/component/simgple_tag.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/gender.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/page/common/report_page.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/account_util.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:provider/provider.dart';

class TweetReplyItemDetail extends StatelessWidget {
  static const TextSpan emptyTs = TextSpan(text: '');
  final TweetReply reply;
  final bool tweetAnonymous;
  final String tweetAccountId;
  final int parentId;
  final int tweetId;
  final Function onTapAccount;
  final Function onTapReply;
  final Function refresh;
  String tweetType;

  BuildContext context;

  TweetReplyItemDetail(
      {@required this.tweetAccountId,
      @required this.tweetAnonymous,
      @required this.reply,
      @required this.parentId,
      @required this.tweetId,
      this.onTapAccount,
      @required this.onTapReply,
      @required this.tweetType,
      @required this.refresh});

  @override
  Widget build(BuildContext context) {
    this.context = context;
//    print('build reply complex' + reply.toJson().toString());
    bool dirReply = reply.type == 1;
    bool dirReplyAnonymous = (dirReply && reply.anonymous);

    bool isAuthorReply = reply.account.id == tweetAccountId;

    bool boo1 = dirReplyAnonymous || (tweetAnonymous && isAuthorReply);
    String authorNick =
        TweetReplyUtil.getTweetReplyAuthorText(reply.account, tweetAnonymous, reply.anonymous, isAuthorReply);
    return Container(
        margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: dirReplyAnonymous
              ? () => ToastUtil.showToast(context, '匿名评论不可回复')
              : () => onTapReply(authorNick),
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return BottomSheetMultiSelect(
                  title: '评论操作',
                  choices: tweetAccountId == Application.getAccountId
                      ? [
                          MultiBottomSheetItem(
                              text: '举报',
                              style: pfStyle.copyWith(color: Color(0xffCD5C5C), fontSize: Dimens.font_sp13p5),
                              onTap: () => NavigatorUtils.goReportPage(
                                  context, ReportPage.REPORT_TWEET_REPLY, reply.id.toString(), "评论举报")),
                          MultiBottomSheetItem(
                              text: '删除',
                              style: pfStyle.copyWith(color: Color(0xff4682B4), fontSize: Dimens.font_sp13p5),
                              onTap: () => delReply(reply.id))
                        ]
                      : [
                          MultiBottomSheetItem(
                              text: '举报',
                              style: pfStyle.copyWith(color: Color(0xffCD5C5C), fontSize: Dimens.font_sp13p5),
                              onTap: () => NavigatorUtils.goReportPage(
                                  context, ReportPage.REPORT_TWEET_REPLY, reply.id.toString(), "评论举报"))
                        ],
                );
              },
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              reply.type == 2 && reply.tarAccount != null ? SizedBox(width: 48) : Gaps.empty,
              Container(
                margin: const EdgeInsets.only(right: 11.0),
                child: AccountAvatar(
                    size: SizeConstant.TWEET_PROFILE_SIZE,
                    avatarUrl: boo1 ? PathConstant.ANONYMOUS_PROFILE : reply.account.avatarUrl,
                    gender: boo1 ? Gender.UNKNOWN : Gender.parseGenderByAccount(reply.account),
                    onTap: boo1 ? null : () => NavigatorUtils.goAccountProfile2(context, reply.account)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _headContainer(),
                    _replyBodyContainer(),
                    Row(
                      children: <Widget>[
                        _timeContainer(),
                        _delReplyContainer(),
                      ],
                    ),
                    Gaps.vGap4,
                    Gaps.line,
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget _headContainer() {
    bool replyAnonymous = reply.anonymous;

    bool isAuthorReply = reply.account.id == tweetAccountId;
    bool directReply = reply.type == 1 || reply.tarAccount == null;

    bool authorReplyWithTweetAnon = isAuthorReply && tweetAnonymous;
    bool targetAuthor = reply.tarAccount == null || reply.tarAccount.id == tweetAccountId;
    bool targetAuthorAndTweetAnon = tweetAnonymous && targetAuthor;

    if (tweetTypeMap[tweetType] == null) {
      tweetType = fallbackTweetType;
    }
    String authorNick =
        TweetReplyUtil.getTweetReplyAuthorText(reply.account, tweetAnonymous, reply.anonymous, isAuthorReply);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      runAlignment: WrapAlignment.center,
      children: <Widget>[
        RichText(
          softWrap: true,
          text: TextSpan(children: [
            replyAnonymous || !isAuthorReply || directReply
                ? TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // 如果 回复匿名 || （推文匿名 && 作者的回复）
                        if (replyAnonymous || authorReplyWithTweetAnon) {
                          return;
                        }
                        forwardAccountProfile(reply.account);
                      },
                    text: authorNick ?? "",
                    style: TweetReplyUtil.getTweetReplyStyle(
                        tweetAnonymous, reply.anonymous, isAuthorReply, Dimens.font_sp14))
                : WidgetSpan(
                    child: SimpleTag(
                    '作者',
                    round: true,
                    radius: 5.0,
                    bgColor: tweetTypeMap[tweetType].color.withAlpha(180),
                    textColor: Colors.white,
                    verticalPadding: 0,
                  )),
            !replyAnonymous && directReply && isAuthorReply
                ? WidgetSpan(
                    child: SimpleTag(
                    '作者',
                    round: true,
                      radius: 5.0,
                      bgColor: tweetTypeMap[tweetType].color.withAlpha(180),
                    textColor: Colors.white,
                    verticalPadding: 0,
                    leftMargin: 5,
                  ))
                : emptyTs,
            !directReply
                ? TextSpan(
                    text: ' 回复 ',
                    style: TweetReplyUtil.getTweetHuiFuStyle(Dimens.font_sp13p5, context: context))
                : emptyTs,
            !directReply
                ? TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        if (!targetAuthorAndTweetAnon) {
                          forwardAccountProfile(reply.tarAccount);
                        }
                      },
                    text: (targetAuthorAndTweetAnon ? TextConstant.TWEET_AUTHOR_TEXT : reply.tarAccount.nick),
                    style: TweetReplyUtil.getTweetReplyStyle(
                        tweetAnonymous, reply.anonymous, isAuthorReply, Dimens.font_sp14))
                : emptyTs
          ]),
        ),
      ],
    );
  }

  Widget _replyBodyContainer() {
    String body = reply.body;
    if (body == null || body.length == 0) {
      return Gaps.empty;
    }
    return GestureDetector(
//        onLongPress: () {
//          showModalBottomSheet(
//            context: context,
//            builder: (BuildContext context) {
//              return BottomSheetConfirm(
//                  title: '评论操作',
//                  optChoice: '举报',
//                  optColor: Colors.redAccent,
//                  onTapOpt: () => NavigatorUtils.goReportPage(
//                      context, ReportPage.REPORT_TWEET_REPLY, reply.id.toString(), "评论举报"));
//            },
//          );
//        },
        child: Container(
      margin: const EdgeInsets.only(top: 1.5),
      child: ExtendedText("${body}",
          maxLines: 3,
          softWrap: true,
          textAlign: TextAlign.left,
          specialTextSpanBuilder: MySpecialTextSpanBuilder(showAtBackground: false),
          onSpecialTextTap: (dynamic parameter) {},
          selectionEnabled: true,
          overflowWidget: TextOverflowWidget(
            // fixedOffset: Offset(10.0, 0.0),
              child: Row(children: <Widget>[
            GestureDetector(
                child: Text(
                  '..查看全部',
                  style: pfStyle.copyWith(
                    color: Colors.blue,
                    fontSize: Dimens.font_sp14,
                  ),
                ),
                onTap: () {
                  BottomSheetUtil.showBottomSheetSingleTweetReplyDetail(
                      context, reply, reply.anonymous, tweetAnonymous && reply.account.id == tweetAccountId,
                      onTap: () => NavigatorUtils.goBack(context));
                })
          ])),
          style: TweetReplyUtil.getReplyBodyStyle(Dimens.font_sp14, context: context)),
    ));
  }

  Widget _timeContainer() {
    return Container(
        padding: EdgeInsets.only(top: 1.0),
        child: Text(
          TimeUtil.getShortTime(reply.sentTime),
          style:
              pfStyle.copyWith(fontSize: Dimens.font_sp12, color: ColorConstant.getTweetTimeColor(context)),
        ));
  }

  Widget _delReplyContainer() {
    if (reply.account != null && reply.account.id == Application.getAccountId) {
      return GestureDetector(
          onTap: () => delReply(reply.id),
          child: Container(
            padding: EdgeInsets.only(left: 10.0),
            child: Text('删除', style: pfStyle.copyWith(fontSize: Dimens.font_sp13, color: Color(0xff4682B4))),
          ));
    }
    return Gaps.empty;
  }

  void delReply(int replyId) async {
    Utils.showDefaultLoadingWithBounds(context);
    Result r = await TweetApi.delTweetReply(replyId);
    if (r != null && r.isSuccess) {
      if (refresh != null) {
        refresh();
      } else {
        ToastUtil.showToast(context, '删除成功');
      }
      print(tweetId);
      Provider.of<TweetProvider>(context).deleteReply(tweetId, parentId, replyId, reply.type);
    } else {
      ToastUtil.showToast(context, '删除失败');
    }
    NavigatorUtils.goBack(context);
  }

  void forwardAccountProfile(Account account) {
    NavigatorUtils.goAccountProfile2(context, account);
  }

//  Widget replyWrapContainer(TweetReply reply, bool subDir, int parentId) {
//    // 是否作者回复
//    bool authorReply = reply.account.id == tweetAccountId;
//    // 是否此条评论匿名
//    bool thisReplyAnonymous = reply.anonymous;
//
//    Widget wd = GestureDetector(
//        behavior: HitTestBehavior.opaque,
//        // 这条评论不是匿名回复，都可以回复这条评论
//        onTap: !thisReplyAnonymous
//            ? () {
//                curReply.parentId = parentId;
//                curReply.type = 2;
//                curReply.tarAccount = Account.fromId(reply.account.id);
//                if (tweetAnonymous && authorReply) {
//                  // 推文匿名 && 回复 => 推文作者
//                  showReplyContainer(TextConstant.TWEET_AUTHOR_TEXT, reply.account.id, false);
//                } else {
//                  showReplyContainer(
//                      TweetReplyUtil.getNickFromAccount(reply.account, false), reply.account.id, false);
//                }
//              }
//            : () {
//                ToastUtil.showToast(context, '匿名评论不可回复');
//              },
//        child: new Row(
//          mainAxisAlignment: MainAxisAlignment.start,
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: <Widget>[
//            subDir ? Container(width: 42) : Gaps.empty,
//            _leftContainer(reply.account.avatarUrl, thisReplyAnonymous, reply.account),
//            Flexible(
//                fit: FlexFit.tight,
//                flex: 1,
//                child: Container(
//                  padding: const EdgeInsets.only(right: 5, left: 2, top: 5),
//                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
////                    _headContainer(reply),
//                    _replyBodyContainer(reply.body),
//                    Row(children: <Widget>[
//                      Container(
//                          padding: EdgeInsets.only(top: 5),
//                          child: Text(
//                            TimeUtil.getShortTime(reply.sentTime),
//                            style: TextStyle(
//                                fontSize: SizeConstant.TWEET_TIME_SIZE,
//                                color: ColorConstant.getTweetTimeColor(context)),
//                          )),
//                    ]),
//                    Gaps.vGap4,
//                    Divider()
//                  ]),
//                )),
//          ],
//        ));
//    return wd;
//  }
//

}
