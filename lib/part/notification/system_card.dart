import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/api/message.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:iap_app/model/message/plain_system_message.dart';
import 'package:iap_app/model/message/popular_message.dart';
import 'package:iap_app/model/message/tweet_reply_message.dart';
import 'package:iap_app/page/tweet_detail.dart';
import 'package:iap_app/part/notification/red_point.dart';
import 'package:iap_app/part/topic_card.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/resources.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/image_utils.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';

class SystemCardItem extends StatelessWidget {
  final AbstractMessage message;

  BuildContext thisContext;
  bool isDark = false;

  SystemCardItem(this.message);

  @override
  Widget build(BuildContext context) {
    thisContext = context;
    isDark = ThemeUtils.isDark(context);
    if (message == null) {
      return Gaps.empty;
    }

    MessageType mstT = message.messageType;
    if (mstT == MessageType.PLAIN_SYSTEM) {
      // 系统消息
      PlainSystemMessage temp = message as PlainSystemMessage;
      print("------" + temp.toJson().toString());
      return _buildPlainSystemMessage(context, temp);
    } else if (mstT == MessageType.POPULAR) {
      // 上热门消息
      PopularMessage temp = message as PopularMessage;
      print("------" + temp.toJson().toString());
      return _buildPopularSystemMessage(context, temp);
    } else {
      return Gaps.empty;
    }
  }

  Widget _buildPlainSystemMessage(BuildContext context, PlainSystemMessage msg) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          message.readStatus = ReadStatus.READ;
          if (msg.hasLink && msg.linkUrl != null) {
            NavigatorUtils.goWebViewPage(context, msg.title, msg.linkUrl);
          }
        },
        child: MySnCard(
          child: Container(
              margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _dateTimeContainer(context, msg.sentTime),
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Text(
                        msg.title ?? "系统通知",
                        style: MyDefaultTextStyle.getMainTextBodyStyle(isDark),
                      )),
                      msg.hasLink && msg.linkUrl != null ? Images.arrowRight : Gaps.empty
                    ],
                  ),
                  Gaps.vGap8,
                  Gaps.line,
                  msg.hasCover && msg.coverUrl != null
                      ? Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            maxHeight: 180,
                          ),
                          child: ClipRRect(
                            child: FadeInImage(
                              placeholder: ImageUtils.getImageProvider('https://via.placeholder.com/180'),
                              image: NetworkImage(msg.coverUrl),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: const BorderRadius.all(const Radius.circular(10)),
                          ),
                        )
                      : Gaps.empty,
                  Gaps.vGap8,
                  Text(msg.content ?? '', style: MyDefaultTextStyle.getSubTextBodyStyle(isDark)),
                ],
              )),
        ));
  }

  _dateTimeContainer(BuildContext context, DateTime date) {
    return date != null
        ? Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.only(bottom: 10),
            child: Text(TimeUtil.getShortTime(date), style: MyDefaultTextStyle.getTweetTimeStyle(context)),
          )
        : Gaps.empty;
  }

  Widget _buildPopularSystemMessage(BuildContext context, PopularMessage msg) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () async {
          message.readStatus = ReadStatus.READ;
          MessageAPI.readThisMessage(message.id);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TweetDetail(null, tweetId: msg.tweetId, hotRank: -1),
                maintainState: true),
          );
        },
        child: MySnCard(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _dateTimeContainer(context, msg.sentTime),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                          child: Text(
                        "恭喜，您的发布上热门 !",
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: Dimens.font_sp15),
                      )),
                    ),
                    msg.readStatus == ReadStatus.UNREAD
                        ? RedPoint(
                            msg,
                            color: Color(0xff00CED1),
                          )
                        : Gaps.empty,
                    Images.arrowRight,
                  ],
                ),
                Gaps.vGap8,
                Gaps.line,
                Gaps.vGap8,
                _buildBody(msg.tweetBody, msg.coverUrl),
              ],
            ),
          ),
        ));
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
            style: pfStyle.copyWith(color: Colors.grey, fontSize: Dimens.font_sp15)),
      );
    } else if (cover != null) {
      return Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: 180,
          ),
          child: ClipRRect(
            child: CachedNetworkImage(
              imageUrl: cover,
              fit: BoxFit.cover,
            ),
            borderRadius: const BorderRadius.all(const Radius.circular(10)),
          ));
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
