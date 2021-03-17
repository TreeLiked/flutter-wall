import 'dart:ui';

import 'package:extended_text/extended_text.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/popup_window.dart';
import 'package:iap_app/common-widget/sticky_row_delegate.dart';
import 'package:iap_app/component/circle/circle_card.dart';
import 'package:iap_app/component/circle/circle_tweet_card.dart';
import 'package:iap_app/component/custom_header.dart';
import 'package:iap_app/component/flexible_detail_bar.dart';
import 'package:iap_app/component/satck_img_conatiner.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/model/circle/circle.dart';
import 'package:iap_app/model/circle/circle_tweet.dart';
import 'package:iap_app/model/gender.dart';
import 'package:iap_app/model/media.dart';
import 'package:iap_app/page/circle/circle_detail.dart';
import 'package:iap_app/page/common/report_page.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/circle_router.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/umeng_util.dart';
import 'package:iap_app/util/widget_util.dart';

class CircleHome extends StatefulWidget {
  final Circle _circle;

  CircleHome(this._circle);

  @override
  State<StatefulWidget> createState() {
    return _CircleHomeState(this._circle);
  }
}

class _CircleHomeState extends State<CircleHome> {
  EasyRefreshController _refreshController = EasyRefreshController();
  ScrollController _scrollController = ScrollController();

  LinkHeaderNotifier _linkHeaderNotifier;

  // 两个排序
  List _sortTypeList = ["热门排序", "最新内容"];

  // 默认时间排序
  int _sortTypeIndex = 1;

  // 按钮key
  GlobalKey _sortButtonKey = GlobalKey();

  final Circle _circle;

  BuildContext _context;
  bool isDark = false;

  // 是否显示滚动到顶部组件
  bool displayGoTopWidget = false;

  // 是否当前用户加入了该圈子
  bool iJoin = false;

  _CircleHomeState(this._circle);

  @override
  void initState() {
    super.initState();
    _linkHeaderNotifier = LinkHeaderNotifier();
    _scrollController.addListener(_scrollListener);
  }

  _scrollListener() {
    if (showGoTop != displayGoTopWidget) {
      setState(() {
        displayGoTopWidget = showGoTop;
      });
    }
  }

  bool get showGoTop {
    return _scrollController.hasClients && _scrollController.offset > 230;
  }

