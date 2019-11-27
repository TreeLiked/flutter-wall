import 'dart:ui';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/models/tabIconData.dart';
import 'package:iap_app/page/tweet_type_sel.dart';
import 'package:iap_app/part/recom.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/shared.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
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

  void _onRefresh(BuildContext context) async {
    print('On refresh');
    // monitor network fetch
    _currentPage = 1;
    List<BaseTweet> temp = await getData(_currentPage);

    if (!CollectionUtil.isListEmpty(temp)) {
      recomKey.currentState.updateTweetList(temp, add: false);
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
      recomKey.currentState.updateTweetList(null, add: true);
    }
  }

  void initData() async {
    List<BaseTweet> temp = await getData(1);
    if (!CollectionUtil.isListEmpty(temp)) {
      recomKey.currentState.updateTweetList(temp, add: false);
    }
  }

  void _onLoading() async {
    // monitor network fetch

    List<BaseTweet> temp = await getData(++_currentPage);
    if (CollectionUtil.isListEmpty(temp)) {
      print('没有数据了');
      _currentPage--;
      _refreshController.loadNoData();
    } else {
      print('adddddd---------');
      recomKey.currentState.updateTweetList(temp, add: true, start: false);
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
    // _updateTWeetList(pbt);
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
                  callback: () {
                    _refreshController.requestRefresh();
                  },
                )));
  }

  void setPreferTypes(typeNames) {
    SharedPreferenceUtil.setListStringValue(
        SharedConstant.LOCAL_FILTER_TYPES, typeNames);
    this.tweetQueryTypes = typeNames;
    _refreshController.requestRefresh();
    // initData();
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
        Scaffold(
            appBar: PreferredSize(
                child: AppBar(
                  elevation: 0.3,
                  title: Text(
                    "南京工程学院",
                  ),
                  // backgroundColor: Color(0xfff9f9f9),
                  centerTitle: true,
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: () => _forwardFilterPage(),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                      ),
                      onPressed: () {
                        Application.router.navigateTo(context, Routes.create,
                            transition: TransitionType.fadeIn);
                      },
                    ),
                  ],
                ),
                preferredSize:
                    Size.fromHeight(MediaQuery.of(context).size.height * 0.06)),
            body: Listener(
              onPointerDown: (_) {
                hideReplyContainer();
                startY = _.position.dy;
              },
              onPointerUp: (_) {
                if (widget.pullDownCallBack != null) {
                  widget.pullDownCallBack((_.position.dy - startY) > 0);
                }
              },
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
                  onRefresh: () => _onRefresh(context),
                  onLoading: _onLoading,
                  child: Recommendation(
                    key: recomKey,
                    callback: (a, b, c, d) {
                      showReplyContainer(a, b, c);
                      sendCallback = d;
                    },
                    // callback2: () => hideReplyContainer(),
                  )),
            )
            // )
            ),
        Positioned(
          left: 0,
          bottom: 0,
          child: Container(
              // height: ,
              width: _replyContainerHeight,
              decoration: BoxDecoration(
                color: ThemeUtils.isDark(context)
                    ? Color(0xff363636)
                    : Color(0xfff2f2f2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
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
                          decoration: InputDecoration(
                              suffixIcon: curReply != null && curReply.type == 1
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
                                        size: SizeConstant.TWEET_PROFILE_SIZE *
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
                                fontSize: SizeConstant.TWEET_TIME_SIZE - 1,
                              )),
                          textInputAction: TextInputAction.send,
                          cursorColor: Colors.grey,
                          style: TextStyle(
                            fontSize: SizeConstant.TWEET_FONT_SIZE - 1,
                          ),
                          onSubmitted: (value) {
                            _sendReply(value);
                          },
                        )),
                  ),
                ],
              )),
        )
      ],
    );
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      // PlatformAppBar(
      //   title: Text(
      //     '南京工程学院',
      //     style: TextStyle(fontSize: GlobalConfig.TEXT_TITLE_SIZE),
      //   ),
      // )
      Stack(
        children: <Widget>[
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
                icon: Icon(Icons.filter_list),
                onPressed: () {
                  // _select(choices[0]);
                },
              ),
            ],

            expandedHeight: SizeConstant.HP_COVER_HEIGHT,
            // backgroundColor: GlobalConfig.DEFAULT_BAR_BACK_COLOR,
            backgroundColor: Colors.transparent,
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
          // BackdropFilter(
          //   filter: new ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          //   child: new Container(
          //     color: Colors.white.withOpacity(0.1),
          //     width: 300,
          //     height: 300,
          //   ),
          // )
        ],
      )
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

  @override
  bool get wantKeepAlive => true;
}
