import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/index/navigation_icon_view.dart';
import 'package:iap_app/models/tabIconData.dart';
import 'package:iap_app/page/create_page.dart';
import 'package:iap_app/page/home_page.dart';
import 'package:iap_app/page/hot_page.dart';
import 'package:iap_app/part/bottomBarView.dart';
import 'package:iap_app/part/hot_today.dart';

class Index extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _IndexState();
}

class _IndexState extends State<Index> with TickerProviderStateMixin {
  // 当前选中的索引
  int _currentIndex = 0;
  // 底部导航视图
  List<NavigationIconView> _navigationViews;
  // 所有页面
  List<StatefulWidget> _pageList;
  // 当前页面
  StatefulWidget _currentPage;

  final pageController = PageController();

  @override
  void initState() {
    super.initState();
    _navigationViews = <NavigationIconView>[
      NavigationIconView(
          icon: Icon(Icons.home),
          title: Container(
            child: Text('推荐'),
            // height: 0.0,
          ),
          vsync: this),
      NavigationIconView(
          icon: Icon(Icons.room),
          title: Container(
            child: Text('热门'),
          ),
          vsync: this),
      NavigationIconView(
          icon: Icon(Icons.notifications),
          title: Container(
            child: Text('通知'),
          ),
          vsync: this),
      NavigationIconView(
          icon: Icon(Icons.person),
          title: Container(
            child: Text('我的'),
          ),
          vsync: this),
    ];
    // 刷新视图
    // _navigationViews.forEach((v) => {
    //       // v.controller.addListener(_rebuild)
    //     });

    _pageList = <StatefulWidget>[
      new HomePage(),
      new HotToday(),
      // new CreatePage(),
      new CreatePage(),
      new CreatePage(),
    ];

    _currentPage = _pageList[_currentIndex];
  }

  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void pageOnTap(index) {
    pageController.jumpToPage(index);
  }

  void _rebuild() {
    setState(() {});
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: TabIconData.tabIconsList,
          addClick: () {},
          changeIndex: (index) {
            if (index == 0 || index == 2) {
              // animationController.reverse().then((data) {
              //   if (!mounted) return;
              //   setState(() {
              //     tabBody =
              //         MyDiaryScreen(animationController: animationController);
              //   });
              // });
            } else if (index == 1 || index == 3) {
              // animationController.reverse().then((data) {
              //   if (!mounted) return;
              //   setState(() {
              //     tabBody =
              //         TrainingScreen(animationController: animationController);
              //   });
              // });
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);

    final BottomNavigationBar bottomNavigationBar = new BottomNavigationBar(
        backgroundColor: Color(0xffffffff),
        elevation: 0,
        items: _navigationViews.map((navIconView) => navIconView.item).toList(),
        currentIndex: _currentIndex,
        fixedColor: ColorConstant.QQ_BLUE,
        // unselectedItemColor: Colors.black87,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => pageOnTap(index));

    // return new Scaffold(
    //     body: IndexedStack(index: _currentIndex, children: _pageList),
    //     bottomNavigationBar: bottomNavigationBar);
    return Scaffold(
        bottomNavigationBar: bottomNavigationBar,
        // body: bodyList[currentIndex],
        body: PageView(
          controller: pageController,
          onPageChanged: onPageChanged,
          children: _pageList,
          physics: NeverScrollableScrollPhysics(), // 禁止滑动
        ));
  }
}
