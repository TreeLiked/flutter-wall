import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/circle.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/component/circle/circle_simple_item.dart';
import 'package:iap_app/component/satck_img_conatiner.dart';
import 'package:iap_app/component/simgple_tag.dart';
import 'package:iap_app/model/account/circle_account.dart';
import 'package:iap_app/model/circle/circle.dart';
import 'package:iap_app/model/circle_query_param.dart';
import 'package:iap_app/model/cirlce_type.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/page/circle/circle_home.dart';
import 'package:iap_app/page/tweet_detail.dart';
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

class CircleMyPage extends StatefulWidget {
  CircleMyPage();

  @override
  State<StatefulWidget> createState() {
    return _CircleMyPageState();
  }
}

class _CircleMyPageState extends State<CircleMyPage> {
  static const String _TAG = "_CircleMyPageState";

  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController = RefreshController(initialRefresh: true);

  int _currentPage = 1;
  List<Circle> _circles;

  bool isDark = false;

  void _initData() {}

  Future<void> _onRefresh() async {
    LogUtil.e("---onRefresh---", tag: _TAG);
    _refreshController.resetNoData();
    _currentPage = 1;
    List<Circle> temp = await getData(_currentPage);
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
      appBar: MyAppBar(
        centerTitle: '我的圈子',
        isBack: true,
      ),
      body: SafeArea(child: SmartRefresher(
        enablePullUp: false,
        enablePullDown: true,
        primary: false,
        scrollController: _scrollController,
        controller: _refreshController,
        cacheExtent: 20,
        header:
        WaterDropHeader(waterDropColor: Color(0xff96CDCD), complete: const Text('刷新完成', style: pfStyle)),
        footer: ClassicFooter(
          loadingText: '正在加载...',
          canLoadingText: '释放以加载更多',
          noDataText: '到底了哦',
          idleText: '继续上滑',
        ),
        child: _circles == null
            ? Gaps.empty
            : _circles.length == 0
            ? WidgetUtil.getEmptyView("no_data", dartIconPath: "no_data_dark", text: '快去加入或创建一个圈子吧')
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
            : ListView.separated(
            shrinkWrap: false,
            separatorBuilder: (_, index) {
              if (index == _circles.length - 1) {
                return Gaps.empty;
              }
              return Container(
                  padding: const EdgeInsets.only(left: 100, right: 40), child: Gaps.line);
            },
            itemCount: _circles.length,
            itemBuilder: (context, index) {
              var c = _circles[index];
              return ListTile(
                leading: _renderLeft(c),
                title: Text("${c.brief}",
                    style: pfStyle.copyWith(fontSize: Dimens.font_sp16),
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                subtitle: Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  child: Text("${c.desc}",
                      style: pfStyle.copyWith(fontSize: Dimens.font_sp14, color: Colors.grey),
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
                enabled: true,
                onTap: () => _forwardDetail(c),
              );
            }),

        // : ListView.builder(
        //     itemCount: _circles.length,
        //     itemBuilder: (ctx, index) {
        //       return CircleSimpleItem(_circles[index]);
        //     }),
        onRefresh: () => _onRefresh(),
        onLoading: _onLoading,
      ))
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

  _forwardDetail(Circle c) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CircleHome(c)),
    );
  }

  Future getData(int page) async {
    List<Circle> pbt = await CircleApi.queryUserCircles();
    if (CollectionUtil.isListNotEmpty(pbt)) {
      pbt.sort((c1, c2) {
        if (c1.meRole == null) {
          return 1;
        }
        if (c2.meRole == null) {
          return -1;
        }
        if (c1.meRole == CircleAccountRole.CREATOR) {
          return -1;
        }
        if (c2.meRole == CircleAccountRole.CREATOR) {
          return 1;
        }
        if (c1.meRole == CircleAccountRole.ADMIN) {
          return -1;
        }
        if (c2.meRole == CircleAccountRole.ADMIN) {
          return 1;
        }
        return 0;
      });
    }
    return pbt;
  }

  _renderLeft(Circle _circle) {
    // return ClipRRect(
    //     borderRadius: BorderRadius.circular(8.0),
    //     child: CachedNetworkImage(imageUrl: _circle.cover, fit: BoxFit.cover, width: 70, height: 70));
    return StackImageContainer(
      _circle.cover,
      hasShadow: false,
      height: 56,
      width: 56,
      positionedWidgets: [
        Positioned(
            child: SimpleTag(
              "${CircleTypeEnum.fromName(_circle.circleType).zhTag}",
              round: true,
              radius: 5.0,
              bgColor: Colors.white70,
              bgDarkColor: Colors.white70,
              textColor: Colors.black87,
            ),
            left: 2.0,
            top: 2.0)
      ],
    );
  }
}
