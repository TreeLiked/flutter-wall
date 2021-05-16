import 'dart:ui';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:iap_app/api/circle.dart';
import 'package:iap_app/api/message.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/component/circle/circle_simple_item.dart';
import 'package:iap_app/model/circle/circle.dart';
import 'package:iap_app/model/circle_query_param.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/part/circle/circle_main.dart';
import 'package:iap_app/part/circle/circle_square_tab.dart';
import 'package:iap_app/part/notification/circle_system_card.dart';
import 'package:iap_app/part/notification/interation_card.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/umeng_util.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CircleNotificationMainPage extends StatefulWidget {
  @override
  _CircleNotificationMainPageState createState() => _CircleNotificationMainPageState();
}

class _CircleNotificationMainPageState extends State<CircleNotificationMainPage>
    with AutomaticKeepAliveClientMixin<CircleNotificationMainPage>, SingleTickerProviderStateMixin {
  bool isDark = false;

  RefreshController _refreshController = RefreshController(initialRefresh: true);

  int currentPage = 1;
  int pageSize = 25;

  TabController _tabController;
  int _currentSelectIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentSelectIndex = _tabController.index;
      });
    });
  }

  void _readAll() async {
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
        centerTitle: "圈子消息",
        isBack: true,
        actionColor: Colors.green,
        actionName: _currentSelectIndex == 1 ? '' : '全部已读',
        onPressed: _currentSelectIndex == 1 ? null : _readAll,
      ),
      body: CustomScrollView(slivers: <Widget>[
        SliverPersistentHeader(
          // 可以吸顶的TabBar
          pinned: true,
          delegate: StickyTabBarDelegate(
            child: TabBar(
              labelColor: Colors.black,
              isScrollable: false,
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 2.0, color: Colors.green),
                  insets: EdgeInsets.symmetric(horizontal: 1.0, vertical: 0.0)),
              tabs: <Widget>[
                Tab(child: Text('互动', style: pfStyle.copyWith(color: _getTabColor(0)))),
                Tab(child: Text('系统', style: pfStyle.copyWith(color: _getTabColor(1)))),
              ],
            ),
          ),
        ),
        SliverPadding(
            padding: const EdgeInsets.only(bottom: 0.0),
            sliver: SliverFillRemaining(
                // 剩余补充内容TabBarView
                child: TabBarView(controller: _tabController, children: <Widget>[
              CircleInteractionTabView(refreshWidgetColor: Color(0xffE6E6FA)),
              CircleSystemTabView(refreshWidgetColor: Color(0xffE6E6FA))
            ])))
      ]),
    );
  }

  Color _getTabColor(int index) {
    if (_currentSelectIndex == index) {
      return isDark ? Colors.white : Colors.black;
    }
    return isDark ? Colors.white38 : Colors.black54;
  }

  @override
  bool get wantKeepAlive => true;
}

class CircleInteractionTabView extends StatefulWidget {
  /// 下拉刷新的颜色
  final Color refreshWidgetColor;

  CircleInteractionTabView({this.refreshWidgetColor = Colors.blue});

  @override
  State<StatefulWidget> createState() {
    return _CircleInteractionTabViewState();
  }
}

class _CircleInteractionTabViewState extends State<CircleInteractionTabView> {
  final String _TAG = "_CircleInteractionTabViewState";

  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController = RefreshController(initialRefresh: true);

  int _currentPage = 1;
  List<Circle> _circles = List();

  bool isDark = false;

  void _initData() {}

