import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/page/home/home_page.dart';
import 'package:iap_app/util/message_util.dart';
import 'package:iap_app/util/page_shared.widget.dart';
import 'package:iap_app/util/version_utils.dart';

class Index extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _IndexState();
}

class _IndexState extends State<Index> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  var _pageList;

  // 当前选中的索引
  int _currentIndex = 0;


  // 所有页面
  // 当前页面

  final pageController = PageController(keepPage: true);

  bool _showBottomNavBar = true;

  final double iconSize = 22.0;

  @override
  void initState() {
    super.initState();
    initPageData();

    checkUpdate();
  }

  @override
  void dispose() {
    MessageUtil.close();
//    _homePageStreamCntCtrl?.close();
    super.dispose();
  }

  void checkUpdate() async {
    VersionUtils.checkUpdate().then((result) {
      if (result != null) {
        VersionUtils.displayUpdateDialog(result, slient: true);
      }
    });
  }

  void initPageData() {
    _pageList = <StatefulWidget>[
      HomePage(pullDownCallBack: (_) => updateBottomBar(_)),
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
    // index 0-3
    if (index == _currentIndex) {
      if (index == 0) {
        PageSharedWidget.homepageScrollController
            .animateTo(.0, duration: Duration(milliseconds: 1688), curve: Curves.easeInOutQuint);
      }
      return;
    }
    pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('index_build');
    ScreenUtil.init(context, width: 1242, height: 2688);

    return Scaffold(
        backgroundColor: Colors.transparent,
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
