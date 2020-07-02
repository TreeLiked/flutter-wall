import 'package:badges/badges.dart';
import 'package:fluro/fluro.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as prefix0;
import 'package:iap_app/api/message.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/popup_window.dart';
import 'package:iap_app/common-widget/v_empty_view.dart';
import 'package:iap_app/component/tweet/tweet_card.dart';
import 'package:iap_app/component/tweet/tweet_no_data_view.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/models/tabIconData.dart';
import 'package:iap_app/page/common/tweet_type_select.dart';
import 'package:iap_app/page/home/home_comment_wrapper.dart';
import 'package:iap_app/page/personal_center/personal_center.dart';
import 'package:iap_app/page/tweet/TweetIndexTabView.dart';
import 'package:iap_app/part/hot_today.dart';
import 'package:iap_app/platform/platform_appbar.dart';
import 'package:iap_app/platform/platform_scaffold.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/routes/setting_router.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/message_util.dart';
import 'package:iap_app/util/page_shared.widget.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:iap_app/util/widget_util.dart' as wu;

class HomePage extends StatefulWidget {
  final pullDownCallBack;

  HomePage({this.pullDownCallBack});

  @override
  State<StatefulWidget> createState() {
    return new _HomePageState();
  }
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, TickerProviderStateMixin {
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  AnimationController animationController;

  ScrollController _scrollController = PageSharedWidget.homepageScrollController;

  final commentWrapperKey = GlobalKey<HomeCommentWrapperState>();

  int _currentPage = 1;

  List<String> tweetQueryTypes = List();

  AccountLocalProvider accountLocalProvider;
  TweetTypesFilterProvider typesFilterProvider;
  TweetProvider tweetProvider;

  // weather first build
  bool firstBuild = true;

  // touch position, for display or hide bottomNavigatorBar
  double startY = -1;
  double lastY = -1;

  // menu float choice
  GlobalKey _menuKey = GlobalKey();

  bool isDark = false;

  int count = 1;

  TabController _tabController;

  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();

    tabIconsList.forEach((tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    _tabController = TabController(vsync: this, length: 2);

    firstRefreshMessage();
  }

  void firstRefreshMessage() async {
//    Future.delayed(Duration(seconds: 3)).then((val) {
    MessageAPI.queryInteractionMessageCount().then((cnt) {
      MessageUtil.setNotificationCnt(cnt);
    }).whenComplete(() {
      MessageUtil.startLoopQueryNotification();
    });
//    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onRefresh(BuildContext context) async {
    print('On refresh');
    _refreshController.resetNoData();
    _currentPage = 1;
    List<BaseTweet> temp = await getData(_currentPage);
    tweetProvider.update(temp, clear: true, append: false);
    if (temp == null) {
      _refreshController.refreshFailed();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  void initData() async {
    List<BaseTweet> temp = await getData(1);
    tweetProvider.update(temp, clear: true, append: false);
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    List<BaseTweet> temp = await getData(++_currentPage);
    tweetProvider.update(temp, append: true, clear: false);
    if (CollectionUtil.isListEmpty(temp)) {
      _currentPage--;
      _refreshController.loadNoData();
    } else {
      _refreshController.loadComplete();
    }
  }

  Future getData(int page) async {
    print('get data ------$page------');
    List<BaseTweet> pbt = await (TweetApi.queryTweets(PageParam(page,
        pageSize: 10,
        orgId: Application.getOrgId,
        types: ((typesFilterProvider.selectAll ?? true) ? null : typesFilterProvider.selTypeNames))));

    return pbt;
  }

  /*
   * 显示回复框
   */
  void showReplyContainer(TweetReply tr, String destAccountNick, String destAccountId) {
    commentWrapperKey.currentState.showReplyContainer(tr, destAccountNick, destAccountId);
  }

  /*
   * 监测滑动手势，隐藏回复框
   */
  void hideReplyContainer() {
    commentWrapperKey.currentState.hideReplyContainer();
  }

  List<String> _getFilterTypes() {
    List<String> types = typesFilterProvider.selTypeNames;

    List<String> names = TweetTypeUtil.getVisibleTweetTypeMap()
        .values
        .where((f) => (!f.filterable) && f.visible)
        .map((f) => f.name)
        .toList();
    names.forEach((f) {
      if (!types.contains(f)) {
        types.add(f);
      }
    });
    types = types.toSet().toList();
    return types;
  }

  void _forwardFilterPage() async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TweetTypeSelectPage(
                  title: "过滤内容类型",
                  subTitle: '我的只看',
                  filter: true,
                  subScribe: false,
                  initFirst: _getFilterTypes(),
                  callback: (resultNames) async {
                    await SpUtil.putStringList(SharedConstant.LOCAL_FILTER_TYPES, resultNames);
                    typesFilterProvider.updateTypeNames();
                    _refreshController.requestRefresh();
                    print(resultNames);
                  },
                )));
  }

  void updateHeader(bool next) {}

  //设定Widget的偏移量
  Offset floatingOffset = Offset(20, Application.screenHeight - 150);
  double middle = Application.screenWidth / 2;
  bool stickLeft = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    isDark = ThemeUtils.isDark(context);

    typesFilterProvider = Provider.of<TweetTypesFilterProvider>(context);
    accountLocalProvider = Provider.of<AccountLocalProvider>(context);
    if (firstBuild) {
      initData();
      tweetProvider = Provider.of<TweetProvider>(context);
    }
    firstBuild = false;

    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(
          elevation: 0,
        ),
        preferredSize: Size.zero,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Padding(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Positioned(
                        left: prefix0.ScreenUtil().setWidth(10.0),
                        child: Consumer<AccountLocalProvider>(
                          builder: (_, model, __) {
                            var acc = model.account;
                            return IconButton(
                                onPressed: () {
                                  BottomSheetUtil.showBottomSheet(context, 0.75, PersonalCenter());
                                },
                                icon: AccountAvatar(avatarUrl: acc.avatarUrl, size: 33.0, cache: true));
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: prefix0.ScreenUtil().setWidth(150)),
                        child: TabBar(
                          labelStyle:
                              TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber),
                          unselectedLabelStyle: TextStyle(fontSize: 14, color: Colors.black),
                          indicatorSize: TabBarIndicatorSize.label,
                          indicator: const UnderlineTabIndicator(
                              borderSide: const BorderSide(color: Colors.amber, width: 2.0)),
                          controller: _tabController,
                          labelColor: isDark ? Color(0xffbababa) : Colors.black,
                          onTap: (index) {
                            if (index == _currentTabIndex) {
                              if (index == 0) {
                                PageSharedWidget.homepageScrollController.animateTo(.0,
                                    duration: Duration(milliseconds: 1688), curve: Curves.easeInOutQuint);
                                return;
                              }
                            }
                            _tabController.animateTo(index);
                            setState(() {
                              _currentTabIndex = index;
                            });
                          },
                          tabs: [
                            Tab(
                              text: '首页',
                            ),
                            Tab(
                              text: '热门',
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                          right: prefix0.ScreenUtil().setWidth(10.0),
//                        top: prefix0.ScreenUtil().setWidth(10.0),
                          child: IconButton(
                            icon: StreamBuilder(
                              initialData: 0,
                              stream: MessageUtil.notificationStreamCntCtrl.stream,
                              builder: (_, snapshot) => Badge(
                                elevation: 0,
                                padding: const EdgeInsets.all(3.0),
                                child: LoadAssetIcon(
                                  "notification/bell",
                                  color: snapshot.data != -1 && snapshot.data != 0
                                      ? Colors.amber
                                      : Colors.black54,
                                  width: 21.0,
                                  height: 21.0,
                                ),
                                animationType: BadgeAnimationType.fade,
                                showBadge: snapshot.data != -1 && snapshot.data != 0,
                                badgeContent: Text(
                                  '${snapshot.data}',
                                  style: const TextStyle(color: Colors.white, fontSize: Dimens.font_sp12),
                                ),
                              ),
                            ),
                            onPressed: () => NavigatorUtils.push(context, Routes.notification),
                          )),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        TweetIndexTabView(),
                        HotToday(),
                      ],
                    ),
                  ),
                ],
              ),
              padding: EdgeInsets.only(bottom: 0.0),
            ),
            _currentTabIndex == 0
                ? Positioned(
                    left: stickLeft ? 20.0 : null,
                    right: stickLeft ? null : 20.0,
                    top: floatingOffset.dy,
                    child: Draggable(
                      feedback: FloatingActionButton(
                          child: Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                          ),
                          backgroundColor: Colors.amber[300],
                          elevation: 0.0,
                          onPressed: null),
                      child: FloatingActionButton(
                          child: Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                          ),
                          backgroundColor: Colors.amber[300],
                          elevation: 10.0,
                          splashColor: Colors.amber,
                          onPressed: () => NavigatorUtils.push(context, Routes.create,
                              transitionType: TransitionType.fadeIn)),

                      //拖动过程中，在原来位置停留的Widget，设定这个可以保留原本位置的残影，如果不需要可以直接设置为Container()
                      childWhenDragging: Container(),
                      //拖动结束后的Widget
                      onDragEnd: (details) {
                        double targetX = details.offset.dx;
                        double targetY = details.offset.dy;
                        if (targetY >= Application.screenHeight - 150 || targetY <= 20) {
                          targetY = Application.screenHeight - 150;
                        }
                        setState(() {
                          stickLeft = targetX < middle;
                          floatingOffset = new Offset(0.0, targetY);
                        });
                      },
                    ),
                  )
                : Gaps.empty,
          ],
        ),
      ),
    );
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        centerTitle: true,
        backgroundColor: isDark ? Colours.dark_bg_color : Color(0xfff4f5f6),
        //标题居中

        title: GestureDetector(
            child: Text(
              Application.getOrgName ?? TextConstant.TEXT_UN_CATCH_ERROR,
              style: TextStyle(fontSize: Dimens.font_sp15, fontWeight: FontWeight.w400),
            ),
            onTap: () => PageSharedWidget.homepageScrollController
                .animateTo(.0, duration: Duration(milliseconds: 1688), curve: Curves.easeInOutQuint)),
        elevation: 0.3,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.blur_on),
            onPressed: () {
              NavigatorUtils.push(context, Routes.square, transitionType: TransitionType.fadeIn);
            },
          ),
          IconButton(
              key: _menuKey,
              icon: Icon(Icons.add),
              onPressed: _showAddMenu,
              color: ThemeUtils.getIconColor(context)),
        ],

        expandedHeight: 0,
        // expandedHeight: SizeConstant.HP_COVER_HEIGHT,
        // backgroundColor: GlobalConfig.DEFAULT_BAR_BACK_COLOR,
        // backgroundColor: Colors.transparent,
        floating: false,
        pinned: true,
        snap: false,
