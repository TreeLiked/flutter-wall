import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:iap_app/api/message.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:iap_app/part/notification/my_sn_card.dart';
import 'package:iap_app/part/notification/system_card.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/resources.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/image_utils.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SystemNotificationMainPage extends StatefulWidget {
  @override
  _SystemNotificationMainPageState createState() => _SystemNotificationMainPageState();
}

class _SystemNotificationMainPageState extends State<SystemNotificationMainPage> {
  bool isDark = false;

  RefreshController _refreshController = RefreshController(initialRefresh: true);
  int currentPage = 1;
  int pageSize = 25;

  List<Widget> sysMsgList;
  List<AbstractMessage> sysMsgs;

  @override
  void initState() {
    super.initState();
  }

  void _fetchSystemMessages() async {
    print('--------------------------请求系统消息---------------');
    currentPage = 1;
    List<AbstractMessage> msgs = await getData(1, pageSize);
    if (msgs == null || msgs.length == 0) {
      _refreshController.refreshCompleted(resetFooterState: true);
      setState(() {
        this.sysMsgs = [];
      });
      return;
    }

    setState(() {
      if (this.sysMsgs != null) {
        this.sysMsgs.clear();
      } else {
        this.sysMsgs = List();
      }
      this.sysMsgs.addAll(msgs);
    });
    _refreshController.refreshCompleted(resetFooterState: true);
  }

  void _loadMore() async {
    List<AbstractMessage> msgs = await getData(++currentPage, pageSize);
    if (msgs == null || msgs.length == 0) {
      _refreshController.loadNoData();
      return;
    }
    setState(() {
      if (this.sysMsgs == null) {
        this.sysMsgs = List();
      }
      this.sysMsgs.addAll(msgs);
    });
    _refreshController.loadComplete();
  }

  Future<List<AbstractMessage>> getData(int currentPage, int pageSize) async {
    return await MessageAPI.querySystemMsg(currentPage, pageSize);
  }

  @override
  Widget build(BuildContext context) {
    isDark = ThemeUtils.isDark(context);
    return Scaffold(
//        backgroundColor: isDark ? Colours.dark_bg_color : Colours.bg_color,
        appBar: MyAppBar(
          centerTitle: "官方通知",
          isBack: true,
        ),
        body: SafeArea(
            top: false,
            child: SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: true,
                header: WaterDropHeader(
                  waterDropColor: Color(0xff00CED1),
                  complete: const Text('刷新完成'),
                ),
                footer: ClassicFooter(
                  loadingText: '正在加载更多消息...',
                  canLoadingText: '释放以加载更多',
                  noDataText: '没有更多消息了',
                  idleText: '继续上滑',
                ),
                onLoading: _loadMore,
                onRefresh: _fetchSystemMessages,
                child: sysMsgs == null
                    ? Gaps.empty
                    : sysMsgs.length == 0
                        ? Container(
                            alignment: Alignment.topCenter,
                            margin: const EdgeInsets.only(top: 50),
                            child: Text('暂无消息'),
                          )
                        : ListView.builder(
                            itemCount: sysMsgs.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return SystemCardItem(sysMsgs[index]);
                            }))));
  }
}

class SystemCard extends StatelessWidget {
  final String title;
  final String cover;
  final String content;
  final String jumpUrl;
  final Function onClick;
  final DateTime date;

  final bool isDark;

  SystemCard(
      {this.title, this.cover, this.content, this.jumpUrl, this.onClick, this.isDark = false, this.date});

  @override
  Widget build(BuildContext context) {
    return MyShadowCard(
        onClick: onClick,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _dateTimeContainer(context),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Text(
                    title ?? "系统通知",
                    style: MyDefaultTextStyle.getMainTextBodyStyle(isDark),
                  )),
                  onClick != null
                      ? Container(
                          margin: const EdgeInsets.only(right: 4.0),
                          height: 8.0,
                          width: 8.0,
                          decoration: BoxDecoration(
                            color: Colours.app_main,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        )
                      : Gaps.empty,
                  onClick != null ? Images.arrowRight : Gaps.empty
                ],
              ),
              Gaps.vGap8,
              Gaps.line,
              cover != null
                  ? Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: 180,
                      ),
                      child: ClipRRect(
                        child: FadeInImage(
                          placeholder: ImageUtils.getImageProvider('https://via.placeholder.com/180'),
                          image: NetworkImage(cover),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: const BorderRadius.all(const Radius.circular(10)),
                      ),
                    )
                  : Gaps.empty,
              Gaps.vGap8,
              Text(content ?? '', style: MyDefaultTextStyle.getSubTextBodyStyle(isDark)),
            ],
          ),
        ));
  }

  _dateTimeContainer(context) {
    return date != null
        ? Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.only(bottom: 10),
            child: Text(TimeUtil.getShortTime(date), style: MyDefaultTextStyle.getTweetTimeStyle(context)),
          )
        : Gaps.empty;
  }
}
