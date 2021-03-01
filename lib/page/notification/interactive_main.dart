import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:iap_app/api/message.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/part/notification/interation_card.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class InteractiveNotificationMainPage extends StatefulWidget {
  @override
  _InteractiveNotificationMainPageState createState() => _InteractiveNotificationMainPageState();
}

class _InteractiveNotificationMainPageState extends State<InteractiveNotificationMainPage>
    with AutomaticKeepAliveClientMixin<InteractiveNotificationMainPage> {
  bool isDark = false;

  List<AbstractMessage> msgs;

  RefreshController _refreshController = RefreshController(initialRefresh: true);

  int currentPage = 1;
  int pageSize = 25;

  @override
  void initState() {
    super.initState();
  }

  void _fetchInteractiveMessages() async {
    currentPage = 1;
    List<AbstractMessage> msgs = await getData(1, pageSize);
    if (msgs == null || msgs.length == 0) {
      setState(() {
        this.msgs = [];
      });
      _refreshController.refreshCompleted(resetFooterState: true);
      return;
    }
    setState(() {

      if (this.msgs != null) {
        this.msgs.clear();
      } else {
        this.msgs = List();
      }
      this.msgs.addAll(msgs);
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
      if (this.msgs == null) {
        this.msgs = List();
      }
      this.msgs.addAll(msgs);
    });
    _refreshController.loadComplete();
  }

  Future<List<AbstractMessage>> getData(int currentPage, int pageSize) async {
    return await MessageAPI.queryInteractionMsg(currentPage, pageSize);
  }

  void _readAll() async {
    if (msgs == null || msgs.length == 0) {
      ToastUtil.showToast(context, '暂无消息');
      return;
    }
    Utils.showDefaultLoadingWithBounds(context);
    Result r = await MessageAPI.readAllInteractionMessage(pop: false);
    NavigatorUtils.goBack(context);
    if (r != null && r.isSuccess) {
      _refreshController.requestRefresh();
    } else {
      ToastUtil.showToast(context, r.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    isDark = ThemeUtils.isDark(context);
    return Scaffold(
//        backgroundColor: isDark ? Colours.dark_bg_color : Colours.bg_color,
        appBar: MyAppBar(
          centerTitle: "个人通知",
          isBack: true,
          actionName: '全部已读',
          onPressed: CollectionUtil.isListEmpty(msgs) ? null : _readAll,
        ),
        body: SafeArea(
            top: false,
            child: SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: true,
                header: WaterDropHeader(
                  waterDropColor: Colors.amber[700],
                  complete: const Text('刷新完成'),
                ),
                footer: ClassicFooter(
                  loadingText: '正在加载更多消息...',
                  canLoadingText: '释放以加载更多',
                  noDataText: '没有更多消息了',
                  idleText: '继续上滑',
                ),
                onLoading: _loadMore,
                onRefresh: _fetchInteractiveMessages,
                child: msgs == null
                    ? Gaps.empty
                    : msgs.length == 0
                        ? Container(
                            alignment: Alignment.topCenter,
                            margin: const EdgeInsets.only(top: 50),
                            child: Text('暂无消息'),
                          )
                        : ListView.builder(
                            itemCount: msgs.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return InteractionCardItem(msgs[index]);
                            }))));
  }

  @override
  bool get wantKeepAlive => true;
}
