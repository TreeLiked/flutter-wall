import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/bottom_bar_navigation_pattern/animated_bottom_bar.dart';
import 'package:iap_app/page/home/home_page.dart';
import 'package:iap_app/page/index/navigation_icon_view.dart';
import 'package:iap_app/page/notification/index.dart';
import 'package:iap_app/page/personal_center/personal_center.dart';
import 'package:iap_app/part/hot_today.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/style/text_style.dart';

class Index extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _IndexState();
}

class _IndexState extends State<Index>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  var _pageList;

  // 当前选中的索引
  int _currentIndex = 0;
  // 底部导航视图
  List<NavigationIconView> _navigationViews;
  // 所有页面
  // 当前页面

  final pageController = PageController();

  bool _showBottomNavBar = true;

  final List<BarItem> barItems = [
    BarItem(
      text: "首页",
      iconData: Icons.home,
    ),
    BarItem(
      text: "热门",
      iconData: Icons.room,
    ),
    BarItem(
      text: "消息",
      iconData: Icons.notifications,
    ),
    BarItem(
      text: "我的",
      iconData: Icons.person,
    ),
  ];

  @override
  void initState() {
    super.initState();
    initPageData();
  }

  void initPageData() {
    _navigationViews = <NavigationIconView>[
      NavigationIconView(
          icon: Icon(Icons.home, size: 20, color: Colors.grey),
          title: Container(
            child: MyDefaultTextStyle.getBottomNavTextItem('首页', Colors.indigo),
          ),
          selColor: Colors.indigo,
          vsync: this),
      NavigationIconView(
          icon: Icon(Icons.room, size: 20, color: Colors.grey),
          selColor: Colors.pinkAccent,
          title: Container(
            child: MyDefaultTextStyle.getBottomNavTextItem(
                '热门', Colors.pinkAccent),
          ),
          vsync: this),
      NavigationIconView(
          icon: Icon(Icons.notifications, size: 20, color: Colors.grey),
          title: Container(
            child: MyDefaultTextStyle.getBottomNavTextItem(
                '消息', Colors.yellow.shade900),
          ),
          selColor: Colors.yellow.shade900,
          vsync: this),
      NavigationIconView(
          icon: Icon(Icons.person, size: 20, color: Colors.grey),
          title: Container(
            child: MyDefaultTextStyle.getBottomNavTextItem('我的', Colors.teal),
          ),
          selColor: Colors.teal,
          vsync: this),
    ];
    // 刷新视图
    // _navigationViews.forEach((v) => {
    //       // v.controller.addListener(_rebuild)
    //     });

    _pageList = <StatefulWidget>[
      HomePage(pullDownCallBack: (_) => updateBottomBar(_)),
      HotToday(),
      NotificationIndexPage(),
      PersonalCenter(),
    ];
  }

  // 是否向下滑动
  void updateBottomBar(bool pullDown) {
    if (pullDown) {
      // 向下滑动，显示
      if (!_showBottomNavBar) {
        setState(() {
          _showBottomNavBar = true;
        });
      }
    } else {
      // 隐藏
      if (_showBottomNavBar) {
        setState(() {
          _showBottomNavBar = false;
        });
      }
    }
  }

  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void pageOnTap(index) {
    pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('index_build');
    if (_navigationViews == null) {
      initPageData();
    }
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);
    final BottomNavigationBar bottomNavigationBar = new BottomNavigationBar(
        elevation: 0,
        // items: itmes,
        items: _navigationViews.map((navIconView) => navIconView.item).toList(),
        currentIndex: _currentIndex,
        backgroundColor: Colors.transparent,
        // selectedIconTheme: IconThemeData(opacity: 0.9),
        // unselectedIconTheme: IconThemeData(opacity: 0.5),
        showUnselectedLabels: false,
        // selectedItemColor: _navigationViews[_currentIndex].selColor,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => pageOnTap(index));

    // return new Scaffold(
    //     body: IndexedStack(index: _currentIndex, children: _pageList),
    //     bottomNavigationBar: bottomNavigationBar);
    return Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: Offstage(
            offstage: !_showBottomNavBar,
            child: AnimatedOpacity(
              opacity: _showBottomNavBar ? 1.0 : 0.0,
              duration: Duration(milliseconds: 700),
              child: PreferredSize(
                  child: bottomNavigationBar,
                  preferredSize: Size.fromHeight(
                      MediaQuery.of(context).size.height * 0.04)),
            )),
        // child: AnimatedOpacity(
        //   opacity: _showBottomNavBar ? 1.0 : 0.0,
        //   duration: Duration(milliseconds: 600),
        //   child: PreferredSize(
        //       child: AnimatedBottomBar(
        //           barItems: barItems,
        //           animationDuration: const Duration(milliseconds: 150),
        //           barStyle: BarStyle(fontSize: 14.0, iconSize: 20.0),
        //           onBarTap: (index) {
        //             // setState(() {
        //             //   _currentIndex = index;
        //             // });
        //             pageOnTap(index);
        //           }),
        //       preferredSize: Size.fromHeight(
        //           MediaQuery.of(context).size.height * 0.04)),
        // )),
        // body: bodyList[currentIndex],
        body: PageView(
          controller: pageController,
          onPageChanged: onPageChanged,
          children: _pageList,
          physics: NeverScrollableScrollPhysics(), // 禁止滑动
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
