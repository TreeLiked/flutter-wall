import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:iap_app/api/circle.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/sticky_row_delegate.dart';
import 'package:iap_app/component/circle/circle_simple_item.dart';
import 'package:iap_app/component/circle/circle_swpier_banner.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/oss_canstant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/model/circle/circle.dart';
import 'package:iap_app/model/circle_query_param.dart';
import 'package:iap_app/part/circle/circle_main.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/circle_router.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/umeng_util.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CircleMainNew extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CircleMainNewState();
  }
}

class _CircleMainNewState extends State<CircleMainNew>
    with AutomaticKeepAliveClientMixin<CircleMainNew>, SingleTickerProviderStateMixin {
  static const String _TAG = "_CircleMainNewState";

  RefreshController _refreshController = RefreshController(initialRefresh: true);

  // 用来控制titleText的更换
  ScrollController _scrollController = ScrollController();

  // 主标题展示"精彩"/"推荐"
  bool showRecommendTitleText = false;

  // 连接通知器
  LinkHeaderNotifier _headerNotifier;

  int _currentPage = 1;

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

  final String defaultCover = PathConstant.HOT_COVER_URL + OssConstant.THUMBNAIL_SUFFIX;

  bool isDark = false;

  int _currentSelectIndex = 0;

  List<Circle> _circles;

  @override
  void initState() {
    super.initState();
    // _futureTask = getData();
    UMengUtil.userGoPage(UMengUtil.PAGE_CIRCLE_INDEX);
    _headerNotifier = LinkHeaderNotifier();
    _scrollController.addListener(_scrollListener);
  }

  _scrollListener() {
    if (showRecommend != showRecommendTitleText) {
      setState(() {
        showRecommendTitleText = showRecommend;
      });
    }
  }

  bool get showRecommend {
    return _scrollController.hasClients && _scrollController.offset > (200 - kToolbarHeight);
  }

  @override
  void dispose() {
    _headerNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    isDark = ThemeUtils.isDark(context);

    return SafeArea(
        bottom: false,
        child: Scaffold(
            body: NestedScrollView(
                controller: _scrollController,
                floatHeaderSlivers: true,
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      elevation: 0.0,
                      pinned: true,
                      floating: false,
                      snap: false,
                      primary: true,
                      title: showRecommendTitleText
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('更多',
                                    style: pfStyle.copyWith(fontSize: Dimens.font_sp17, letterSpacing: 1.5)),
                                Gaps.hGap5,
                                _goCircleAllWidget(),
                              ],
                            )
                          : Text('推荐',
                              style: pfStyle.copyWith(fontSize: Dimens.font_sp17, letterSpacing: 1.5)),
                      centerTitle: false,
                      actions: [
                        _getActionItem(
                            "circle/circle_create",
                            () => NavigatorUtils.push(context, CircleRouter.CREATE,
                                transitionType: TransitionType.fadeIn)),
                        // _getActionItem("circle/circle_noti", () => {}),
                        _getActionItem("circle/circle_me", () => {}),
                      ],
                    ),

                    // SliverPersistentHeader(
                    //   pinned: true,
                    //   delegate: StickyTabBarDelegate(
                    //     child: TabBar(
                    //       labelColor: Colors.black,
                    //       controller: this._tabController,
                    //       tabs: <Widget>[
                    //         Tab(text: '资讯'),
                    //         Tab(text: '技术'),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    SliverPadding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        sliver: SliverPersistentHeader(
                          delegate: StickySwiperDelegate(children: _circles),
                        )),
                    SliverPadding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        sliver: SliverPersistentHeader(
                          delegate: StickyRowDelegate(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '更多',
                                  style: pfStyle.copyWith(fontSize: Dimens.font_sp17, letterSpacing: 1.5),
                                ),
                                _goCircleAllWidget()
                              ],
                              height: 20.0,
                              padding: const EdgeInsets.only(left: 15.0, right: 15.0)),
                        )),
                  ];
                },
                body: SmartRefresher(
                  header: ClassicHeader(
                    releaseText: '换一批',
                    refreshingText: '更新中',
                    idleText: '继续下滑',
                    completeText: '更新完成',
                    failedText: '更新完成',
                  ),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  child: CollectionUtil.isListEmpty(_circles)
                      ? Gaps.empty
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _circles.length,
                          itemBuilder: (ctx, index) {
                            return CircleSimpleItem(_circles[index]);
                          }),
                ))));
  }

  Widget _goCircleAllWidget() {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CircleTabMain()),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '查看全部',
              style: pfStyle.copyWith(fontSize: Dimens.font_sp14, color: Colors.grey),
            ),
            Icon(
              Icons.keyboard_arrow_right_outlined,
              size: 16,
              color: Colors.grey,
            )
          ],
        ));
  }

  Widget _getActionItem(String iconPath, Function ontap) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.only(left: 7.0, top: 10.0, bottom: 10.0, right: 5.0),
        decoration: BoxDecoration(
            color: !isDark ? ColorConstant.TWEET_RICH_BG : ColorConstant.TWEET_RICH_BG_DARK, borderRadius: BorderRadius.circular(10.0)),
        child: GestureDetector(
            onTap: ontap,
            child: LoadAssetIcon(iconPath,
                width: 16.0, height: 16.0, color: isDark ? Colors.grey : Colors.black87)));
  }

  Future getData(int page) async {
    List<Circle> pbt =
        await (CircleApi.queryCircles(CircleQueryParam(page, pageSize: 10, orgId: Application.getOrgId)));
    return pbt;
  }

  @override
  bool get wantKeepAlive => true;
}

class StickySwiperDelegate extends SliverPersistentHeaderDelegate {
  List<Circle> children;

  StickySwiperDelegate({@required this.children});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    if (children == null || children.isEmpty) {
      return Gaps.empty;
    }
    int recommendSize = new CircleQueryParam(1).recommendSize;
    if(children.length > recommendSize) {
      children = children.sublist(0, recommendSize);
    }
    return Container(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
        child: Swiper(
          itemCount: children.length,
          itemBuilder: (context, index) {
            return Container(child: CircleSwiperBanner(children[index]));
          },
          autoplay: true,
          autoplayDelay: 5000,
          duration: 1000,
          pagination: new SwiperPagination(
              alignment: Alignment.bottomRight,
              builder: RectSwiperPaginationBuilder(
                color: Colors.black54,
                activeColor: Colors.white,
                size: Size(10, 1),
                activeSize: Size(10, 2),
              )),
        ));
  }

  @override
  double get maxExtent => CollectionUtil.isListEmpty(children) ? 0 : 130;

  @override
  double get minExtent => CollectionUtil.isListEmpty(children) ? 0 : 120;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
