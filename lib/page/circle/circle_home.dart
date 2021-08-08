import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:iap_app/api/circle.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/dialog/ab_dialog.dart';
import 'package:iap_app/common-widget/empty_view.dart';
import 'package:iap_app/common-widget/popup_window.dart';
import 'package:iap_app/common-widget/sticky_empty_delegate.dart';
import 'package:iap_app/common-widget/sticky_row_delegate.dart';
import 'package:iap_app/component/circle/circle_card.dart';
import 'package:iap_app/component/circle/circle_tweet_card.dart';
import 'package:iap_app/component/custom_header.dart';
import 'package:iap_app/component/flexible_detail_bar.dart';
import 'package:iap_app/component/satck_img_conatiner.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/model/account/circle_account.dart';
import 'package:iap_app/model/circle/circle.dart';
import 'package:iap_app/model/circle/circle_tweet.dart';
import 'package:iap_app/model/gender.dart';
import 'package:iap_app/model/media.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/page/circle/circle_detail.dart';
import 'package:iap_app/page/common/report_page.dart';
import 'package:iap_app/provider/circle_tweet_provider.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/circle_router.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/number_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/umeng_util.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:provider/provider.dart';

class CircleHome extends StatefulWidget {
  final Circle _circle;
  final int circleId;

  CircleHome(this._circle, {this.circleId});

  @override
  State<StatefulWidget> createState() {
    print("$circleId-----------------, ${_circle.toJson()}");
    return _CircleHomeState(this._circle, circleId: circleId);
  }
}

class _CircleHomeState extends State<CircleHome> {
  EasyRefreshController _refreshController = EasyRefreshController();
  ScrollController _scrollController = ScrollController();
  LinkHeaderNotifier _linkHeaderNotifier;

  Circle _circle;
  final int circleId;

  // 两个排序
  List _sortTypeList = ["最新内容", "热门排序"];

  // 默认时间排序
  int _sortTypeIndex = 0;

  // 按钮key
  GlobalKey _sortButtonKey = GlobalKey();

  BuildContext _context;
  bool isDark = false;

  // 是否显示滚动到顶部组件
  bool displayGoTopWidget = false;

  // 是否当前用户加入了该圈子
  bool _meJoined;

  _CircleHomeState(this._circle, {this.circleId});

  int _currentPage = 1;
  int _pageSize = 10;
  CircleTweetProvider tweetProvider;

  @override
  void initState() {
    super.initState();
    _linkHeaderNotifier = LinkHeaderNotifier();
    _scrollController.addListener(_scrollListener);
    queryDetail();
  }

  _scrollListener() {
    if (showGoTop != displayGoTopWidget) {
      setState(() {
        displayGoTopWidget = showGoTop;
      });
    }
  }

  bool get showGoTop {
    return _scrollController.hasClients && _scrollController.offset > 230;
  }

