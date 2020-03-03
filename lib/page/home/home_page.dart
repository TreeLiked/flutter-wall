import 'dart:ui';

import 'package:fluro/fluro.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as prefix2;
import 'package:iap_app/api/message.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/popup_window.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/models/tabIconData.dart';
import 'package:iap_app/page/common/tweet_type_select.dart';
import 'package:iap_app/page/home/home_comment_wrapper.dart';
import 'package:iap_app/page/home/second_floor.dart';
import 'package:iap_app/page/index/index.dart';
import 'package:iap_app/page/square/index.dart';
import 'package:iap_app/part/recom.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/message_util.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:iap_app/component/link_header.dart' as prefix1;

class HomePage extends StatefulWidget {
  final pullDownCallBack;

  HomePage({this.pullDownCallBack});

  @override
  State<StatefulWidget> createState() {
    return new _HomePageState();
  }
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin<HomePage> {
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  ScrollController _scrollController = ScrollController();
  List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  AnimationController animationController;

  final commentWrapperKey = GlobalKey<HomeCommentWrapperState>();

  int _currentPage = 1;

  List<String> tweetQueryTypes = List();

  Function sendCallback;

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

  @override
  void initState() {
    super.initState();

    tabIconsList.forEach((tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    _scrollController.addListener(() {
      // TODO 自动加载更多
//      ScrollNotification scroll = notification as ScrollNotification;
//      // 当前滑动距离
//      double currentExtent = scroll.metrics.pixels;
//      double maxExtent = scroll.metrics.maxScrollExtent;
//      if (maxExtent - currentExtent > widget.startLoadMoreOffset) {
//        // 开始加载更多
//
//      }
    });

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

  Widget tabBody = Container(
    color: Color(0xFFF2F3F8),
  );

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
        pageSize: 5,
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
                    print("callbacl result names");
                    await SpUtil.putStringList(SharedConstant.LOCAL_FILTER_TYPES, resultNames);
                    typesFilterProvider.updateTypeNames();
                    _refreshController.requestRefresh();
                    print(resultNames);
                  },

                  // callback: (_) {
                  //   // _refreshController.requestRefresh();
                  //   _esRefreshController.resetLoadState();
                  //   _esRefreshController.callRefresh();
                  // },
                )));
    // MaterialPageRoute(
    //     builder: (context) => TweetTypeSelect(
    //           title: "过滤内容类型",
    //           multi: true,
    //           backText: "编辑",
    //           finishText: "完成",
    //           initNames: typesFilterProvider.selTypeNames,
    //           callback: (_) {
    //             // _refreshController.requestRefresh();
    //             _esRefreshController.resetLoadState();
    //             _esRefreshController.callRefresh();
    //           },
    //         )));
  }

  void updateHeader(bool next) {}

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

    return Stack(
      children: <Widget>[
        NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => _sliverBuilder(context, innerBoxIsScrolled),
          body: Listener(
              onPointerDown: (_) {
                // if (_replyContainerHeight == 0) {
                hideReplyContainer();
                startY = _.position.dy;
                // }
              },
              onPointerUp: (_) {
                if (widget.pullDownCallBack != null) {
                  widget.pullDownCallBack((_.position.dy - startY) > 0);
                }
              },
              child: Scrollbar(
                controller: _scrollController,
                child: SmartRefresher(
                  enablePullUp: true,
                  enablePullDown: true,
                  scrollController: _scrollController,
                  controller: _refreshController,
                  header: WaterDropHeader(
                    waterDropColor: Colors.lightBlue,
                    complete: const Text('刷新完成'),
                  ),
                  footer: ClassicFooter(
                    loadingText: '正在加载...',
                    canLoadingText: '释放以加载更多',
                    noDataText: '到底了哦',
                  ),
                  // footer: Wat,
                  child: CustomScrollView(
                    primary: false,
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: Recommendation(
                          callback: (a, b, c, d) {
                            showReplyContainer(a, b, c);
                            sendCallback = d;
                          },
                          refreshController: _refreshController,
                        ),
                      )
                    ],
                  ),
                  onRefresh: () => _onRefresh(context),
//                  onLoad: _onLoading,
                  onLoading: _onLoading,
                ),
              )),
        ),
        // StatelessWdigetWrapper(Text('data')),
        Positioned(
            left: 0,
            bottom: 0,
            child: HomeCommentWrapper(
              key: commentWrapperKey,
              sendCallback: (reply) => sendCallback(reply),
            )),
      ],
    );
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        centerTitle: true,
        backgroundColor: isDark ? Colours.dark_bg_color : Colours.bg_color,
        //标题居中

        title: GestureDetector(
          child: Text(
            Application.getOrgName ?? TextConstant.TEXT_UN_CATCH_ERROR,
            style: TextStyle(fontSize: Dimens.font_sp15),
          ),
          onDoubleTap: () {
            _scrollController.animateTo(.0,
                duration: Duration(milliseconds: 2000), curve: Curves.fastLinearToSlowEaseIn);
          },
        ),
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
        // flexibleSpace: FlexibleSpaceBar(
        //     background: CachedNetworkImage(
        //   imageUrl:
        //       'https://cdn.pixabay.com/photo/2018/09/05/04/21/flowers-3655451__480.jpg',
        //   fit: BoxFit.cover,
        // )),
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
