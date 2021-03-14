import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:iap_app/api/message.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/global/theme_constant.dart';
import 'package:iap_app/model/im_dto.dart';
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
import 'package:event_bus/event_bus.dart';

class NotificationIndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    print('NotificationIndexPage create state');
    return _NotificationIndexPageState();
  }
}

class _NotificationIndexPageState extends State<NotificationIndexPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<NotificationIndexPage> {
  String iconSubPath = "self2";
  String iconSchoolPath = "school2";
  String iconContactPath = "contact2";
  String iconOfficialPath = "official2";

  final String noMessage = "暂无新通知";

  bool isDark = false;

  RefreshController _refreshController = new RefreshController(initialRefresh: true);

  dynamic _latestInteractionMsg;
  dynamic _latestSystemMsg;

  SingleMessageControl interactionMsgCtrl = MessageUtil.interactionMsgControl;
  SingleMessageControl sysMsgCtrl = MessageUtil.systemMsgControl;

  // 控制消息总线
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    // 校验通知权限
    UMengUtil.userGoPage(UMengUtil.PAGE_NOTI_INDEX);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      checkNotification();
    });

    _subscription = wsCommandEventBus.on<ImDTO>().listen((ImDTO data) {
      int c = data.command;
      if (c == ImDTO.COMMAND_TWEET_PRAISED || c == ImDTO.COMMAND_TWEET_REPLIED) {
        _fetchLatestMessageAndCount();
      }
    });
    _subscription.resume();
  }

  void checkNotification() async {
    Future.delayed(Duration(seconds: 3)).then((value) =>
        PermissionUtil.checkAndRequestNotification(context, showTipIfDetermined: true, probability: 39));
  }

  _fetchLatestMessageAndCount() async {
    await _queryInteractionMsgAndCnt();
    await _querySystemMsgCnt();
    if (_refreshController.isRefresh) {
      _refreshController.refreshCompleted();
    }
  }

  _fetchLatestMessage() async {
    _fetchLatestSystemMsg();
    _fetchLatestInteractionMsg();
  }

  // 查询的具体的系统消息内容
  Future<void> _fetchLatestSystemMsg() async {
    MessageAPI.fetchLatestMessage(0).then((msg) {
      setState(() {
        this._latestSystemMsg = msg;
      });
    }).whenComplete(() => _refreshController.refreshCompleted());
  }

  // 查询的具体的互动消息内容
  Future<void> _fetchLatestInteractionMsg() async {
    MessageAPI.fetchLatestMessage(1).then((msg) {
      if (msg != null && msg.readStatus == ReadStatus.UNREAD) {
        setState(() {
          this._latestInteractionMsg = msg;
        });
      }
    }).whenComplete(() => _refreshController.refreshCompleted());
  }

  // 查询互动消息数量并查询消息
  _queryInteractionMsgAndCnt() {
    MessageAPI.queryInteractionMessageCount().then((count) {
      _fetchLatestInteractionMsg().then((_) {
        // 刷新完成后增加小红点
        interactionMsgCtrl.streamCount = count;
      });
      if (count != -1) {
        if (interactionMsgCtrl.localCount != count) {
          interactionMsgCtrl.localCount = count;
          print('发现新消息，开始刷新');
        }
      }
    });
  }

  // 查询系统数量并查询消息
  _querySystemMsgCnt() {
    MessageAPI.querySystemMessageCount().then((count) {
      _fetchLatestSystemMsg().then((_) {
        // 查询完增加小红点
        sysMsgCtrl.streamCount = count;
      });
      if (count != -1) {
        if (sysMsgCtrl.localCount != count) {
          sysMsgCtrl.localCount = count;
        }
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
        backgroundColor: isDark ? Colours.dark_bottom_sheet : Colors.white,
        automaticallyImplyLeading: false,
        title: Text('消息',
            style: pfStyle.copyWith(
                fontSize: Dimens.font_sp18, fontWeight: FontWeight.w400, letterSpacing: 1.3)),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back), iconSize: 23.0, onPressed: () => NavigatorUtils.goBack(context)),
      ),
      body: SafeArea(
        top: false,
        child: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: false,
            // header: MaterialClassicHeader(
            //   color: Colors.amber,
            //   backgroundColor: isDark ? ColorConstant.MAIN_BG_DARK : ColorConstant.MAIN_BG,
            // ),
            header: WaterDropHeader(
              waterDropColor: isDark ? Color(0xff6E7B8B) : Color(0xffEED2EE),
              complete: const Text('刷新完成', style: pfStyle),
            ),
//            header: Utils.getDefaultRefreshHeader(),
            onRefresh: _fetchLatestMessageAndCount,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  MainMessageItem(
                    iconPath: iconSubPath,
                    iconColor: Color(0xff87CEFF),
                    title: "私信",
                    body: "暂无私信消息",
                    color: Color(0xffF0F8FF),
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
                    color: Color(0xffFCF1F4),
                    iconColor: Color(0xffFF69B4),
                  ),
                  MainMessageItem(
                      iconPath: iconContactPath,
                      color: Color(0xffEBFAF4),
                      iconColor: Color(0xff00CED1),
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
                    color: Color(0xffFEF7E7),
                    iconColor: Color(0xffDAA520),
                    title: "Wall",
                    tagName: "官方",
                    controller: MessageUtil.systemMsgControl.controller,
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