  Future<void> _onRefresh() async {
    LogUtil.e("---onRefresh---", tag: _TAG);
    _refreshController.resetNoData();
    _currentPage = 1;
    List<Circle> temp = await getData(_currentPage);
    // tweetProvider.update(temp, clear: true, append: false);
    // MessageUtil.clearTabIndexTweetCnt();
    setState(() {
      this._circles = temp;
    });
    if (temp == null) {
      _refreshController.refreshFailed();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  Future<void> _onLoading() async {
    setState(() {
      _initData();
    });
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    _initData();
    UMengUtil.userGoPage(UMengUtil.PAGE_NOTI_CIRCLE_SYSTEM);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isDark = ThemeUtils.isDark(context);

    bool noData = true;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[];
        },
        body: SmartRefresher(
          enablePullUp: true,
          enablePullDown: true,
          primary: false,
          scrollController: _scrollController,
          controller: _refreshController,
          cacheExtent: 20,
          header: WaterDropHeader(
              waterDropColor: isDark ? Color(0xff6E7B8B) : widget.refreshWidgetColor,
              complete: const Text('刷新完成', style: pfStyle)),
          footer: ClassicFooter(
            loadingText: '正在加载...',
            canLoadingText: '释放以加载更多',
            noDataText: '到底了哦',
            idleText: '继续上滑',
          ),
          child: _circles == null
              ? Align(
                  alignment: Alignment.topCenter,
                  child: WidgetUtil.getLoadingAnimation(),
                )
              : _circles.length == 0
                  ? _noDataView()
                  : ListView.builder(
                      itemCount: _circles.length,
                      itemBuilder: (ctx, index) {
                        return CircleSimpleItem(_circles[index]);
                      }),
          onRefresh: () => _onRefresh(),
          onLoading: _onLoading,
        ),
      ),
    );
  }

  _noDataView() {
    return Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.only(top: 50.0),
      child: Text('暂无消息', style: pfStyle.copyWith(color: Colors.grey, fontSize: Dimens.font_sp13p5)),
    );
  }

  // _forwardDetail(int tweetId, int rank) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //         builder: (context) => TweetDetail(null, tweetId: tweetId, hotRank: rank, newLink: true)),
  //   );
  // }

  Future getData(int page) async {
    List<Circle> pbt = await (CircleApi.queryCircles(CircleQueryParam(
      page,
      pageSize: 10,
      orgId: Application.getOrgId,
    )));
    return pbt;
  }
}

class CircleSystemTabView extends StatefulWidget {
  /// 下拉刷新的颜色
  final Color refreshWidgetColor;

  CircleSystemTabView({this.refreshWidgetColor = Colors.blue});

  @override
  State<StatefulWidget> createState() {
    return _CircleSystemTabViewState();
  }
}

class _CircleSystemTabViewState extends State<CircleSystemTabView> {
  final String _TAG = "_CircleSystemTabViewState";

  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController = RefreshController(initialRefresh: true);

  List<AbstractMessage> msgs;

  int _currentPage = 1;
  int _pageSize = 20;

  bool isDark = false;

  void _fetchMessages() async {
    _currentPage = 1;
    List<AbstractMessage> msgs = await getData(1, _pageSize);
    if (CollectionUtil.isListEmpty(msgs)) {
      setState(() {
        this.msgs = [];
      });
      _refreshController.refreshCompleted();
      return;
    }
    setState(() {
      this.msgs = msgs;
    });
    _refreshController.refreshCompleted(resetFooterState: true);
  }

  Future<void> _onLoading() async {
    List<AbstractMessage> msgs = await getData(++_currentPage, _pageSize);
    if (CollectionUtil.isListEmpty(msgs)) {
      _refreshController.loadNoData();
      return;
    }
    setState(() {
      if (this.msgs == null) {
        this.msgs = [];
      }
      this.msgs.addAll(msgs);
    });
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    UMengUtil.userGoPage(UMengUtil.PAGE_TWEET_INDEX_HOT);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isDark = ThemeUtils.isDark(context);

    return Scaffold(
        body: SmartRefresher(
      enablePullUp: true,
      enablePullDown: true,
      primary: false,
      scrollController: _scrollController,
      controller: _refreshController,
      cacheExtent: 20,
      header: WaterDropHeader(
          waterDropColor: isDark ? Color(0xff6E7B8B) : widget.refreshWidgetColor,
          complete: const Text('刷新完成', style: pfStyle)),
      footer: ClassicFooter(
        loadingText: '正在加载...',
        canLoadingText: '释放以加载更多',
        noDataText: '到底了哦',
        idleText: '继续上滑',
      ),
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
                    return CircleSystemCard(msgs[index]);
                  }),
      onRefresh: () => _fetchMessages(),
      onLoading: _onLoading,
    ));
  }

  _noDataView() {
    return Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.only(top: 50.0),
      child: Text('暂无消息', style: pfStyle.copyWith(color: Colors.grey, fontSize: Dimens.font_sp13p5)),
    );
  }

  Future<List<AbstractMessage>> getData(int currentPage, int pageSize) async {
    return await MessageAPI.queryCircleSystemMsg(currentPage, pageSize);
  }
}
