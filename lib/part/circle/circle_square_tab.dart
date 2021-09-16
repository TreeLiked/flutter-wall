import 'dart:async';
import 'dart:math';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/circle.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/component/circle/circle_simple_item.dart';
import 'package:iap_app/model/circle/circle.dart';
import 'package:iap_app/model/circle_query_param.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/page/tweet_detail.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/umeng_util.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CircleSquareTabView extends StatefulWidget {
  /// 圈子分类ID
  final int circleCategoryId;

  /// 下拉刷新的颜色
  final Color refreshWidgetColor;

  CircleSquareTabView(this.circleCategoryId, {this.refreshWidgetColor = Colors.blue});

  @override
  State<StatefulWidget> createState() {
    return _CircleSquareTabView();
  }
}

class _CircleSquareTabView extends State<CircleSquareTabView>
    with AutomaticKeepAliveClientMixin<CircleSquareTabView> {
  final String _TAG = "CircleSquareTabView";

  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  int _currentPage = 1;
  List<Circle> _circles = List();

  // 连接通知器
  LinkHeaderNotifier _headerNotifier;

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
    print("---------refreshiing..........");
  }

  Future<void> _onLoading() async {
    print("---------refreshiing..........");
    setState(() {
      _initData();
    });
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    // _futureTask = getData();
    _initData();
    UMengUtil.userGoPage(UMengUtil.PAGE_TWEET_INDEX_HOT);
    _headerNotifier = LinkHeaderNotifier();
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
                  // : StaggeredGridView.countBuilder(
                  //     controller: _scrollController,
                  //     crossAxisCount: 4,
                  //     itemCount: _circles.length,
                  //     itemBuilder: (BuildContext context, int index) => CircleSimpleItem(_circles[index]),
                  //     // staggeredTileBuilder: (int index) =>
                  //     //     new StaggeredTile.count(5, _circles[index].higher ? 6 : 5),
                  //     staggeredTileBuilder: (index) => new StaggeredTile.fit(2),
                  //     mainAxisSpacing: 15.0,
                  //     crossAxisSpacing: 10.0,
                  //   ),
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

    // return Scaffold(
    //   body: EasyRefresh.custom(
    //       header: esr.LinkHeader(
    //         _headerNotifier,
    //         extent: 70.0,
    //         triggerDistance: 70.0,
    //         // completeDuration: Duration(milliseconds: 5000),
    //         enableHapticFeedback: true,
    //       ),
    //       firstRefresh: true,
    //       slivers: <Widget>[
    //         SliverFillRemaining(
    //             child: StaggeredGridView.countBuilder(
    //               crossAxisCount: 4,
    //               itemCount: 16,
    //               itemBuilder: (BuildContext context, int index) => new Container(
    //                   color: Colors.green,
    //                   child: new Center(
    //                     child: new CircleAvatar(
    //                       backgroundColor: Colors.white,
    //                       child: new Text('$index'),
    //                     ),
    //                   )),
    //               staggeredTileBuilder: (int index) => new StaggeredTile.count(3, index.isEven ? 2 : 1),
    //               mainAxisSpacing: 4.0,
    //               crossAxisSpacing: 4.0,
    //             )),
    //         // Gaps.vGap5
    //       ],
    //       onRefresh: _onRefresh,
    //       onLoad: null)
    // );
  }

  _noDataView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Gaps.vGap50,
        SizedBox(
            // width: ScreenUtil().setWidth(600),
            height: ScreenUtil().setHeight(500),
            child: LoadAssetImage(
              ThemeUtils.isDark(context) ? 'no_data_dark' : 'no_data',
              fit: BoxFit.cover,
            )),
        Gaps.vGap16,
        Text('快去创建一个圈子吧 ～',
            style: pfStyle.copyWith(color: Colors.grey, fontSize: Dimens.font_sp16, letterSpacing: 1.3)),
      ],
    );
  }

  _forwardDetail(int tweetId, int rank) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TweetDetail(null, tweetId: tweetId, hotRank: rank, newLink: true)),
    );
  }

  Future getData(int page) async {
    List<Circle> pbt = await (CircleApi.queryCircles(CircleQueryParam(
      page,
      pageSize: 10,
      orgId: Application.getOrgId,
    )));
    return pbt;
  }

  @override
  bool get wantKeepAlive => true;
}
