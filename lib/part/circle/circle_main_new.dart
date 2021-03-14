import 'dart:async';
import 'dart:math';

import 'package:common_utils/common_utils.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/click_item.dart';
import 'package:iap_app/common-widget/sticky_row_delegate.dart';
import 'package:iap_app/component/circle/circle_card.dart';
import 'package:iap_app/component/circle/circle_simple_item.dart';
import 'package:iap_app/component/circle/circle_swpier_banner.dart';
import 'package:iap_app/component/empty_view.dart';
import 'package:iap_app/component/hot_app_bar.dart';
import 'package:iap_app/component/tweet/tweet_hot_card.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/oss_canstant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/model/account/circle_account.dart';
import 'package:iap_app/model/circle/circle.dart';
import 'package:iap_app/model/discuss/discuss.dart';
import 'package:iap_app/model/hot_tweet.dart';
import 'package:iap_app/model/media.dart';
import 'package:iap_app/page/circle/circle_home.dart';
import 'package:iap_app/page/tweet_detail.dart';
import 'package:iap_app/part/circle/circle_main.dart';
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
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CircleMainNew extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CircleMainNewState();
  }
}

class _CircleMainNewState extends State<CircleMainNew>
    with AutomaticKeepAliveClientMixin<CircleMainNew>, SingleTickerProviderStateMixin {
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  // 用来控制titleText的更换
  ScrollController _scrollController = ScrollController();

  // 主标题展示"精彩"/"推荐"
  bool showRecommendTitleText = false;

  // 连接通知器
  LinkHeaderNotifier _headerNotifier;

  Future<void> _onRefresh() async {
    await getData();
  }

  final String defaultCover = PathConstant.HOT_COVER_URL + OssConstant.THUMBNAIL_SUFFIX;

  bool isDark = false;

  int _currentSelectIndex = 0;

  List<Circle> _circles = List();

  void _initData() {
    String cover = "https://tva1.sinaimg.cn/large/008eGmZEgy1goi9lajqpvj307705eaaf.jpg";
    Circle c = new Circle();
    c.brief = "工程吃货小组";
    c.desc = "哪里有饭哪里就有我们！！！";
    c.cover = cover;
    c.view = 2000;
    c.participants = 780;
    c.limit = 1000;
    c.joinType = Circle.JOIN_TYPE_REFUSE_ALL;
    c.higher = Random().nextInt(2) == 1;

    Circle c1 = new Circle();
    c1.brief = "大一计算机学院相亲交流圈子";
    c1.desc = "想脱单吗？想认识更多的帅哥哥和小姐姐们？？";
    c1.cover = "https://tva1.sinaimg.cn/large/008eGmZEgy1goi9ilaj7pj30u00u0did.jpg";
    c1.view = 2000;
    c1.participants = 780;
    c1.limit = 1000;
    c1.joinType = Circle.JOIN_TYPE_DIRECT;
    c1.higher = Random().nextInt(2) == 1;

    Circle c2 = new Circle();
    c2.brief = "2021届考研学习交流";
    c2.desc = "这里是21届考研的学习交流圈子，非诚勿扰";
    c2.cover = "https://tva1.sinaimg.cn/large/008eGmZEgy1goi9iu1muuj30jg0jgq3q.jpg";
    c2.view = 2000;
    c2.participants = 780;
    c2.limit = 1000;
    c2.joinType = Circle.JOIN_TYPE_ADMIN_AGREE;

    c2.higher = Random().nextInt(2) == 1;

    Circle c3 = new Circle();
    c3.brief = "王者开黑第一小组";
    c3.desc = "永恒钻石，星耀渣渣，王者低🌟废物都可以来";
    c3.cover = "https://tva1.sinaimg.cn/large/008eGmZEgy1goi9jxjom7j308l04j3yt.jpg";
    c3.view = 2000;
    c3.participants = 780;
    c3.higher = Random().nextInt(2) == 1;
    c3.limit = 1000;
    c3.joinType = Circle.JOIN_TYPE_ADMIN_AGREE;

    Circle c4 = new Circle();
    c4.brief = "音乐爱好交流组";
    c4.desc = "希望音乐可以治愈你～";
    c4.cover = "https://tva1.sinaimg.cn/large/008eGmZEgy1goi9kfz3b5j308c04oaa6.jpg";
    c4.view = 2000;
    c4.participants = 780;
    c4.higher = Random().nextInt(2) == 1;
    c.contentPrivate = true;
    c1.contentPrivate = false;
    c2.contentPrivate = true;
    c3.contentPrivate = false;
    c4.contentPrivate = true;

    CircleAccount ca = CircleAccount();
    ca.id = Application.getAccount.id;
    ca.nick = Application.getAccount.nick;
    ca.avatarUrl = Application.getAccount.avatarUrl;

    c.creator  = ca;
    c1.creator  = ca;
    c2.creator  = ca;
    c3.creator  = ca;
    c4.creator  = ca;

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

  @override
  void initState() {
    super.initState();
    // _futureTask = getData();
    UMengUtil.userGoPage(UMengUtil.PAGE_CIRCLE_INDEX);
    _headerNotifier = LinkHeaderNotifier();
    _scrollController.addListener(_scrollListener);

    _initData();
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

  Future<void> getData() async {
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
                      primary: false,
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
                        _getActionItem("circle/circle_create", () => {}),
                        _getActionItem("circle/circle_search", () => {}),
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
                  child: ListView.builder(
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
      padding: const EdgeInsets.all(3.0),
      margin: const EdgeInsets.only(left: 0.0),
      child: GestureDetector(
        onTap: ontap,
        child: CircleAvatar(
            child:
                LoadAssetIcon(iconPath, width: 16.0, height: 16.0, color: ThemeUtils.getIconColor(context)),
            backgroundColor: ThemeUtils.getBackColor(context)),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class StickySwiperDelegate extends SliverPersistentHeaderDelegate {
  final List<Circle> children;

  StickySwiperDelegate({@required this.children});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    if (children == null || children.isEmpty) {
      return Gaps.empty;
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
  double get maxExtent => 130;

  @override
  double get minExtent => CollectionUtil.isListEmpty(children) ? 0 : 120;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