  @override
  void dispose() {
    _linkHeaderNotifier ?? dispose();
    _refreshController ?? dispose();
    _scrollController ?? dispose();
    _sortButtonKey.currentState ?? dispose();
    tweetProvider.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    this._context = context;
    isDark = ThemeUtils.isDark(context);
    tweetProvider = Provider.of<CircleTweetProvider>(_context, listen: false);

    return Consumer<CircleTweetProvider>(builder: (context, provider, _) {
      var _tweets = provider.displayTweets;
      return Stack(
        children: [
          NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    centerTitle: true,
                    title: MyCustomHeader(_linkHeaderNotifier),
                    expandedHeight: 230.0,
                    pinned: true,
                    elevation: 0.0,

                    leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        iconSize: 23.0,
                        onPressed: () {
                          tweetProvider?.clear();
                          NavigatorUtils.goBack(context);
                        }),
                    actions: [
                      _getActionItem('circle/circle_detail', () => _displayDetail()),
                      _getActionItem('circle/circle_more', () => _displayMoreActs()),
                    ],
                    flexibleSpace: Container(
                      color: ThemeUtils.isDark(context) ? ColorConstant.MAIN_BG_DARK : ColorConstant.MAIN_BG,
                      child: ClipRRect(
                        child: FlexibleDetailBar(
                          content: Container(
                              height: 100,
                              margin: const EdgeInsets.only(
                                  top: kToolbarHeight, left: 20.0, right: 20.0, bottom: 30.0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _circle == null
                                        ? Center(
                                            child: Text('正在加载...'),
                                          )
                                        : Row(children: [
                                            ClipRRect(
                                              child: CachedNetworkImage(
                                                imageUrl: _circle.cover,
                                                fit: BoxFit.cover,
                                                width: 120,
                                                height: 120,
                                              ),
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                            Gaps.hGap20,
                                            Expanded(
                                              child: Column(
                                                  children: [
                                                    Text('${_circle == null ? '正在加载..' : _circle.brief}',
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: pfStyle.copyWith(
                                                            fontSize: Dimens.font_sp17,
                                                            color: Colors.white,
                                                            letterSpacing: 1.1)),
                                                    Gaps.vGap10,
                                                    RichText(
                                                        maxLines: 1,
                                                        softWrap: true,
                                                        overflow: TextOverflow.ellipsis,
                                                        text: TextSpan(children: [
                                                          WidgetSpan(
                                                              child: (_circle != null &&
                                                                      _circle.creator != null &&
                                                                      _circle.creator.avatarUrl != null)
                                                                  ? AccountAvatar(
                                                                      cache: true,
                                                                      avatarUrl: _circle.creator.avatarUrl,
                                                                      size: 23)
                                                                  : Gaps.empty),
                                                          TextSpan(
                                                              text: " ${_circle == null ? '' : _circle.desc}",
                                                              style: pfStyle.copyWith(
                                                                  fontSize: Dimens.font_sp14,
                                                                  color: Colors.white70),
                                                              recognizer: TapGestureRecognizer()
                                                                ..onTap = () => _displayDetail()),
                                                        ])),
                                                    Gaps.vGap10,
                                                    Text(
                                                        '浏览${NumberUtil.calCount(_circle.view)}次，${NumberUtil.calCount(_circle.participants)}人已加入',
                                                        style: pfStyle.copyWith(
                                                            fontSize: Dimens.font_sp13,
                                                            color: Colors.white70)),
                                                    Gaps.vGap10,
                                                    Container(
                                                        child: _meJoined == null
                                                            ? Gaps.empty
                                                            : Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Container(
                                                                      padding: const EdgeInsets.symmetric(
                                                                          horizontal: 10.0, vertical: 4.0),
                                                                      decoration: BoxDecoration(
                                                                        color: _meJoined
                                                                            ? Colors.green.withAlpha(180)
                                                                            : Colors.white24,
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      child: _meJoined
                                                                          ? _getCreateContentItem()
                                                                          : _getApplyJoinItem()),
                                                                ],
                                                              ))
                                                  ],
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.max),
                                            )
                                          ]),
                                  ])),
                          background: _circle == null
                              ? Gaps.empty
                              : Stack(
                                  children: <Widget>[
                                    Utils.showFadeInImage(_circle.cover, BorderRadius.circular(0.0),
                                        cache: true),
                                    BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaY: 5,
                                        sigmaX: 5,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                            gradient: new LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: isDark
                                                    ? [Colors.black26, Colors.black45]
                                                    : [Colors.black12, Colors.black38])),
                                      ),
                                    )
                                  ],
                                ),
                        ),
                      ),
                    ),
                    // flexibleSpace: StackImageContainer(
                    //   _circle.cover,
                    //   height: 230,
                    //   hasShadow: true,
                    //   centerWidget: Text('kskk'),
                    //   // width: double.infinity,
                    // ),

                    // flexibleSpace: FlexibleSpaceBar(
                    //   title: Text(_circle.brief),
                    //   background: Image.network(
                    //     _circle.cover,
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),

                    // bottom: PreferredSize(
                    //   preferredSize: Size.fromHeight(100),
                    //   child: Text("1223"),
                    // ),
                  ),
                ];
              },
              body: _circle == null
                  ? Gaps.empty
                  : MediaQuery.removePadding(
                      removeTop: true,
                      context: context,
                      child: Material(
                          color: isDark ? ColorConstant.MAIN_BG_DARK : Colors.white,
                          child: EasyRefresh.custom(
                              controller: _refreshController,
                              header: LinkHeader(
                                _linkHeaderNotifier,
                                extent: 50.0,
                                triggerDistance: 50.0,
                                // completeDuration: Duration(milliseconds: 5000),
                                enableHapticFeedback: true,
                              ),
                              footer: ClassicalFooter(
                                loadedText: '加载完成',
                                noMoreText: '没有更多了',
                                loadReadyText: '释放以加载',
                                loadFailedText: '加载失败',
                                loadingText: '正在加载更多',
                                showInfo: true,
                                infoColor: Colors.grey,
                                textColor: Colors.grey,
                                safeArea: true,
                                infoText: '更新于 ' + TimeUtil.getShortTime(DateTime.now()),
                              ),
                              firstRefresh: false,
                              slivers: <Widget>[
                                SliverPersistentHeader(
                                    delegate: CollectionUtil.isListNotEmpty(_tweets)
                                        ? StickyRowDelegate(
                                            padding: const EdgeInsets.only(left: 15.0),
                                            bgColor: ThemeUtils.getBackgroundColor(_context),
                                            children: [
                                              GestureDetector(
                                                  key: _sortButtonKey,
                                                  onTap: () => _showSortTypeSel(),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Text('${_sortTypeList[_sortTypeIndex]}',
                                                            style: pfStyle.copyWith(
                                                                fontSize: Dimens.font_sp15,
                                                                fontWeight: FontWeight.w500)),
                                                      ),
                                                      Gaps.hGap4,
                                                      LoadAssetSvg("sort_arrow_down",
                                                          width: 17,
                                                          height: 17,
                                                          color: ThemeUtils.getIconColor(_context)),
                                                    ],
                                                  ))
                                            ],
                                            height: 45,
                                            crossAxisAlignment: CrossAxisAlignment.center)
                                        : StickyEmptyDelegate()),
                                !_circle.contentPrivate || (_meJoined != null && _meJoined)
                                    ? CollectionUtil.isListNotEmpty(_tweets)
                                        ? (_tweets == null
                                            ? WidgetUtil.getLoadingGif()
                                            : SliverPadding(
                                                padding: const EdgeInsets.only(bottom: 10.0, top: 0.0),
                                                sliver: SliverList(
                                                  delegate: new SliverChildBuilderDelegate(
                                                      (BuildContext context, int index) {
                                                    return CircleTweetCard(_tweets[index]);
                                                  }, childCount: _tweets.length),
                                                )))
                                        : SliverFillRemaining(
                                            child: Container(
                                                child: EmptyView(
                                                    lightImg: "no_data_green",
                                                    text: '圈子暂无内容哦 ～',
                                                    topMargin: 50)),
                                          )
                                    : SliverFillRemaining(
                                        child: Container(
                                            child: EmptyView(
                                                lightImg: "no_data_green",
                                                text: '管理员设置了仅圈内用户可访问哦 ～',
                                                topMargin: 50)),
                                      ),
                                // Gaps.vGap5
                              ],
                              onRefresh: () => _onRefresh(context),
                              onLoad: _onLoading)),
                    )),
          displayGoTopWidget
              ? Positioned(
                  child: GestureDetector(
                    onTap: () => _scrollController.animateTo(0,
                        duration: Duration(milliseconds: 3000), curve: Curves.fastLinearToSlowEaseIn),
                    child: Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: isDark ? Colors.black : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.lightGreen : Colors.lightGreenAccent,
                              blurRadius: 5.0,
                            ),
                          ]),
                      child: LoadAssetSvg(
                        'circle_go_top',
                        width: double.infinity,
                        height: double.infinity,
                        color: isDark ? Colors.lightGreen : Colors.lightGreen,
                      ),
                    ),
                  ),
                  // right: (Application.screenWidth - 50) / 2,
                  right: 60,
                  bottom: 60,
                )
              : Gaps.empty
        ],
      );
    });
  }

  Future<void> _onRefresh(BuildContext context) async {
    _currentPage = 1;
    List<CircleTweet> temp = await getData(_currentPage);
    tweetProvider.update(temp, clear: true, append: false);
    _refreshController.finishRefresh();
  }

  Widget _getActionItem(String iconPath, Function ontap) {
    return Container(
      padding: const EdgeInsets.all(3.0),
      margin: const EdgeInsets.only(right: 15.0),
      child: GestureDetector(
        onTap: ontap,
        child: LoadAssetIcon(iconPath, width: 20.0, height: 20.0, color: Colors.white),
      ),
    );
  }

  Widget _getApplyJoinItem() {
    return InkWell(
      onTap: () {
        if (this._meJoined) {
          return;
        }
        Utils.showDefaultLoadingWithBounds(context, text: '正在处理');
        CircleApi.applyJoinCircle(_circle.id).then((res) {
          Utils.closeLoading(context);
          if (res.isSuccess) {
            if (StringUtil.notEmpty(res.message)) {
              ToastUtil.showToast(context, res.message);
            }
          } else {
            if (res.code == "201") {
              // 201表示被管理员拒绝，是否需要重新申请
              setState(() {
                this._meJoined = res.data;
              });
              _displayReApplyDialog();
              return;
            } else {
              ToastUtil.showToast(context, res.message);
            }
          }
          setState(() {
            this._meJoined = res.data;
          });
        });
      },
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                size: 14,
                color: Colors.white,
              ),
              Gaps.hGap5,
              Text("申请加入", style: pfStyle.copyWith(fontSize: Dimens.font_sp14, color: Colors.white)),
            ],
          )),
    );
  }

  Widget _getCreateContentItem() {
    return InkWell(
        onTap: () => NavigatorUtils.push(
            context,
            Routes.create +
                Routes.assembleArgs({
                  "type": 1,
                  "title": "发布内容",
                  "hintText": "分享到圈子",
                  "circleId": (circleId ?? _circle.id).toString()
                }),
            transitionType: TransitionType.fadeIn),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                Icons.create,
                size: 14,
                color: Colors.white,
              ),
              Gaps.hGap5,
              Text("发布内容", style: pfStyle.copyWith(fontSize: Dimens.font_sp14, color: Colors.white))
            ])));
  }

  void _showSortTypeSel() {
    // 获取点击控件的坐标
    final RenderBox button = _sortButtonKey.currentContext.findRenderObject();
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    // 获得控件左下方的坐标
    var a = button.localToGlobal(Offset(0.0, button.size.height), ancestor: overlay);
    // 获得控件右下方的坐标
    var b = button.localToGlobal(button.size.bottomRight(Offset(0, 0)), ancestor: overlay);
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(a, b),
      Offset.zero & overlay.size,
    );
    showPopupWindow(
      context: context,
      fullWidth: true,
      position: position,
      elevation: 0.0,
      child: GestureDetector(
        onTap: () => NavigatorUtils.goBack(context),
        child: Container(
          color: const Color(0x99000000),
          height: Application.screenHeight - b.dy,
          child: ListView.builder(
            physics: ClampingScrollPhysics(),
            itemCount: _sortTypeList.length,
            itemBuilder: (_, index) {
              Color backgroundColor = ThemeUtils.getBackgroundColor(context);
              bool selected = index == _sortTypeIndex;
              return Material(
                color: backgroundColor,
                child: InkWell(
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 15.0, top: 20.0, bottom: index == _sortTypeList.length - 1 ? 15 : 0),
                    child: Text(
                      _sortTypeList[index],
                      style: pfStyle.copyWith(
                          fontSize: Dimens.font_sp15,
                          color: selected ? ColorConstant.getTweetNickColor(context) : null),
                    ),
                  ),
                  onTap: () {
                    NavigatorUtils.goBack(context);
                    setState(() {
                      _sortTypeIndex = index;
                      _refreshController.callRefresh();
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void queryDetail() {
    CircleApi.queryCircleDetail(getCircleId()).then((resCircle) {
      if (resCircle != null) {
        setState(() {
          this._circle = resCircle;
          this._meJoined = _circle.meJoined;
        });
      }
      _refreshController.callRefresh();
    });
  }

  void _displayDetail() {
    BottomSheetUtil.showBottomSheet(context, 0.6, CircleDetailPage(_circle.id, circle: _circle),
        topLine: false);
    UMengUtil.userGoPage(UMengUtil.PAGE_CIRCLE_DETAIL);
  }

  void _displayMoreActs() {
    List<BottomSheetItem> items = List();
    items.add(BottomSheetItem(
        Icon(
          Icons.warning,
          color: Colors.grey,
        ),
        '举报', () {
      Navigator.pop(context);
      NavigatorUtils.goReportPage(context, ReportPage.REPORT_CIRCLE, _circle.id.toString(), "圈子举报");
    }));

    if (_meJoined != null && _meJoined == true) {
      items.add(BottomSheetItem(
          Icon(
            Icons.exit_to_app,
            color: Colors.red,
          ),
          '退出圈子', () {
        Navigator.pop(context);
        NavigatorUtils.goReportPage(context, ReportPage.REPORT_CIRCLE, _circle.id.toString(), "圈子举报");
      }));
    }

    BottomSheetUtil.showBottomSheetView(context, items);
  }

  _displayReApplyDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AbDialog(
              leftText: '取消',
              rightText: '重新申请',
              title: '申请结果',
              content: '您的圈子加入申请被管理员拒绝了，是否需要重新申请',
              barryOnDismiss: false,
              onTapRight: () {
                CircleApi.applyJoinCircle(_circle.id, reApply: true).then((res) {
                  if (res.isSuccess) {
                    if (StringUtil.notEmpty(res.message)) {
                      ToastUtil.showToast(context, res.message);
                    }
                  } else {
                    ToastUtil.showToast(context, res.message);
                  }
                  setState(() {
                    this._meJoined = res.data;
                  });
                  NavigatorUtils.goBack(context);
                });
              });
        });
  }

  Future<void> _onLoading() async {
    List<CircleTweet> temp = await getData(++_currentPage);
    tweetProvider.update(temp, append: true, clear: false);
    if (CollectionUtil.isListEmpty(temp)) {
      _currentPage--;
      _refreshController.finishLoad(success: true, noMore: true);
    } else {
      _refreshController.finishLoad(success: true, noMore: false);
    }
  }

  Future getData(int page) async {
    if (_circle.contentPrivate) {
      if (_meJoined == null || !_meJoined) {
        return Future.delayed(Duration(milliseconds: 100)).then((value) => getData(page));
      }
    }
    return await CircleApi.queryTweets(
        _sortTypeIndex, getCircleId(), PageParam(_currentPage, pageSize: _pageSize));
  }

  int getCircleId() {
    return circleId ?? _circle.id;
  }
}
