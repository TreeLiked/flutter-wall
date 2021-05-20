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
import 'package:iap_app/model/message/circle_system_message.dart';
import 'package:iap_app/model/message/plain_system_message.dart';
import 'package:iap_app/model/message/topic_reply_message.dart';
import 'package:iap_app/model/message/tweet_praise_message.dart';
import 'package:iap_app/model/message/tweet_reply_message.dart';
import 'package:iap_app/page/notification/index_main_item.dart';
import 'package:iap_app/page/notification/index_main_item_new.dart';
import 'package:iap_app/provider/msg_provider.dart';
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
import 'package:provider/provider.dart';
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
  String circleNotiPath = "circle_noti";
  String iconContactPath = "contact2";
  String iconOfficialPath = "official2";
  static const String _TAG = "_NotificationIndexPageState";

  final String noMessage = "暂无新通知";

  bool isDark = false;

  RefreshController _refreshController = new RefreshController(initialRefresh: true);

  dynamic _latestInteractionMsg;
  dynamic _latestSystemMsg;
  dynamic _latestCircleMsg;

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
    _fetchLatestMessage();

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
    _refreshController.refreshCompleted();
  }

  _fetchLatestMessage() async {
    MessageUtil.queryTweetInterMsgCnt(context).then((value) {
      if (value > 0) {
        _fetchLatestInteractionMsg();
      }
    });
    MessageUtil.querySysMsgCnt(context).then((value) {
      if (value > 0) {
        _fetchLatestSystemMsg();
      }
    });
    MessageUtil.queryCircleMsgCntTotal(context).then((value) {
      if (value > 0) {
        _fetchLatestCircleMsg();
      }
    });
  }

  // 查询的具体的系统消息内容
  Future<void> _fetchLatestSystemMsg() async {
    MessageAPI.fetchLatestMessage(MessageCategory.SYSTEM).then((msg) {
      setState(() {
        this._latestSystemMsg = msg;
      });
    });
  }

  // 查询的具体的互动消息内容
  Future<void> _fetchLatestInteractionMsg() async {
    MessageAPI.fetchLatestMessage(MessageCategory.INTERACTION).then((msg) {
      if (msg != null && msg.readStatus == ReadStatus.UNREAD) {
        setState(() {
          this._latestInteractionMsg = msg;
        });
      }
    });
  }

  // 查询最新的圈子内容
  Future<void> _fetchLatestCircleMsg() async {
    AbstractMessage msg1 = await MessageAPI.fetchLatestMessage(MessageCategory.CIRCLE_INTERACTION);
    AbstractMessage msg2 = await MessageAPI.fetchLatestMessage(MessageCategory.CIRCLE_SYS);
    if (msg1 == null) {
      setState(() {
        _latestCircleMsg = msg2;
      });
      return;
    }
    if (msg2 == null) {
      setState(() {
        _latestCircleMsg = msg1;
      });
      return;
    }
    setState(() {
      _latestCircleMsg = msg1.sentTime.compareTo(msg2.sentTime) > 0 ? msg1 : msg2;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    LogUtil.e('notification build', tag: _TAG);
//    print('notification' + (ModalRoute.of(context).isCurrent ? "当前页面" : "不是当前页面"));

    isDark = ThemeUtils.isDark(context);

    return Consumer<MsgProvider>(builder: (_, provider, __) {
      return Scaffold(
        backgroundColor: ThemeUtils.getBackColor(context),
        appBar: AppBar(
          backgroundColor: isDark ? ColorConstant.MAIN_BG_DARK : Colors.white,
          automaticallyImplyLeading: false,
          title: Text('我的消息',
              style: pfStyle.copyWith(
                  fontSize: Dimens.font_sp16p5, fontWeight: FontWeight.w400, letterSpacing: 1.2)),
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
                waterDropColor: isDark ? Color(0xff6E7B8B) : Color(0xffE6E6FA),
                complete: const Text('刷新完成', style: pfStyle),
              ),
//            header: Utils.getDefaultRefreshHeader(),
              onRefresh: _fetchLatestMessageAndCount,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    MainMessageItemNew(
                      iconPath: iconSubPath,
                      iconPadding: 8.5,
                      iconColor: Color(0xff87CEFF),
                      title: "私信",
                      body: "暂无私信消息",
                      color: Color(0xffF0F8FF),
                      onTap: () => ToastUtil.showToast(context, "当前没有私信消息"),
                    ),
                    MainMessageItemNew(
                      iconPath: iconSchoolPath,
                      title: "校园",
                      official: true,
                      body: "暂无新通知",
                      pointType: true,
                      onTap: () {
                        NavigatorUtils.push(context, NotificationRouter.campusMain);
                      },
                      color: Color(0xffFCF1F4),
                      iconColor: Color(0xffFF69B4),
                    ),
                    MainMessageItemNew(
                      iconPath: circleNotiPath,
                      title: "圈子",
                      official: true,
                      body: _getCircleMsgBody(),
                      iconPadding: 8.5,
                      msgCnt: provider.circleTotal,
                      onTap: () {
                        NavigatorUtils.push(context, NotificationRouter.circleMain);
                      },
                      color: Colors.lightGreen[50],
                      iconColor: Colors.lightGreen,
                    ),
                    MainMessageItemNew(
                        iconPath: iconContactPath,
                        color: Color(0xffEBFAF4),
                        iconColor: Color(0xff00CED1),
                        iconPadding: 9.5,
                        title: "互动",
                        msgCnt: provider.tweetInterCnt,
                        body: _getInteractionBody(),
                        time: _latestInteractionMsg == null ? null : _latestInteractionMsg.sentTime,
                        onTap: () {
                          _latestInteractionMsg = null;
                          NavigatorUtils.push(context, NotificationRouter.interactiveMain);
                        }),
                    Gaps.vGap8,
                    MainMessageItemNew(
                      iconPath: iconOfficialPath,
                      color: Color(0xffFEF7E7),
                      iconColor: Color(0xffDAA520),
                      title: "WALL",
                      tagName: "官方",
                      msgCnt: provider.sysCnt,
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
    });
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

  String _getCircleMsgBody() {
    if (_latestCircleMsg == null) {
      return noMessage;
    } else {
      CircleSystemMessage message = _latestCircleMsg as CircleSystemMessage;
      return message.getSimpleBody();
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
