import 'dart:async';
import 'dart:math';

import 'package:common_utils/common_utils.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/component/empty_view.dart';
import 'package:iap_app/component/hot_app_bar.dart';
import 'package:iap_app/component/tweet/tweet_hot_card.dart';
import 'package:iap_app/global/oss_canstant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/model/discuss/discuss.dart';
import 'package:iap_app/model/hot_tweet.dart';
import 'package:iap_app/model/media.dart';
import 'package:iap_app/page/tweet_detail.dart';
import 'package:iap_app/part/circle/circle_my_tab.dart';
import 'package:iap_app/part/circle/circle_square_tab.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/umeng_util.dart';
import 'package:iap_app/util/widget_util.dart';

class CircleTabMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CircleTabMainState();
  }
}

class _CircleTabMainState extends State<CircleTabMain>
    with AutomaticKeepAliveClientMixin<CircleTabMain>, SingleTickerProviderStateMixin {
  double _expandedHeight = ScreenUtil().setWidth(600);

  // 当前页面存储的讨论数据模型
  Discuss _currentDiscuss;

  UniHotTweet hotTweet;

  // 连接通知器
  LinkHeaderNotifier _headerNotifier;

  Future<void> _onRefresh() async {
    await getData();
  }

  final String defaultCover = PathConstant.HOT_COVER_URL + OssConstant.THUMBNAIL_SUFFIX;
  String _currentCover = PathConstant.HOT_COVER_URL + OssConstant.THUMBNAIL_SUFFIX;
  String _preCover = PathConstant.HOT_COVER_URL + OssConstant.THUMBNAIL_SUFFIX;
  List<String> _covers;
  int _currentCoverIndex = 0;
  Timer _loadCoverTimer;

  bool isDark = false;

  TabController _tabController;

  int _currentSelectIndex = 0;

  @override
  void initState() {
    super.initState();
    // _futureTask = getData();
    _tabController = TabController(length: 4, vsync: this);
    UMengUtil.userGoPage(UMengUtil.PAGE_DISCUSS_INDEX);
    _headerNotifier = LinkHeaderNotifier();

    _tabController.addListener(() {
      setState(() {
        _currentSelectIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _headerNotifier.dispose();
    if (_loadCoverTimer != null) {
      // 页面销毁时触发定时器销毁
      if (_loadCoverTimer.isActive) {
        // 判断定时器是否是激活状态
        _loadCoverTimer.cancel();
      }
    }
    super.dispose();
  }

  Future<void> getData() async {
    Discuss dis = new Discuss();
    dis.title = "# 自拍美颜是欺骗吗？#";
    dis.id = "";
    dis.cover = "https://tva1.sinaimg.cn/large/008eGmZEgy1gmrst2ibm8j30u01sxk0w.jpg";
    dis.desc =
        "美颜这个事儿啊，往轻了说是欺骗围观群众，往重了说那简直是破坏社会公信力。现在的人拍照五分钟，修图两小时，什么磨皮美白，柔光滤镜，统统往上怼。闺蜜合照是否只修自己已经成了考验友情的一个指标，就连糙老爷们儿也开始使用一些自拍滤镜";
    setState(() {
      this._currentDiscuss = dis;
    });
    // UniHotTweet ht = await TweetApi.queryOrgHotTweets(Application.getOrgId);
    //
    // if (ht == null) {
    //   ToastUtil.showToast(context, '当前访问人数较多，请稍后重试');
    //   setState(() {
    //     this.hotTweet = null;
    //   });
    //   return;
    // }
    // setState(() {
    //   this.hotTweet = ht;
    // });
    // extractCovers();
    // ToastUtil.showToast(context, '更新完成');
  }

  void loopDisplayCover() {
    _loadCoverTimer?.cancel();
    if (_covers == null || _covers.length == 1) {
      setState(() {
        _currentCover = defaultCover;
      });
      return;
    }
    if (hotTweet == null) {
      return;
    }
    _loadCoverTimer = Timer.periodic(Duration(milliseconds: 3000), (t) {
      if (_currentCoverIndex == _covers.length) {
        _currentCoverIndex = 0;
//        _currentCoverIndex = Random().nextInt(2) == 1 ? 0: 1;
        setState(() {
          _currentCover = _covers[_currentCoverIndex];
          _loadCoverTimer.cancel();
        });
        return;
      }
      setState(() {
        _currentCover = _covers[_currentCoverIndex++];
        if (_currentCoverIndex > 0) {
          _preCover = _covers[_currentCoverIndex - 1];
        }
      });
    });
  }

  void extractCovers() {
    _covers?.clear();
    if (_covers == null) {
      _covers = new List();
    }
    _covers.add(defaultCover);
    if (hotTweet == null) {
      return;
    }
    List<HotTweet> bts = hotTweet.tweets;
    if (bts != null && bts.length > 0) {
      int len = bts.length;
      for (int i = 0; i < len; i++) {
        if (bts[i].cover != null && bts[i].cover.mediaType == Media.TYPE_IMAGE) {
          _covers.add(bts[i].cover.url + OssConstant.THUMBNAIL_SUFFIX);
        }
      }
      // loopDisplayCover();
      setState(() {
        _covers = _covers;
        _currentCover = _covers[0];
        // if(!CollectionUtil.isListEmpty(_covers)) {
        //   _currentCover = _covers[Random().nextInt(_covers.length)];
        // }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    isDark = ThemeUtils.isDark(context);

    bool loadingOrRedisInit = hotTweet == null;
    bool noData = !loadingOrRedisInit && CollectionUtil.isListEmpty(hotTweet.tweets);
    bool showTrend = !noData;

    int currentSelIndex = _tabController.index;

    return Scaffold(
      appBar: MyAppBar(
        isBack: true,
        centerTitle: '全部圈子',
      ),
      body: CustomScrollView(slivers: <Widget>[

        SliverPersistentHeader(
          // 可以吸顶的TabBar
          pinned: true,
          delegate: StickyTabBarDelegate(
            child: TabBar(
              // labelPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
              labelColor: Colors.black,

              isScrollable: false,
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.label,
              // indicator: UnderlineTabIndicator(
              //     borderSide: BorderSide(width: 5.0),
              //     insets: EdgeInsets.symmetric(horizontal:16.0, vertical: 0.0)
              // ),

              tabs: <Widget>[
                Tab(child: Text('美食', style: pfStyle.copyWith(color: _getTabColor(0)))),
                Tab(child: Text('学习', style: pfStyle.copyWith(color: _getTabColor(1)))),
                Tab(child: Text('活动', style: pfStyle.copyWith(color: _getTabColor(2)))),
                Tab(child: Text('其他', style: pfStyle.copyWith(color: _getTabColor(3)))),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.only(bottom: 0.0),
          sliver: SliverFillRemaining(
            // 剩余补充内容TabBarView
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                CircleSquareTabView(1, refreshWidgetColor: Colors.orangeAccent),
                CircleSquareTabView(2, refreshWidgetColor: Colors.tealAccent),
                CircleSquareTabView(3),
                CircleSquareTabView(4),
              ],
            ),
          ),
        )
        // SliverFillRemaining(
        //     child: StaggeredGridView.countBuilder(
        //   crossAxisCount: 4,
        //   itemCount: 16,
        //   itemBuilder: (BuildContext context, int index) => new Container(
        //       color: Colors.green,
        //       child: new Center(
        //         child: new CircleAvatar(
        //           backgroundColor: Colors.white,
        //           child: new Text('$index'),
        //         ),
        //       )),
        //   staggeredTileBuilder: (int index) => new StaggeredTile.count(3, index.isEven ? 2 : 1),
        //   mainAxisSpacing: 4.0,
        //   crossAxisSpacing: 4.0,
        // )),

        // Gaps.vGap5
      ]),
    );
  }

  Color _getTabColor(int index) {
    if (_currentSelectIndex == index) {
      return isDark ? Colors.white : Colors.black;
    }
    return isDark ? Colors.white38 : Colors.black54;
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

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;

  StickyTabBarDelegate({@required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: this.child,
    );
  }

  @override
  double get maxExtent => this.child.preferredSize.height;

  @override
  double get minExtent => this.child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
