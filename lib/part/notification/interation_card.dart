import 'package:flutter/material.dart';
import 'package:iap_app/api/message.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/imgae_container.dart';
import 'package:iap_app/component/bottom_sheet_confirm.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/simple_account.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:iap_app/model/message/topic_reply_message.dart';
import 'package:iap_app/model/message/tweet_praise_message.dart';
import 'package:iap_app/model/message/tweet_reply_message.dart';
import 'package:iap_app/part/notification/red_point.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/routes/square_router.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/widget_util.dart';

class InteractionCardItem extends StatelessWidget {
  final AbstractMessage message;

  BuildContext thisContext;
  bool isDark = false;

  InteractionCardItem(this.message);

  @override
  Widget build(BuildContext context) {
    thisContext = context;
    isDark = ThemeUtils.isDark(context);

    Account account;
    bool accountAnonymous = false;
    // 0 点赞， 1 回复
    int optType;
    // 如果是回复，则replyBody不为空
    String replyBody;

    // 推文body | 话题标题
    String body;

    // 推文封面，如果无body，显示封面
    String cover;
    int refId;

    MessageType mstT = message.messageType;
    if (mstT == MessageType.TWEET_PRAISE) {
      // 推文点赞
      TweetPraiseMessage temp = message as TweetPraiseMessage;
      account = temp.praiser;
      optType = 0;
      body = temp.tweetBody;
      cover = temp.coverUrl;
      refId = temp.tweetId;
    } else if (mstT == MessageType.TWEET_REPLY) {
      // 推文回复
      TweetReplyMessage temp = message as TweetReplyMessage;
      account = temp.replier;
      optType = 1;
      replyBody = temp.replyContent;
      body = temp.tweetBody;
      cover = temp.coverUrl;
      refId = temp.tweetId;
      accountAnonymous = temp.anonymous;
    } else if (mstT == MessageType.TOPIC_REPLY) {
      // 话题回复
      TopicReplyMessage temp = message as TopicReplyMessage;
      account = temp.replier;
      optType = 1;
      replyBody = temp.replyContent;
      body = temp.topicBody;
      refId = temp.topicId;
    } else {
      return Gaps.empty;
    }
    if (account == null) {
      return Gaps.empty;
    }

    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          message.readStatus = ReadStatus.READ;
          MessageAPI.readThisMessage(message.id);
          if (mstT == MessageType.TWEET_PRAISE || mstT == MessageType.TWEET_REPLY) {
            NavigatorUtils.push(context, Routes.tweetDetail + "?tweetId=$refId");
          } else if (mstT == MessageType.TOPIC_REPLY) {
            NavigatorUtils.push(context, SquareRouter.topicDetail + "?topicId=$refId");
          }
        },
//        onLongPress: () {
//          showModalBottomSheet(
//            context: context,
//            builder: (BuildContext context) {
//              return BottomSheetConfirm(
//                title: '确认删除此条消息吗',
//                optChoice: '删除',
//                onTapOpt: () async {
//                  MessageAPI.readAllInteractionMessage()
//                },
//              );
//            },
//          );
//        },
        child: Container(
            margin: const EdgeInsets.only(left: 10.0, bottom: 5.0, right: 10.0, top: 5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        margin: const EdgeInsets.only(right: 10.0),
                        child: AccountAvatar(
                            cache: true,
                            avatarUrl: !accountAnonymous ? account.avatarUrl : PathConstant.ANONYMOUS_PROFILE,
                            onTap: () => _handleGoAccount(context, account)))
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                              child: GestureDetector(
                            child: _buildNick(account.nick, accountAnonymous),
                            onTap: () => _handleGoAccount(context, account),
                          )),
                          Expanded(
                              child: Container(
                                  child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              RedPoint(message),
                              _buildTime(message.sentTime),
                            ],
                          )))
                        ],
                      ),
                      Gaps.vGap4,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          optType == 0
                              ? const LoadAssetSvg('love_fill',
                                  width: 20, height: 20, color: Color(0xFFFF80AB))
                              : const LoadAssetSvg('reply', width: 20, height: 20, color: Colors.blue),
                          optType == 0
                              ? const Text(' 赞了你', style: const TextStyle())
                              : Flexible(
                                  child: RichText(
                                    softWrap: true,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(children: [
                                      TextSpan(text: ' 回复: ', style: const TextStyle(color: Colors.blue)),
                                      TextSpan(
                                          text: '$replyBody',
                                          style: MyDefaultTextStyle.getMainTextBodyStyle(isDark,
                                              fontSize: Dimens.font_sp14)),
                                    ]),
                                  ),
                                ),
                        ],
                      ),
                      Gaps.vGap5,
                      Wrap(
                        children: <Widget>[
                          _buildBody(body, cover),
                        ],
                      ),
                      Gaps.vGap8,
                      Gaps.line
                    ],
                  ),
                ),
              ],
            )));
  }

  _buildNick(String nick, bool anonymous) {
    return Container(
      child: Text(
        anonymous ? TextConstant.TWEET_ANONYMOUS_NICK : nick,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: MyDefaultTextStyle.getTweetNickStyle(thisContext, Dimens.font_sp15),
      ),
    );
  }

  _buildTime(DateTime dt) {
    return Container(
        margin: const EdgeInsets.only(left: 5),
        child: Text(TimeUtil.getShortTime(dt), style: MyDefaultTextStyle.getTweetTimeStyle(thisContext)));
  }

  _buildBody(String refBody, String cover) {
    if (refBody != null && refBody.trim() != "") {
      return Container(
        child: Text('$refBody',
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: Dimens.font_sp15)),
      );
    } else if (cover != null) {
      return ImageContainer(
          url: cover, width: Application.screenWidth / 4, maxHeight: Application.screenHeight / 4);
    } else {
      return Gaps.empty;
    }
  }

  void _handleGoAccount(BuildContext context, Account account) {
    if (message.messageType == MessageType.TWEET_REPLY && (message as TweetReplyMessage).anonymous) {
      return;
    }
    NavigatorUtils.goAccountProfile2(context, account);
  }
}
