import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/page/square/activity_page_view.dart';
import 'package:iap_app/page/square/topic/topic_page_view.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/square_router.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:unicorndial/unicorndial.dart';

class SquareIndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    print('square index create state');
    return _SquareIndexPage();
  }
}

class _SquareIndexPage extends State<SquareIndexPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<SquareIndexPage> {
  int _currentIndex = 0;

  List<String> tabs;

  bool isDark = false;

  var childButtons = List<UnicornButton>();

  TabController _controller;

  final pageController = PageController();

  @override
  void initState() {
    super.initState();
    print('square index craete state');

    initPageData();

    _controller = TabController(vsync: this, length: tabs.length)
      ..addListener(() {
        if (_controller.index.toDouble() == _controller.animation.value) {
          switch (_controller.index) {
            case 0:
              print(1);
              break;
            case 1:
              print(2);
              break;
          }
        }
      });
  }

  void initPageData() {
    tabs = ['话题'];

    childButtons.add(UnicornButton(
        labelText: '创建话题',
        labelColor: Colors.black,
        labelBackgroundColor: Colors.transparent,
        labelHasShadow: false,
        hasLabel: true,
        currentButton: FloatingActionButton(
            backgroundColor: Colors.white,
            mini: true,
            heroTag: 'topic',
            onPressed: () {
              NavigatorUtils.push(context, SquareRouter.topicCreate, transitionType: TransitionType.fadeIn);
            },
//            child: Icon(Icons.bubble_chart, color: Colors.lightGreen))));
            child: LoadAssetSvg(
              "voice",
              height: 25,
              width: 25,
              color: Colors.pinkAccent,
            ))));

    childButtons.add(UnicornButton(
        labelText: '发起活动',
        labelColor: Colors.black,
        labelBackgroundColor: Colors.transparent,
        labelHasShadow: false,
        hasLabel: true,
        currentButton: FloatingActionButton(
            onPressed: () {
              NavigatorUtils.goBack(context);
            },
            backgroundColor: Colors.white,
            mini: true,
            heroTag: 'activity',
            child: const LoadAssetSvg(
              "thing",
              height: 25,
              width: 25,
              color: Colors.purpleAccent,
            ))));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    isDark = ThemeUtils.isDark(context);
    print('square index build');

    Color _badgeColor = isDark ? Colours.dark_app_main : Colours.app_main;

    return Scaffold(
      // 设置没有高度的 appbar，目的是为了设置状态栏的颜色
              backgroundColor: isDark ? Color(0xff303233) : Color(0xfff6f7f8),
    appBar: AppBar(
        backgroundColor: Colors.transparent,
//        leading:
//            IconButton(icon: Icon(Icons.close, size: 20), onPressed: () => NavigatorUtils.goBack(context)),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('话题广场'),
        centerTitle: true,
actions: _renderActions(),
//        actions: <Widget>[Icon(Icons.close)],
//        title: Stack(
//          children: <Widget>[
//            Padding(
//              padding: EdgeInsets.symmetric(horizontal: 0),
//              child: TabBar(
//                labelStyle: const TextStyle(fontSize: Dimens.font_sp15),
//                unselectedLabelStyle: TextStyle(fontSize: 14),
//                indicator: UnderlineTabIndicator(),
//                controller: _controller,
//                tabs: [
//                  Tab(
//                    child: Text(
//                      '话 题 广 场',
//                      style: TextStyle(color: isDark ? Colors.white : Colours.dark_bg_color),
//                    ),
//                  ),
//                ],
//              ),
//            ),
////                Positioned(
////                  right: ScreenUtil().setWidth(20),
////                  child: IconButton(
////                    icon: Icon(
////                      Icons.search,
////                      size: ScreenUtil().setWidth(50),
////                      color: Colors.black87,
////                    ),
////                    onPressed: () {},
////                  ),
////                ),
//          ],
//      ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        child: LoadAssetSvg(
          'add',
          width: 25,
          height: 25,
          color: Colors.white,
        ),
        onPressed: () =>
            NavigatorUtils.push(context, SquareRouter.topicCreate, transitionType: TransitionType.fadeIn),
      ),

      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
//            VEmptyView(20),
            Expanded(
              child: TabBarView(
                controller: _controller,
                children: [TopicPageView()],
              ),
            ),
          ],
        ),
      ),
    );
//    return Scaffold(
//        // 设置没有高度的 appbar，目的是为了设置状态栏的颜色
//        appBar: AppBar(
//            title: const Text('广场'),
//            backgroundColor: isDark ? Color(0xff303233) : Color(0xfff7f8f9),
//            leading: IconButton(
//                icon: Icon(Icons.arrow_back, size: 20), onPressed: () => NavigatorUtils.goBack(context)),
//            elevation: 0.5,
//            automaticallyImplyLeading: false,
////            actions: _renderActions(),
//            bottom: TabBar(
////              isScrollable: true,
//                // 去掉下划线
//                indicator: const BoxDecoration(),
//                controller: _controller,
//                unselectedLabelColor: isDark ? Colours.dark_text : Colours.text,
//                indicatorColor: Colours.app_main,
//                labelColor: Color(0xff8968CD),
//                labelStyle: const TextStyle(fontSize: Dimens.font_sp15),
//                unselectedLabelStyle: const TextStyle(fontSize: Dimens.font_sp13),
//                tabs: tabs.map((e) => Tab(child: Text(e))).toList())),
//        floatingActionButton: UnicornDialer(
////          backgroundColor: Colors.black,
//          parentButtonBackground: Color(0xff8968CD),
//          orientation: UnicornOrientation.VERTICAL,
//          parentButton: Icon(Icons.add),
//          childButtons: childButtons,
//        ),
//        body: TabBarView(children: _pageList, controller: _controller));
  }

  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Text _getBadgeText(dynamic content) {
    return Text(
      content.toString(),
      style: TextStyle(fontSize: Dimens.font_sp10, color: Colors.white),
    );
  }

  List<Widget> _renderActions() {
    return [
      FlatButton(
        child: Text('退出',style: MyDefaultTextStyle.getSubTextBodyStyle(isDark)),
        onPressed: ()=>NavigatorUtils.goBack(context)
      )
    ];
  }

  @override
  bool get wantKeepAlive => true;
}
