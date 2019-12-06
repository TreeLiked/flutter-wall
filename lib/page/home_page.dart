import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/bezier_circle_header.dart' as prefix0;
import 'package:flutter_easyrefresh/delivery_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_easyrefresh/bezier_circle_header.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/popup_window.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/models/tabIconData.dart';
import 'package:iap_app/page/tweet_type_sel.dart';
import 'package:iap_app/part/recom.dart';
import 'package:iap_app/part/space_header.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/res/resources.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  final pullDownCallBack;
  HomePage({this.pullDownCallBack});
  @override
  State<StatefulWidget> createState() {
    return new _HomePageState();
  }
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  EasyRefreshController _esRefreshController = EasyRefreshController();

  List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  AnimationController animationController;

  final recomKey = GlobalKey<RecommendationState>();

  int _currentPage = 1;

  // 回复相关
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();
  String _hintText = "说点什么吧";
  TweetReply curReply;
  String destAccountId;
  double _replyContainerHeight = 0;
  // 是否开启匿名评论
  bool showAnonymous = false;

  List<String> tweetQueryTypes = List();

  Function sendCallback;

  AccountLocalProvider accountLocalProvider;
  TweetTypesFilterProvider typesFilterProvider;

  bool firstBuild = true;

  double startY = -1;
  double lastY = -1;

  GlobalKey _menuKey = GlobalKey();

  DateTime _lastRefresh;

  @override
  void initState() {
    tabIconsList.forEach((tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;
    super.initState();
  }

  Widget tabBody = Container(
    color: Color(0xFFF2F3F8),
  );

  Future<void> _onRefresh(BuildContext context) async {
    print('On refresh');

    _esRefreshController.resetLoadState();
    _currentPage = 1;
    List<BaseTweet> temp = await getData(_currentPage);
    if (!CollectionUtil.isListEmpty(temp)) {
      recomKey.currentState.updateTweetList(temp, add: false);
      _esRefreshController.finishRefresh(success: true, noMore: false);
      _refreshController.refreshCompleted();
    } else {
      recomKey.currentState.updateTweetList(null, add: true);
      _esRefreshController.finishRefresh(success: true, noMore: true);
      _refreshController.refreshCompleted();
    }
    setState(() {
      _lastRefresh = DateTime.now();
    });
  }

  void initData() async {
    List<BaseTweet> temp = await getData(1);
    if (!CollectionUtil.isListEmpty(temp)) {
      recomKey.currentState.updateTweetList(temp, add: false);
    }
  }

  Future<void> _onLoading() async {
    // monitor network fetch

    print('loading more data');
    List<BaseTweet> temp = await getData(++_currentPage);
    if (CollectionUtil.isListEmpty(temp)) {
      print('没有数据了');
      _currentPage--;
      _esRefreshController.finishLoad(success: true, noMore: true);
      _refreshController.loadNoData();
    } else {
      recomKey.currentState.updateTweetList(temp, add: true, start: false);
      _esRefreshController.finishLoad(success: true, noMore: false);
      _refreshController.loadComplete();
    }
  }

  Future getData(int page) async {
    print('get data ---------------------$page');
    print(typesFilterProvider.selTypeNames);
    List<BaseTweet> pbt = await (TweetApi.queryTweets(
        PageParam(page,
            pageSize: 5,
            types: ((typesFilterProvider.selectAll ?? true)
                ? null
                : typesFilterProvider.selTypeNames)),
        Application.getAccountId));
    pbt.forEach((f) => print(f.toJson()));
    return pbt;
  }

  // void getStoragePreferTypes() async {
  //   List<String> selTypes = await SharedPreferenceUtil.readListStringValue(
  //       SharedConstant.LOCAL_FILTER_TYPES);
  //   if (!CollectionUtil.isListEmpty(selTypes)) {
  //     setState(() {
  //       this.tweetQueryTypes = selTypes;
  //     });
  //   }
  //   setState(() {
  //     isIniting = false;
  //   });
  // }

  void showReplyContainer(
      TweetReply tr, String destAccountNick, String destAccountId) {
    print(
        'home page 回调 =============== $destAccountNick----------------${tr.type}');
    if (StringUtil.isEmpty(destAccountNick)) {
      setState(() {
        if (tr.type == 1) {
          showAnonymous = true;
        } else {
          showAnonymous = false;
        }
        _hintText = "评论";
        curReply = tr;
        _replyContainerHeight = MediaQuery.of(context).size.width;
        this.destAccountId = destAccountId;
      });
    } else {
      setState(() {
        if (tr.type == 1) {
          showAnonymous = true;
        } else {
          showAnonymous = false;
        }
        _hintText = "回复 $destAccountNick";
        curReply = tr;
        _replyContainerHeight = MediaQuery.of(context).size.width;
        this.destAccountId = destAccountId;
      });
    }

    _focusNode.requestFocus();
  }

  void hideReplyContainer() {
    if (_replyContainerHeight != 0) {
      setState(() {
        _replyContainerHeight = 0;
        _controller.clear();
        _focusNode.unfocus();
      });
    }
  }

  void _forwardFilterPage() async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TweetTypeSelect(
                  title: "过滤内容类型",
                  multi: true,
                  backText: "编辑",
                  finishText: "完成",
                  initNames: typesFilterProvider.selTypeNames,
                  callback: (_) {
                    // _refreshController.requestRefresh();
                    _esRefreshController.resetLoadState();
                    _esRefreshController.callRefresh();
                  },
                )));
  }

  void updateHeader(bool next) {}
  @override
  Widget build(BuildContext context) {
    super.build(context);
    typesFilterProvider = Provider.of<TweetTypesFilterProvider>(context);
    accountLocalProvider = Provider.of<AccountLocalProvider>(context);
    if (firstBuild) {
      initData();
    }
    firstBuild = false;
    return Stack(
      children: <Widget>[
        NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) =>
              _sliverBuilder(context, innerBoxIsScrolled),
          body: Listener(
              onPointerDown: (_) {
                // 只有未显示回复框开启滑动检测
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
              child: EasyRefresh(
                header: ClassicalHeader(
                  enableHapticFeedback: true,
                  enableInfiniteRefresh: false,
                  refreshText: '下拉刷新',
                  refreshReadyText: '释放以刷新',
                  refreshingText: '更新中',
                  refreshedText: '更新完成',
                  refreshFailedText: '更新失败',
                  noMoreText: '没有更多了',
                  // bgColor: Theme.of(context).appBarTheme.color,
                  infoColor: null,
                  float: false,
                  showInfo: true,
                  infoText: _lastRefresh == null
                      ? "未刷新"
                      : '更新于 ' +
                          DateUtil.formatDate(_lastRefresh,
                              format: DataFormats.h_m),
                  bgColor: null,
                  textColor: Theme.of(context).textTheme.subhead.color,
                ),

                footer: ClassicalFooter(
                  loadText: '上滑加载更多',
                  loadReadyText: '释放以加载更多',
                  loadingText: '加载中',
                  loadedText: '加载完成',
                  loadFailedText: '加载失败',
                  noMoreText: '没有更多了',
                  showInfo: false,
                  textColor: Theme.of(context).textTheme.subhead.color,
                ),
                // footer: Wat,
                controller: _esRefreshController,
                child: Recommendation(
                  key: recomKey,
                  callback: (a, b, c, d) {
                    showReplyContainer(a, b, c);
                    sendCallback = d;
                  },
                ),
                onRefresh: () => _onRefresh(context),
                onLoad: _onLoading,
              )),
        ),
        Positioned(
            left: 0,
            bottom: 0,
            child: Offstage(
                offstage: false,
                child: AnimatedOpacity(
                    opacity: _replyContainerHeight != 0 ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 500),
                    child: Container(
                        width: _replyContainerHeight,
                        decoration: BoxDecoration(
                          color: ThemeUtils.isDark(context)
                              ? Color(0xff363636)
                              : Color(0xfff2f2f2),
                          // borderRadius: BorderRadius.only(
                          //   topLeft: Radius.circular(15),
                          //   topRight: Radius.circular(15),
                          // ),
                        ),
                        padding: EdgeInsets.fromLTRB(11, 7, 15, 7),
                        child: Row(
                          children: <Widget>[
                            AccountAvatar(
                              cache: true,
                              avatarUrl: accountLocalProvider.account.avatarUrl,
                              size: SizeConstant.TWEET_PROFILE_SIZE * 0.85,
                            ),
                            Expanded(
                              child: Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: TextField(
                                    controller: _controller,
                                    focusNode: _focusNode,
                                    keyboardAppearance:
                                        Theme.of(context).brightness,
                                    decoration: InputDecoration(
                                        suffixIcon: curReply != null &&
                                                curReply.type == 1
                                            ? GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    curReply.anonymous =
                                                        !curReply.anonymous;
                                                    if (curReply.anonymous) {
                                                      ToastUtil.showToast(
                                                          context, '此条评论将匿名回复');
                                                    }
                                                  });
                                                },
                                                child: Icon(
                                                  curReply.anonymous
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  size: SizeConstant
                                                          .TWEET_PROFILE_SIZE *
                                                      0.5,
                                                  color: curReply.anonymous
                                                      ? Colors.blueAccent
                                                      : Colors.grey,
                                                ),
                                              )
                                            : null,
                                        hintText: _hintText,
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                          color: ColorConstant.TWEET_TIME_COLOR,
                                          fontSize:
                                              SizeConstant.TWEET_TIME_SIZE - 1,
                                        )),
                                    textInputAction: TextInputAction.send,
                                    cursorColor: Colors.grey,
                                    style: TextStyle(
                                      fontSize:
                                          SizeConstant.TWEET_FONT_SIZE - 1,
                                    ),
                                    onSubmitted: (value) {
                                      _sendReply(value);
                                    },
                                  )),
                            ),
                          ],
                        ))))),
      ],
    );
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        centerTitle: true, //标题居中
        title: Text(
          Application.getOrgName ?? "未知错误",
        ),
        elevation: 0.4,
        actions: <Widget>[
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

  _sendReply(String value) async {
    if (StringUtil.isEmpty(value) || value.trim().length == 0) {
      ToastUtil.showToast(context, '回复内容不能为空');
      return;
    }
    Utils.showDefaultLoading(context);
    curReply.body = value;
    Account acc = Account.fromId(accountLocalProvider.accountId);
    curReply.account = acc;
    await TweetApi.pushReply(curReply, curReply.tweetId).then((result) {
      print(result.data);
      if (result.isSuccess) {
        TweetReply newReply = TweetReply.fromJson(result.data);
        _controller.clear();
        hideReplyContainer();
        sendCallback(newReply);
      } else {
        _controller.clear();
        _hintText = "评论";
        sendCallback(null);
      }
      NavigatorUtils.goBack(context);
      // widget.callback(tr, destAccountId);
    });
  }

  _showAddMenu() {
    final RenderBox button = _menuKey.currentContext.findRenderObject();
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    var a = button.localToGlobal(
        Offset(button.size.width - 8.0, button.size.height - 12.0),
        ancestor: overlay);
    var b = button.localToGlobal(button.size.bottomLeft(Offset(0, -12.0)),
        ancestor: overlay);
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
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0)),
                  ),
                  icon: LoadAssetIcon(
                    "filter",
                    width: 16.0,
                    height: 16.0,
                    color: _iconColor,
                  ),
                  label: const Text("筛 选")),
            ),
            Container(
              width: 120.0,
              height: 0.6,
              color: Colours.line,
              padding: EdgeInsets.symmetric(horizontal: 0),
            ),
            SizedBox(
              width: 120.0,
              height: 40.0,
              child: FlatButton.icon(
                  textColor: Theme.of(context).textTheme.body1.color,
                  onPressed: () {
                    NavigatorUtils.goBack(context);
                    NavigatorUtils.push(context, Routes.create,
                        transitionType: TransitionType.fadeIn);
                  },
                  color: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0)),
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