//         flexibleSpace: FlexibleSpaceBar(
//             background: CachedNetworkImage(
//           imageUrl:
//               'https://tva1.sinaimg.cn/large/00831rSTgy1gdf8bz0p5xj31hc0u0n01.jpgs',
//           fit: BoxFit.cover,
//         )),
      ),
    ];
  }

  _showAddMenu() {
    final RenderBox button = _menuKey.currentContext.findRenderObject();
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    var a =
        button.localToGlobal(Offset(button.size.width - 8.0, button.size.height - 12.0), ancestor: overlay);
    var b = button.localToGlobal(button.size.bottomLeft(Offset(0, -12.0)), ancestor: overlay);
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(a, b),
      Offset.zero & overlay.size,
    );
    final Color backgroundColor = ThemeUtils.getBackgroundColor(context);
    final Color _iconColor = ThemeUtils.getIconColor(context);
    showPopupWindow(
        context: context,
        fullWidth: false,
        isShowBg: true,
        position: position,
        elevation: 0.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: LoadAssetIcon(
                "jt",
                width: 8.0,
                height: 4.0,
                color: ThemeUtils.getDarkColor(context, Colours.dark_bg_color),
              ),
            ),
            SizedBox(
              width: 120.0,
              height: 40.0,
              child: FlatButton.icon(
                  textColor: Theme.of(context).textTheme.body1.color,
                  color: backgroundColor,
                  onPressed: () {
                    NavigatorUtils.goBack(context);
                    _forwardFilterPage();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
                  ),
                  icon: LoadAssetIcon(
                    "filter",
                    width: 16.0,
                    height: 16.0,
                    color: _iconColor,
                  ),
                  label: const Text("筛 选")),
            ),
            // Container(
            //   width: 120.0,
            //   height: 0.6,
            //   color: Colours.line,
            //   padding: EdgeInsets.symmetric(horizontal: 0),
            // ),
            // Gaps.vGap4,
            SizedBox(
              width: 120.0,
              height: 40.0,
              child: FlatButton.icon(
                  textColor: Theme.of(context).textTheme.body1.color,
                  onPressed: () {
                    NavigatorUtils.goBack(context);

                    NavigatorUtils.push(context, Routes.create, transitionType: TransitionType.fadeIn);
                    // NavigatorUtils.push(context, Routes.create,
                    //     transitionType: TransitionType.fadeIn);
                  },
                  color: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: const Radius.circular(8.0), bottomRight: const Radius.circular(8.0)),
                  ),
                  icon: LoadAssetIcon(
                    "create",
                    width: 16.0,
                    height: 16.0,
                    color: _iconColor,
                  ),
                  label: const Text("发 布")),
            ),
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
