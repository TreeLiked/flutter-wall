import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/api/tweet_type_subscribe.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/component/hot_app_bar.dart';
import 'package:iap_app/component/tweet/tweet_card.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/PermissionUtil.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/toast_util.dart';

class TweetTypeInfGroPlfPage extends StatefulWidget {
  final int fromTweetId;
  final String tweetType;

  TweetTypeInfGroPlfPage(this.fromTweetId, this.tweetType);

  @override
  State<StatefulWidget> createState() {
    return _TweetTypeInfGroPlfPageState();
  }
}

class _TweetTypeInfGroPlfPageState extends State<TweetTypeInfGroPlfPage> {
  // 连接通知器
  LinkHeaderNotifier _headerNotifier;

  // 推文类型
  TweetTypeEntity typeEntity;

  int _currentPage = 1;
  List<BaseTweet> _allTweets;

  bool _subThis = false;

  bool _initSub = true;

  @override
  void initState() {
    super.initState();
    _headerNotifier = LinkHeaderNotifier();

    String t = widget.tweetType;
    if (tweetTypeMap[t] == null) {
      t = fallbackTweetType;
    }
    typeEntity = tweetTypeMap[t];
    checkSubscribeStatus();
  }

  Future<void> _onRefresh() async {
    _currentPage = 1;
    await getData(true);
    ToastUtil.showToast(context, '更新完成');
  }

  Future<void> _onLoading() async {
    await getData(false);
  }