  @override
  void dispose() {
    _linkHeaderNotifier ?? dispose();
    _refreshController ?? dispose();
    _scrollController ?? dispose();
    _sortButtonKey.currentState ?? dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    this._context = context;
    isDark = ThemeUtils.isDark(context);

    return Stack(
      children: [
        NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                centerTitle: true,
                title: MyCustomHeader(_linkHeaderNotifier),
                expandedHeight: 230.0,

                snap: false,
                floating: false,
                elevation: 0.0,

                leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    iconSize: 23.0,
                    onPressed: () => NavigatorUtils.goBack(context)),
                actions: [
                  _getActionItem('circle/circle_detail', () => _displayDetail()),
                  _getActionItem('circle/circle_more', () => _displayMoreActs()),
                ],
                flexibleSpace: Container(
                  color: ThemeUtils.isDark(context) ? ColorConstant.MAIN_BG_DARK : ColorConstant.MAIN_BG,
                  child: ClipRRect(
                    child: FlexibleDetailBar(
                      content: Container(
                        padding: const EdgeInsets.only(top: kToolbarHeight, left: 20.0, right: 20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${_circle.brief}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: pfStyle.copyWith(
                                  fontSize: Dimens.font_sp20, color: Colors.white, letterSpacing: 1.1),
                            ),
                            Gaps.vGap10,
                            Container(
                              alignment: Alignment.center,
                              child: ExtendedText("${_circle.desc}",
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  selectionEnabled: true,
                                  overflowWidget: TextOverflowWidget(
                                      child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                                    const Text(' \u2026 '),
                                    GestureDetector(
                                        child: Text('查看更多',
                                            style: pfStyle.copyWith(
                                                fontSize: Dimens.font_sp13, color: Colors.white70)),
                                        onTap: () => _displayDetail()),
                                  ])),
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                  style: pfStyle.copyWith(fontSize: Dimens.font_sp14, color: Colors.white70)),
                            ),
                            Gaps.vGap20,
                            iJoin == null
                                ? Gaps.empty
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                          padding:
                                              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                          decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius: BorderRadius.circular(18.0),
                                          ),
                                          child: iJoin ? _getCreateContentItem() : _getApplyJoinItem()),
                                    ],
                                  )
                          ],
                        ),
                      ),
                      background: Stack(
                        children: <Widget>[
                          Utils.showFadeInImage(_circle.cover, BorderRadius.circular(0.0), cache: true),
                          BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaY: 3,
                              sigmaX: 3,
                            ),
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                  gradient: new LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isDark
                                          ? [Colors.black26, Colors.black45]
                                          : [Colors.black12, Colors.black38])),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                // flexibleSpace: StackImageContainer(
                //   _circle.cover,
                //   height: 230,
                //   hasShadow: true,
                //   centerWidget: Text('kskk'),
                //   // width: double.infinity,
                // ),

                // flexibleSpace: FlexibleSpaceBar(
                //   title: Text(_circle.brief),
                //   background: Image.network(
                //     _circle.cover,
                //     fit: BoxFit.cover,
                //   ),
                // ),

                // bottom: PreferredSize(
                //   preferredSize: Size.fromHeight(100),
                //   child: Text("1223"),
                // ),
              ),
            ];
          },
          body: MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: Material(
                child: EasyRefresh.custom(
                    controller: _refreshController,
                    header: LinkHeader(
                      _linkHeaderNotifier,
                      extent: 50.0,
                      triggerDistance: 50.0,
                      // completeDuration: Duration(milliseconds: 5000),
                      enableHapticFeedback: true,
                    ),
                    firstRefresh: false,
                    slivers: <Widget>[
                      SliverPersistentHeader(
                          delegate: StickyRowDelegate(
                              padding: const EdgeInsets.only(left: 15.0),
                              bgColor: ThemeUtils.getBackgroundColor(context),
                              children: [
                                GestureDetector(
                                    key: _sortButtonKey,
                                    onTap: () => _showSortTypeSel(),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          child: Text('${_sortTypeList[_sortTypeIndex]}',
                                              style: pfStyle.copyWith(
                                                  fontSize: Dimens.font_sp14,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 1.0)),
                                        ),
                                        Gaps.hGap4,
                                        LoadAssetSvg("sort_arrow_down",
                                            width: 17, height: 17, color: ThemeUtils.getIconColor(context)),
                                      ],
                                    ))
                              ],
                              height: 30,
                              crossAxisAlignment: CrossAxisAlignment.center)),
                      SliverPadding(
                          padding: const EdgeInsets.only(bottom: 10.0, top: 0.0),
                          sliver: SliverList(
                            delegate: new SliverChildBuilderDelegate((BuildContext context, int index) {
                              CircleTweet ct = new CircleTweet();
                              ct.sentTime = DateTime.now();
                              ct.account = Application.getAccount..gender = Gender.FEMALE.name;
                              ct.body = 'Flutter - Wrap text on overflow, like insert ellipsis or fade ...' *
                                  (index % 2 == 1 ? 1 : 10);
                              ct.view = 2001;
                              ct.medias = [
                                new Media.fromUrl(Media.MODULE_CIRCLE, Application.getAccount.avatarUrl)
                                  ..mediaType = Media.TYPE_IMAGE,
                                new Media.fromUrl(Media.MODULE_CIRCLE, _circle.cover)
                                  ..mediaType = Media.TYPE_IMAGE,
                              ];
                              ct.displayOnlyCircle = index % 2 == 0;
                              return CircleTweetCard(ct);
                            }, childCount: 20),
                          )),
                      // Gaps.vGap5
                    ],
                    onRefresh: _onRefresh,
                    onLoad: null)),
          ),
          // body: MediaQuery.removePadding(
          //   removeTop: true,
          //   context: context,
          //   child: ListView.builder(
          //     itemBuilder: (BuildContext context, int index) {
          //       return Container(
          //         height: 80,
          //         color: Colors.primaries[index % Colors.primaries.length],
          //         alignment: Alignment.center,
          //         child: Text(
          //           '$index',
          //           style: TextStyle(color: Colors.white, fontSize: 20),
          //         ),
          //       );
          //     },
          //     itemCount: 20,
          //   ),
          // ),
        ),
        displayGoTopWidget
            ? Positioned(
                child: GestureDetector(
                  onTap: () => _scrollController.animateTo(0,
                      duration: Duration(milliseconds: 3000), curve: Curves.fastLinearToSlowEaseIn),
                  child: Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: isDark ? Colors.black : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.orangeAccent : Colors.amberAccent,
                            blurRadius: 5.0,
                          ),
                        ]),
                    child: LoadAssetSvg(
                      'circle_go_top',
                      width: double.infinity,
                      height: double.infinity,
                      color: isDark ? Colors.orangeAccent : Colors.amber,
                    ),
                  ),
                ),
                right: (Application.screenWidth - 50) / 2,
                bottom: 60,
              )
            : Gaps.empty
      ],
    );
  }

  Future<void> _onRefresh() async {}

  Widget _getActionItem(String iconPath, Function ontap) {
    return Container(
      padding: const EdgeInsets.all(3.0),
      margin: const EdgeInsets.only(right: 15.0),
      child: GestureDetector(
        onTap: ontap,
        child: LoadAssetIcon(iconPath, width: 20.0, height: 20.0, color: Colors.white),
      ),
    );
  }

  Widget _getApplyJoinItem() {
    return GestureDetector(
        onTap: () {
          setState(() {
            this.iJoin = !this.iJoin;
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 14,
              color: Colors.white,
            ),
            Text(" 申请加入", style: pfStyle.copyWith(fontSize: Dimens.font_sp14, color: Colors.white)),
          ],
        ));
  }

  Widget _getCreateContentItem() {
    return GestureDetector(
        onTap: () {
          setState(() {
            this.iJoin = !this.iJoin;
            NavigatorUtils.push(context, CircleRouter.CREATE, transitionType: TransitionType.fadeIn);
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.create,
              size: 14,
              color: Colors.white,
            ),
            Text(" 发布内容", style: pfStyle.copyWith(fontSize: Dimens.font_sp14, color: Colors.white)),
          ],
        ));
  }

  void _showSortTypeSel() {
    // 获取点击控件的坐标
    final RenderBox button = _sortButtonKey.currentContext.findRenderObject();
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    // 获得控件左下方的坐标
    var a = button.localToGlobal(Offset(0.0, button.size.height), ancestor: overlay);
    // 获得控件右下方的坐标
    var b = button.localToGlobal(button.size.bottomRight(Offset(0, 0)), ancestor: overlay);
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(a, b),
      Offset.zero & overlay.size,
    );
    showPopupWindow(
      context: context,
      fullWidth: true,
      position: position,
      elevation: 0.0,
      child: GestureDetector(
        onTap: () => NavigatorUtils.goBack(context),
        child: Container(
          color: const Color(0x99000000),
          height: Application.screenHeight - b.dy,
          child: ListView.builder(
            physics: ClampingScrollPhysics(),
            itemCount: _sortTypeList.length,
            itemBuilder: (_, index) {
              Color backgroundColor = ThemeUtils.getBackgroundColor(context);
              bool selected = index == _sortTypeIndex;
              return Material(
                color: backgroundColor,
                child: InkWell(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
                    child: Text(
                      _sortTypeList[index],
                      style: pfStyle.copyWith(
                          fontSize: Dimens.font_sp14,
                          color: selected ? ColorConstant.getTweetNickColor(context) : null,
                          letterSpacing: 1.0),
                    ),
                  ),
                  onTap: () {
                    NavigatorUtils.goBack(context);
                    setState(() {
                      _sortTypeIndex = index;
                      _refreshController.callRefresh();
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _displayDetail() {
    BottomSheetUtil.showBottomSheet(context, 0.65, CircleDetailPage(_circle.id, circle: _circle),
        topLine: false);
    UMengUtil.userGoPage(UMengUtil.PAGE_CIRCLE_DETAIL);
  }

  void _displayMoreActs() {
    List<BottomSheetItem> items = List();
    items.add(BottomSheetItem(
        Icon(
          Icons.warning,
          color: Colors.grey,
        ),
        '举报', () {
      Navigator.pop(context);
      NavigatorUtils.goReportPage(context, ReportPage.REPORT_CIRCLE, _circle.id.toString(), "圈子举报");
    }));

    if (iJoin != null && iJoin == true) {
      items.add(BottomSheetItem(
          Icon(
            Icons.exit_to_app,
            color: Colors.red,
          ),
          '退出圈子', () {
        Navigator.pop(context);
        NavigatorUtils.goReportPage(context, ReportPage.REPORT_CIRCLE, _circle.id.toString(), "圈子举报");
      }));
    }

    BottomSheetUtil.showBottomSheetView(context, items);
  }
}