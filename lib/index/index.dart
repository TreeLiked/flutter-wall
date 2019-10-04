import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/index/navigation_icon_view.dart';
import 'package:iap_app/page/create_page.dart';
import 'package:iap_app/page/home_page.dart';

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

  @override
  void initState() {
    super.initState();
    _navigationViews = <NavigationIconView>[
      NavigationIconView(
          icon: Icon(Icons.navigation), title: Text('首页'), vsync: this),
      NavigationIconView(
          icon: Icon(Icons.hdr_weak), title: Text('热门'), vsync: this),
      NavigationIconView(icon: Icon(Icons.add), title: Text('创建'), vsync: this),
      NavigationIconView(
          icon: Icon(Icons.all_inclusive), title: Text('消息'), vsync: this),
      NavigationIconView(
          icon: Icon(Icons.perm_identity), title: Text('我的'), vsync: this),
    ];
    // 刷新视图
    _navigationViews.forEach((v) => {
          // v.controller.addListener(_rebuild)
        });

    _pageList = <StatefulWidget>[
      new HomePage(),
      new CreatePage(),
      new CreatePage(),
      new CreatePage(),
      new CreatePage(),
    ];

    _currentPage = _pageList[_currentIndex];
  }

  void _rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final BottomNavigationBar bottomNavigationBar = new BottomNavigationBar(
      items: _navigationViews.map((navIconView) => navIconView.item).toList(),
      currentIndex: _currentIndex,
      fixedColor: Colors.blue,
      type: BottomNavigationBarType.fixed,
      onTap: (int index) {
        setState(() {
          _navigationViews[_currentIndex].controller.reverse();
          _currentIndex = index;
          _navigationViews[_currentIndex].controller.forward();
          _currentPage = _pageList[_currentIndex];
        });
      },
    );

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pageList,
        ),
        bottomNavigationBar: bottomNavigationBar,
      ),
      theme: GlobalConfig.td,
    );
  }
}
