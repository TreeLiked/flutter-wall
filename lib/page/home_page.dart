import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/base/plf_appbar.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/part/recom.dart';
import 'package:iap_app/util/collection.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final recomKey = GlobalKey<RecommendationState>();

  List<BaseTweet> _homeTweets = new List();
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void _onRefresh() async {
    print('On refresh');
    // monitor network fetch
    _currentPage = 1;
    List<BaseTweet> temp = await getData(_currentPage);
    print('temp');
    _homeTweets.clear();
    print('on refresh set state');
    _homeTweets.addAll(temp);

    recomKey.currentState.updateTweetList(temp, add: false);
    // if failed,use refreshFailed()
    _refreshController.refreshFailed();
  }

  void initData() async {
    List<BaseTweet> temp = await getData(1);
    print('init data');
    print(temp);
    _homeTweets.clear();
    _homeTweets.addAll(temp);
    recomKey.currentState.updateTweetList(temp, add: false);
  }

  void _onLoading() async {
    // monitor network fetch
    print(_currentPage.toString() + 'sdsaddasd;');
    List<BaseTweet> temp = await getData(++_currentPage);
    if (CollectionUtil.isListEmpty(temp)) {
      _currentPage--;
      _refreshController.loadComplete();
      return;
    }
    _homeTweets.addAll(temp);
    recomKey.currentState.updateTweetList(temp, add: true, start: false);

    _refreshController.loadComplete();
  }

  Future getData(int page) async {
    List<BaseTweet> pbt =
        await (TweetApi.queryTweets(PageParam(page, pageSize: 3)));
    // _updateTWeetList(pbt);
    return pbt;
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      // PlatformAppBar(
      //   title: Text(
      //     '南京工程学院',
      //     style: TextStyle(fontSize: GlobalConfig.TEXT_TITLE_SIZE),
      //   ),
      // )
      SliverAppBar(
        centerTitle: true, //标题居中
        title: Text(
          '南京工程学院',
          style: TextStyle(fontSize: GlobalConfig.TEXT_TITLE_SIZE),
        ),
        elevation: 0,
        leading: Icon(
          Icons.bubble_chart,
          color: Colors.lightGreen,
        ),
        // iconTheme: IconThemeData(size: 5),
        actions: <Widget>[
          new IconButton(
            // action button
            icon: Icon(Icons.bubble_chart),
            onPressed: () {
              this.initData();
              // _select(choices[0]);
            },
          ),
        ],

        expandedHeight: 200.0, //展开高度200
        backgroundColor: GlobalConfig.DEFAULT_BAR_BACK_COLOR,

        floating: false, //不随着滑动隐藏标题
        pinned: true, //不固定在顶部
        snap: false,
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          background: Image.network(
            "https://tva1.sinaimg.cn/large/006y8mN6ly1g7lyhkuhz7j30rs0e875x.jpg",
            fit: BoxFit.cover,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    print('home page state');
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        // onTap: () {
        //   // 触摸收起键盘
        //   FocusScope.of(context).requestFocus(FocusNode());
        // },
        // onTapDown: (details) =>
        //     FocusScope.of(context).requestFocus(FocusNode()),
        // onPanDown: (details) =>
        //     FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
            body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) =>
                    _sliverBuilder(context, innerBoxIsScrolled),
                body: Scrollbar(
                  child: SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: true,
                      header: WaterDropMaterialHeader(
                        color: Colors.blue,
                        backgroundColor: Color(0xffDEB887),
                      ),
                      footer: CustomFooter(
                        builder: (BuildContext context, LoadStatus mode) {
                          Widget body;
                          if (mode == LoadStatus.idle) {
                            body = Text("继续上划!");
                          } else if (mode == LoadStatus.loading) {
                            body = CupertinoActivityIndicator();
                          } else if (mode == LoadStatus.failed) {
                            body = Text("加载失败");
                          } else if (mode == LoadStatus.canLoading) {
                            body = Text("释放加载更多~");
                          } else {
                            body = Text("没有更多了～");
                          }
                          return Container(
                            height: 30.0,
                            child: Center(child: body),
                          );
                        },
                      ),
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      onLoading: _onLoading,
                      child: Recommendation(key: recomKey)),
                ))));
  }
}
