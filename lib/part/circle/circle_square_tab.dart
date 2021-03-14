import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iap_app/component/circle/circle_card.dart';
import 'package:iap_app/component/circle/circle_simple_item.dart';
import 'package:iap_app/component/tweet/tweet_no_data_view.dart';
import 'package:iap_app/model/circle/circle.dart';
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
  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  List<Circle> _circles = List();

  // 连接通知器
  LinkHeaderNotifier _headerNotifier;

  bool isDark = false;

  void _initData() {
    String cover = "https://tva1.sinaimg.cn/large/008eGmZEgy1go2fiz9279j30u01sxapv.jpg";
    Circle c = new Circle();
    c.brief = "永远在干饭的路上";
    c.desc = "加入我们";
    c.cover = cover;
    c.view = 2000;
    c.participants = 780;
    c.higher = Random().nextInt(2) == 1;

    Circle c1 = new Circle();
    c1.brief = "永远在干饭的路上";
    c1.desc = "检查背景";
    c1.cover = "https://tva1.sinaimg.cn/large/008eGmZEgy1go11zesr83j30go0fmq6w.jpg";
    c1.view = 2000;
    c1.participants = 780;
    c1.higher = Random().nextInt(2) == 1;

    Circle c2 = new Circle();
    c2.brief = "北一食堂交流";
    c2.desc = "来啊吃饭啊";
    c2.cover = "https://tva1.sinaimg.cn/large/008eGmZEgy1gob9762hfjj30pr0n5wk5.jpg";
    c2.view = 2000;
    c2.participants = 780;
    c2.higher = Random().nextInt(2) == 1;

    Circle c3 = new Circle();
    c3.brief = "吃货小组";
    c3.desc = "哈哈哈哈😄";
    c3.cover = "https://tva1.sinaimg.cn/large/008eGmZEgy1go2ffn1e4nj30u01sxqmp.jpg";
    c3.view = 2000;
    c3.participants = 780;
    c3.higher = Random().nextInt(2) == 1;

    Circle c4 = new Circle();
    c4.brief = "永远在干饭的路上";
    c4.desc = "加入我们一起来干饭～～～";
    c4.cover = "https://tva1.sinaimg.cn/large/008eGmZEgy1go1yns7qstj30lr0ez40j.jpg";
    c4.view = 2000;
    c4.participants = 780;
    c4.higher = Random().nextInt(2) == 1;
    _circles.add(c);
    _circles.add(c1);
    _circles.add(c2);
    _circles.add(c3);
    _circles.add(c4);
    _circles.add(c);
    _circles.add(c2);
    _circles.add(c1);
    _circles.add(c4);
    _circles.add(c3);
  }

  Future<void> _onRefresh() async {
    print("---------refreshiing..........");
    setState(() {
      _initData();
    });
    _refreshController.refreshCompleted();
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

  @override
  bool get wantKeepAlive => true;
}
