import 'dart:async';
import 'dart:math';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/api/message.dart';
import 'package:iap_app/common-widget/text_clickable_iitem.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:iap_app/model/message/plain_system_message.dart';
import 'package:iap_app/model/message/popular_message.dart';
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
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/message_util.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';
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
    _loopQueryInteraction(true);
    _loopQuerySystem(true);
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
        Future.delayed(Duration(minutes: 30)).then((_) {
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

    checkAndRequestNotificationPermission();
    isDark = ThemeUtils.isDark(context);
    Color _badgeColor = isDark ? Colours.dark_app_main : Colours.app_main;

    return Scaffold(
      backgroundColor: ThemeUtils.getBackColor(context),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('消息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: false,
            header: MaterialClassicHeader(
              color: Colors.pinkAccent,
            ),
            onRefresh: _fetchLatestMessage,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  MainMessageItem(
                    iconPath: iconSubPath,
                    title: "订阅消息",
                    body: "暂无订阅消息",
                    color: Colors.lightBlue,
                    onTap: () => ToastUtil.showToast(context, "当前没有订阅内容"),
                  ),
                  MainMessageItem(
                      iconPath: iconSchoolPath,
                      title: "校园通知",
                      tagName: "官方",
                      body: "暂无通知",
                      pointType: true,
                      onTap: () {
                        NavigatorUtils.push(context, NotificationRouter.campusMain);
                      },
                      color: Colors.amber),
                  MainMessageItem(
                      iconPath: iconContactPath,
                      color: Colors.lightGreen,
                      title: "互动消息",
                      body: _latestInteractionMsg == null ? noMessage : _getInteractionBody(),
                      time: _latestInteractionMsg == null ? null : _latestInteractionMsg.sentTime,
                      controller: MessageUtil.interactionMsgControl.controller,
                      onTap: () {
                        _latestInteractionMsg = null;
                        interactionMsgCtrl.clear();
                        MessageUtil.clearNotificationCnt();
                        NavigatorUtils.push(context, NotificationRouter.interactiveMain);
                      }),
                  Gaps.vGap5,
                  MainMessageItem(
                    iconPath: iconOfficialPath,
                    color: Colors.pinkAccent,
                    title: "墙君",
                    tagName: "官方",
                    controller: MessageUtil.systemStreamCntCtrl,
                    body: _latestSystemMsg == null ? noMessage : _getSystemMsgBody(),
                    time: _latestSystemMsg == null ? null : _latestSystemMsg.sentTime,
                    pointType: true,
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
        String content = message.delete != null && message.delete ? TextConstant.TEXT_TWEET_REPLY_DELETED : message.replyContent;
        return "${message.anonymous ? '[匿名用户]' : message.replier.nick} 评论了你: $content";
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

  void checkAndRequestNotificationPermission() async {
    PermissionStatus permission =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.notification);

    if (permission != PermissionStatus.granted) {
//      Map<PermissionGroup, PermissionStatus> permissions =
      await PermissionHandler().requestPermissions([PermissionGroup.notification]);
      permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.notification);
      if (permission != PermissionStatus.granted) {
        int random = Random().nextInt(100);
        if (random == 79) {
          print(random);
          Utils.showSimpleConfirmDialog(
              context,
              '无法发送通知',
              '你未开启"允许Wall发送通知"选项，将收不到包括用户私信，点赞评论等的通知',
              ClickableText('知道了', () {
                NavigatorUtils.goBack(context);
              }),
              ClickableText('去设置', () async {
                await PermissionHandler().openAppSettings();
              }),
              barrierDismissible: false);
        }
      }
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
