import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/api/message.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/global/theme_constant.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:iap_app/model/message/plain_system_message.dart';
import 'package:iap_app/model/message/topic_reply_message.dart';
import 'package:iap_app/model/message/tweet_praise_message.dart';
import 'package:iap_app/model/message/tweet_reply_message.dart';
import 'package:iap_app/page/notification/index_main_item.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/notification_router.dart';
import 'package:iap_app/routes/setting_router.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/PermissionUtil.dart';
import 'package:iap_app/util/message_util.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/umeng_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NotificationIndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    print('NotificationIndexPage create state');
    return _NotificationIndexPageState();
  }
}

class _NotificationIndexPageState extends State<NotificationIndexPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<NotificationIndexPage> {
  String iconSubPath = "heart";
  String iconSchoolPath = "hat";
  String iconContactPath = "wave";
  String iconOfficialPath = "author";

  final String noMessage = "暂无新通知";

  bool isDark = false;

  RefreshController _refreshController = new RefreshController(initialRefresh: true);

  dynamic _latestInteractionMsg;
  dynamic _latestSystemMsg;

  SingleMessageControl interactionMsgCtrl = MessageUtil.interactionMsgControl;
  SingleMessageControl sysMsgCtrl = MessageUtil.systemMsgControl;

  @override
  void initState() {
    super.initState();
    // 校验通知权限
    UMengUtil.userGoPage(UMengUtil.PAGE_NOTI_INDEX);
    _loopQueryInteraction(true);
    _loopQuerySystem(true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      checkNotification();
    });
  }

  void checkNotification() async {
    Future.delayed(Duration(seconds: 3)).then((value) =>
        PermissionUtil.checkAndRequestNotification(context, showTipIfDetermined: true, probability: 39));
  }

  _fetchLatestMessage() async {
    _fetchLatestSystemMsg();
    _fetchLatestInteractionMsg();
  }

  Future<void> _fetchLatestSystemMsg() async {
    MessageAPI.fetchLatestMessage(0).then((msg) {
      setState(() {
        this._latestSystemMsg = msg;
      });
    }).whenComplete(() => _refreshController.refreshCompleted());
  }

  Future<void> _fetchLatestInteractionMsg() async {
    MessageAPI.fetchLatestMessage(1).then((msg) {
      if (msg != null && msg.readStatus == ReadStatus.UNREAD) {
        _loopQueryInteraction(false);
        setState(() {
          this._latestInteractionMsg = msg;
        });
      }
    }).whenComplete(() => _refreshController.refreshCompleted());
  }

  _loopQueryInteraction(bool loop) {
    MessageAPI.queryInteractionMessageCount().then((count) {
      if (count != -1) {
        if (interactionMsgCtrl.localCount != count) {
          interactionMsgCtrl.localCount = count;
          print('发现新消息，开始刷新');
          if (!_refreshController.isRefresh) {
            _refreshController.requestRefresh();
          }
          _fetchLatestSystemMsg().then((_) {
            // 刷新完成后增加小红点
            interactionMsgCtrl.streamCount = count;
          });
        }
      }
    }).whenComplete(() {
      if (loop) {
        Future.delayed(Duration(seconds: 60)).then((_) {
          _loopQueryInteraction(true);
        });
      }
    });
  }

  _loopQuerySystem(bool loop) {
    MessageAPI.querySystemMessageCount().then((count) {
      if (count != -1) {
        if (sysMsgCtrl.localCount != count) {
          sysMsgCtrl.localCount = count;
          if (!_refreshController.isRefresh) {
            _refreshController.requestRefresh();
          }
          sysMsgCtrl.streamCount = count;

//          print('发现新消息，开始刷新');
//          _fetchLatestInteractionMsg().then((_) {
//          });
        }
      }
    }).whenComplete(() {
      if (loop) {
        Future.delayed(Duration(minutes: 5)).then((_) {
          _loopQuerySystem(true);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
//    print('notification build');
//    print('notification' + (ModalRoute.of(context).isCurrent ? "当前页面" : "不是当前页面"));

    isDark = ThemeUtils.isDark(context);

    return Scaffold(
      backgroundColor: ThemeUtils.getBackColor(context),
      appBar: AppBar(
        backgroundColor: ThemeUtils.getBackColor(context),
        automaticallyImplyLeading: false,
        title: Text('消息',
            style: pfStyle.copyWith(
                fontSize: Dimens.font_sp18, fontWeight: FontWeight.w400, letterSpacing: 1.3)),
        centerTitle: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back), iconSize: 23.0, onPressed: () => NavigatorUtils.goBack(context)),
      ),
      body: SafeArea(
        top: false,
        child: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: false,
            header: MaterialClassicHeader(
              color: Colors.amber,
              backgroundColor: isDark ? ColorConstant.MAIN_BG_DARK : ColorConstant.MAIN_BG,
            ),
//            header: Utils.getDefaultRefreshHeader(),
            onRefresh: _fetchLatestMessage,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  MainMessageItem(
                    iconPath: iconSubPath,
                    title: "私信",
                    body: "暂无私信消息",
                    color: Colors.pink[300],
                    onTap: () => ToastUtil.showToast(context, "当前没有私信消息"),
                  ),
                  MainMessageItem(
                      iconPath: iconSchoolPath,
                      title: "校园公告",
                      tagName: "官方",
                      body: "暂无新通知",
                      pointType: true,
                      onTap: () {
                        NavigatorUtils.push(context, NotificationRouter.campusMain);
                      },
                      color: Colors.amber),
                  MainMessageItem(
                      iconPath: iconContactPath,
                      color: Colors.lightGreen,
                      title: "与我有关",
                      body: _latestInteractionMsg == null ? noMessage : _getInteractionBody(),
                      time: _latestInteractionMsg == null ? null : _latestInteractionMsg.sentTime,
                      controller: MessageUtil.interactionMsgControl.controller,
                      onTap: () {
                        _latestInteractionMsg = null;
                        interactionMsgCtrl.clear();
                        MessageUtil.clearNotificationCnt();
                        NavigatorUtils.push(context, NotificationRouter.interactiveMain);
                      }),
                  Gaps.vGap8,
                  MainMessageItem(
                    iconPath: iconOfficialPath,
                    color: Colors.lightBlueAccent,
                    title: "Wall",
                    tagName: "官方",
                    controller: MessageUtil.systemStreamCntCtrl,
                    body: _latestSystemMsg == null ? noMessage : _getSystemMsgBody(),
                    time: _latestSystemMsg == null ? null : _latestSystemMsg.sentTime,
                    pointType: false,
                    onTap: () {
                      NavigatorUtils.push(context, NotificationRouter.systemMain);
                    },
                  ),
                ],
              ),
            )),
      ),
    );
  }

  String _getInteractionBody() {
    if (_latestInteractionMsg == null) {
      return noMessage;
    } else {
      if (_latestInteractionMsg.messageType == MessageType.TWEET_PRAISE) {
        TweetPraiseMessage message = _latestInteractionMsg as TweetPraiseMessage;
        return "${message.praiser.nick} 赞了你";
      } else if (_latestInteractionMsg.messageType == MessageType.TWEET_REPLY) {
        TweetReplyMessage message = _latestInteractionMsg as TweetReplyMessage;
        String content = message.delete != null && message.delete
            ? TextConstant.TEXT_TWEET_REPLY_DELETED
            : message.replyContent;
        return "${message.anonymous ? '[匿名用户]' : message.replier.nick} 回复了你: $content";
      } else if (_latestInteractionMsg.messageType == MessageType.TOPIC_REPLY) {
        TopicReplyMessage message = _latestInteractionMsg as TopicReplyMessage;
        String content = message.delete ? TextConstant.TEXT_TWEET_REPLY_DELETED : message.replyContent;

        return "${message.replier.nick} 评论了你: $content}";
      } else {
        return noMessage;
      }
    }
  }

  String _getSystemMsgBody() {
    if (_latestSystemMsg == null) {
      return noMessage;
    } else {
      if (_latestSystemMsg.messageType == MessageType.PLAIN_SYSTEM) {
        PlainSystemMessage message = _latestInteractionMsg as PlainSystemMessage;
        return "${message.title ?? message.content}";
      } else if (_latestSystemMsg.messageType == MessageType.POPULAR) {
//        PopularMessage message = _latestSystemMsg as PopularMessage;
        return "恭喜，您发布的内容登上了热门排行榜";
      } else {
        return noMessage;
      }
    }
  }

  Text _getBadgeText(dynamic content) {
    return Text(
      content.toString(),
      style: TextStyle(fontSize: Dimens.font_sp10, color: Colors.white),
    );
  }

  List<Widget> _renderActions() {
    return [
      IconButton(
//        icon: LoadAssetIcon(
//          "alert",
//          key: const Key('message'),
//          width: 24.0,
//          height: 24.0,
//          color: ThemeUtils.getIconColor(context),
//        ),
        icon: Icon(Icons.autorenew),
        onPressed: () {
          NavigatorUtils.push(context, SettingRouter.notificationSettingPage,
              transitionType: TransitionType.fadeIn);
        },
      )
    ];
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
