import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/models/tabIconData.dart';
import 'package:iap_app/page/create_page.dart';
import 'package:iap_app/page/tweet_type_sel.dart';
import 'package:iap_app/part/bottomBarView.dart';
import 'package:iap_app/part/recom.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/shared.dart';
import 'package:iap_app/util/string.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _HomePageState();
  }
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  AnimationController animationController;

  final recomKey = GlobalKey<RecommendationState>();

  List<BaseTweet> _homeTweets = new List();
  int _currentPage = 1;

  bool isIniting = true;

  // 回复相关
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();
  String _hintText = "说点什么吧";
  TweetReply curReply;
  String destAccountId;
  double _replyContainerHeight = 0;

  List<String> tweetQueryTypes = List();

  @override
  void initState() {
    tabIconsList.forEach((tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    // animationController =
    //     AnimationController(duration: Duration(milliseconds: 600), vsync: this);
    // tabBody = MyDiaryScreen(animationController: animationController);
    getStoragePreferTypes();
    super.initState();
    initData();

    // _refreshController.requestRefresh();
  }

  Widget tabBody = Container(
    color: Color(0xFFF2F3F8),
  );

  void _onRefresh() async {
    print('On refresh');
    // monitor network fetch
    _currentPage = 1;
    List<BaseTweet> temp = await getData(_currentPage);

    if (!CollectionUtil.isListEmpty(temp)) {
      _homeTweets.clear();
      _homeTweets.addAll(temp);
      recomKey.currentState.updateTweetList(temp, add: false);
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
      recomKey.currentState.updateTweetList(null, add: true);

      _refreshController.resetNoData();
    }
  }

  void initData() async {
    List<BaseTweet> temp = await getData(1);
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
      _refreshController.loadNoData();
      return;
    }
    _homeTweets.addAll(temp);
    recomKey.currentState.updateTweetList(temp, add: true, start: false);

    _refreshController.loadComplete();
  }

  Future getData(int page) async {
    bool notAll = false;
    if (!CollectionUtil.isListEmpty(tweetQueryTypes)) {
      List<String> allTypes = tweetTypeMap.values.map((f) => f.name).toList();
      if (allTypes.length == tweetTypeMap.length) {
        for (int i = 0; i < allTypes.length; i++) {
          if (!tweetQueryTypes.contains(allTypes[i])) {
            notAll = true;
            break;
          }
        }
      }
    }

    List<BaseTweet> pbt = await (TweetApi.queryTweets(PageParam(page,
        pageSize: 5,
        types: (CollectionUtil.isListEmpty(tweetQueryTypes) || !notAll)
            ? null
            : tweetQueryTypes)));
    // _updateTWeetList(pbt);
    return pbt;
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () {},
          changeIndex: (index) {
            if (index == 0 || index == 2) {
              animationController.reverse().then((data) {
                if (!mounted) return;
                setState(() {
                  // tabBody =
                  //     MyDiaryScreen(animationController: animationController);
                });
              });
            } else if (index == 1 || index == 3) {
              animationController.reverse().then((data) {
                if (!mounted) return;
                setState(() {
                  // tabBody =
                  //     TrainingScreen(animationController: animationController);
                });
              });
            }
          },
        ),
      ],
    );
  }

  void getStoragePreferTypes() async {
    List<String> selTypes = await SharedPreferenceUtil.readListStringValue(
        SharedConstant.LOCAL_FILTER_TYPES);
    if (!CollectionUtil.isListEmpty(selTypes)) {
      setState(() {
        this.tweetQueryTypes = selTypes;
      });
    }
    setState(() {
      isIniting = false;
    });
  }

  void showReplyContainer(
      TweetReply tr, String destAccountNick, String destAccountId) {
    print('home page 回调 =============== $destAccountNick');
    if (StringUtil.isEmpty(destAccountNick)) {
      setState(() {
        _hintText = "评论";
      });
    } else {
      setState(() {
        _hintText = "回复 $destAccountNick";
      });
    }
    setState(() {
      curReply = tr;
      _replyContainerHeight = MediaQuery.of(context).size.width;
      this.destAccountId = destAccountId;
    });
    _focusNode.requestFocus();
  }

  void hideReplyContainer() {
    setState(() {
      _replyContainerHeight = 0;
      _controller.clear();
      _focusNode.unfocus();
    });
  }

  void _forwardFilterPage() async {
    List<String> selTypes = await SharedPreferenceUtil.readListStringValue(
        SharedConstant.LOCAL_FILTER_TYPES);
    if (CollectionUtil.isListEmpty(selTypes)) {
      selTypes = tweetTypeMap.values.map((v) => v.name).toList();
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TweetTypeSelect(
                  title: "过滤内容类型",
                  multi: true,
                  backText: "取消",
                  finishText: "完成",
                  initNames: selTypes,
                  callback: (typeNames) => setPreferTypes(typeNames),
                )));
  }

  void setPreferTypes(typeNames) {
    SharedPreferenceUtil.setListStringValue(
        SharedConstant.LOCAL_FILTER_TYPES, typeNames);
    this.tweetQueryTypes = typeNames;
    _refreshController.requestRefresh();
    // initData();
  }

  @override
  Widget build(BuildContext context) {
    print('home page state');

    return isIniting
        ? CircularProgressIndicator()
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // 触摸收起键盘
              _focusNode.unfocus();
            },
            // onTapDown: (details) =>
            //     FocusScope.of(context).requestFocus(FocusNode()),
            // onPanDown: (details) =>
            //     FocusScope.of(context).requestFocus(FocusNode()),
            child: Scaffold(
                body: Stack(
              children: <Widget>[
                Scaffold(
                    appBar: PreferredSize(
                        child: AppBar(
                          elevation: 0.3,
                          title: Text(
                            "南京工程学院",
                          ),
                          backgroundColor: ColorConstant.MAIN_BAR_COLOR,
                          centerTitle: true,
                          actions: <Widget>[
                            IconButton(
                              icon: Icon(Icons.filter_list,
                                  color: ColorConstant.TWEET_NICK_COLOR),
                              onPressed: () => _forwardFilterPage(),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add,
                              ),
                              color: ColorConstant.QQ_BLUE,
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CreatePage())),
                            ),
                          ],
                        ),
                        preferredSize: Size.fromHeight(
                            MediaQuery.of(context).size.height * 0.05)),

                    // headerSliverBuilder: (context, innerBoxIsScrolled) =>
                    //     <Widget>[],

                    body: Scrollbar(
                      child: SmartRefresher(
                          enablePullDown: true,
                          enablePullUp: true,
                          header: WaterDropHeader(
                              waterDropColor: ColorConstant.QQ_BLUE,
                              complete: Text('刷新成功')),
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
                                body = Text("释放加载多~");
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
                          child: Recommendation(
                            key: recomKey,
                            callback: (a, b, c) => showReplyContainer(a, b, c),
                            callback2: () => hideReplyContainer(),
                          )),
                    )),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                      // height: ,
                      width: _replyContainerHeight,
                      decoration: BoxDecoration(
                        color: Color(0xfff2f2f2),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
                      child: Row(
                        children: <Widget>[
                          ClipOval(
                            child: Image.network(
                              'https://tva1.sinaimg.cn/large/006y8mN6ly1g81f2ri7dqj30xc0m840w.jpg',
                              width: 35,
                              height: 35,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: TextField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  decoration: InputDecoration(
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
                                      color:
                                          ColorConstant.TWEET_REPLY_FONT_COLOR),
                                  onSubmitted: (value) {
                                    _sendReply(value);
                                  },
                                )),
                          ),
                        ],
                      )),
                )
              ],
            )));
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
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,

        // iconTheme: IconThemeData(size: 5),
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {
              // _select(choices[0]);
            },
          ),
        ],

        expandedHeight: SizeConstant.HP_COVER_HEIGHT,
        backgroundColor: GlobalConfig.DEFAULT_BAR_BACK_COLOR,
        floating: false,
        pinned: true,
        snap: false,
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          background: Image.network(
            "https://tva1.sinaimg.cn/large/006y8mN6gy1g81jr0a8t8j30dj0a5405.jpg",
            fit: BoxFit.cover,
          ),
        ),
      ),
    ];
  }

  _sendReply(String value) {
    if (StringUtil.isEmpty(value) || value.trim().length == 0) {
      return "";
    }
    curReply.body = value;
    Account acc = Account.fromId("eec6a9c3f57045b7b2b9ed255cb4e273");
    curReply.account = acc;
    print(curReply.toJson());
    TweetApi.pushReply(curReply).then((result) {
      print(result.data);
      TweetReply newReply = TweetReply.fromJson(result.data);
      if (result.isSuccess) {
        _controller.clear();
        hideReplyContainer();
        // setState(() {
        //   tweet.replyCount++;
        //   if (CollectionUtil.isListEmpty(widget.tweet.dirReplies)) {
        //     widget.tweet.dirReplies = new List();
        //   }
        //   widget.tweet.dirReplies.add(newReply);
        // });
      } else {
        _controller.clear();
        _hintText = "评论失败";
      }
      // widget.callback(tr, destAccountId);
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