  Future<void> getData(bool clear) async {
    List<BaseTweet> tweets = await TweetApi.queryTweets(PageParam(
      _currentPage++,
      pageSize: 15,
      orgId: Application.getOrgId,
      types: [typeEntity.name],
    ));

    if (CollectionUtil.isListEmpty(tweets)) {
      ToastUtil.showToast(context, '没有更多了');
      return;
    }

    setState(() {
      if (_allTweets == null) {
        _allTweets = new List();
      }
      if (clear) {
        _allTweets.clear();
      }
      _allTweets.addAll(tweets);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeUtils.isDark(context);
    double imageSize = Application.screenWidth / 6 - 10;
    return Scaffold(
      body: EasyRefresh.custom(
          header: LinkHeader(
            _headerNotifier,
            extent: 70.0,
            triggerDistance: 70.0,
            enableHapticFeedback: true,
          ),
          firstRefresh: true,
          slivers: <Widget>[
            HotAppBarWidget(
              title: typeEntity.zhTag,
              headerNotifier: _headerNotifier,
              // backgroundImg: TweetTypeUtil.getTweetTypeCover(context),
              backgroundImg: TweetTypeUtil.getTweetEntityCoverUrl(typeEntity),
              cache: true,
              count: 10,
              sigma: 5.5,
              pinned: true,
              floating: true,
              snap: true,
              lightShadow: Colors.black12,
              outerRadius: BorderRadius.zero,
              imageRadius: BorderRadius.zero,
              content: Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.only(bottom: 20.0, left: 10.0, right: 10.0),
                height: double.maxFinite,
                width: double.maxFinite,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                          height: imageSize,
                          width: imageSize,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(2.0),
                                color: Colors.white,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: TweetTypeUtil.getTweetEntityCoverUrl(typeEntity),
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const CupertinoActivityIndicator(),
                                  ),
                                ),
                              ))),
                    ),
                    Flexible(
                      flex: 3,
                      fit: FlexFit.tight,
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('#${typeEntity.zhTag}',
                                style: pfStyle.copyWith(
                                    fontSize: Dimens.font_sp16,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w500)),
                            Gaps.vGap5,
                            Text('${typeEntity.intro}',
                                style: pfStyle.copyWith(
                                    fontSize: Dimens.font_sp14, letterSpacing: 1.1, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      fit: FlexFit.loose,
                      child: Container(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 30,
                            child: FlatButton(
                              onPressed: () async {
                                if (_initSub) {
                                  return;
                                }
                                bool a = await PermissionUtil.checkAndRequestNotification(context);
                                if (!a) {
                                  ToastUtil.showToast(context, "通知权限未开启");
                                  return;
                                }
                                await modSubscribe();
                              },
                              textColor: Colors.white,
                              color: _subThis ? typeEntity.color : null,
                              disabledTextColor: isDark ? Colours.dark_text_disabled : Colours.text_disabled,
                              disabledColor: isDark ? Colours.dark_button_disabled : Colours.button_disabled,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.black26, width: _subThis ? 0 : 1.0),
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: !_initSub
                                  ? (_subThis
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check, size: 15),
                                            Text(" 已订阅", style: pfStyle.copyWith(fontSize: Dimens.font_sp14)),
                                          ],
                                        )
                                      : Text("+ 订阅", style: pfStyle.copyWith(fontSize: Dimens.font_sp14)))
                                  : SpinKitDoubleBounce(size: 5, color: Colors.white),
                            ),
                          )
                        ],
                      )),
                    )
                  ],
                ),
              ),
              expandedHeight: ScreenUtil().setHeight(550),
            ),
            // SliverPersistentHeader(
            //   pinned: true,
            //   delegate: StickyTabBarDelegate(
            //     mmaxExtent: ScreenUtil().setHeight(220),
            //     mminExtent: ScreenUtil().setHeight(220),
            //     child:
            //   ),
            // ),
            SliverList(
              // itemExtent: CollectionUtil.isListEmpty(_allTweets) ? 0 : !noData ? 100 : Application.screenHeight,
              delegate: new SliverChildBuilderDelegate((BuildContext context, int index) {
                //创建列表项
                if (_allTweets == null) {
                  return Gaps.empty;
                }
                // if (tweets == null || tweets.length == 0) {
                //   return _noDataView();
                // }
                return TweetCard2(
                  _allTweets[index],
                  displayExtra: true,
                  displayPraise: false,
                  displayComment: false,
                  displayLink: true,
                  canPraise: true,
                  displayType: false,
                  onDetailDelete: (int tweetId) {
                    setState(() {
                      _allTweets.removeWhere((element) => element.id == tweetId);
                    });
                  },
                );
              }, childCount: CollectionUtil.isListEmpty(_allTweets) ? 0 : _allTweets.length),
            ),
          ],
          onRefresh: _onRefresh,
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
          onLoad: _onLoading),
    );
  }

  void modSubscribe() async {
    Utils.showDefaultLoadingWithBounds(context);

    Result r;
    if (_subThis) {
      // 已经订阅要取消
      r = await TtSubscribe.unSubscribeType(widget.tweetType);
    } else {
      // 想订阅
      r = await TtSubscribe.subscribeType(widget.tweetType);
    }
    NavigatorUtils.goBack(context);
    if (r != null && r.isSuccess) {
      ToastUtil.showToast(context, _subThis ? "已取消订阅" : "订阅成功～");
      setState(() {
        _subThis = !_subThis;
      });
    } else {
      if (r == null) {
        ToastUtil.showServiceExpToast(context);
      } else {
        ToastUtil.showToast(context, r.message);
      }
    }
  }

  void checkSubscribeStatus() async {
    Result r = await TtSubscribe.checkSubscribeStatus(widget.tweetType);
    if (r != null && r.isSuccess) {
      bool sub = r.data as bool;
      setState(() {
        _subThis = sub;
        _initSub = false;
      });
    } else {
      setState(() {
        _initSub = false;
      });
      if (r == null) {
        ToastUtil.showServiceExpToast(Application.context);
      } else {
        ToastUtil.showToast(Application.context, r.message);
      }
    }
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  final double mmaxExtent;
  final double mminExtent;

  StickyTabBarDelegate({@required this.child, @required this.mmaxExtent, @required this.mminExtent});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Scrollbar(child: this.child);
  }

  @override
  double get maxExtent => this.mmaxExtent;

  @override
  double get minExtent => this.mminExtent;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
