import 'dart:math';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/text_clickable_iitem.dart';
import 'package:iap_app/common-widget/v_empty_view.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/page/notification/pm_page.dart';
import 'package:iap_app/page/notification/sn.page.dart';
import 'package:iap_app/provider/theme_provider.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';
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
  TabController _controller;
  int _currentIndex = 0;
  List<String> titleTabs = ['私信', "评论", "点赞", "通知"];

  List<String> tabs;

  bool isDark = false;

  var childButtons = List<UnicornButton>();

  @override
  void initState() {
    super.initState();

    _controller = TabController(vsync: this, length: 2, initialIndex: _currentIndex)
      ..addListener(() {
        if (!this.mounted) {
          return;
        }
        setState(() {
          _currentIndex = _controller.index;
        });
      });

    tabs = ['话题', '活动'];

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "发布话题",
        currentButton: FloatingActionButton(
          heroTag: "train",
          backgroundColor: Colors.redAccent,
          mini: true,
          child: Icon(Icons.train),
          onPressed: () {},
        )));

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: '发布',
        currentButton: FloatingActionButton(
            heroTag: "airplane",
            backgroundColor: Colors.greenAccent,
            mini: true,
            child: Icon(Icons.add_circle))));

    childButtons.add(UnicornButton(
        currentButton: FloatingActionButton(
            onPressed: () {
              NavigatorUtils.goBack(context);
            },
            heroTag: "directions",
            backgroundColor: Colors.white,
            mini: true,
            child: Icon(Icons.fullscreen_exit, color: Colors.grey))));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    isDark = ThemeUtils.isDark(context);
    print('square index build');

    Color _badgeColor = isDark ? Colours.dark_app_main : Colours.app_main;

    return Scaffold(
        // 设置没有高度的 appbar，目的是为了设置状态栏的颜色
        appBar: AppBar(
            title: Text('广场'),
            elevation: .5,
            automaticallyImplyLeading: false,
//            actions: _renderActions(),
            bottom: TabBar(
//              isScrollable: true,
                // 去掉下划线
                indicator: const BoxDecoration(),
                controller: _controller,
                unselectedLabelColor: isDark ? Colours.dark_text : Colours.text,
                indicatorColor: Colours.app_main,
                labelColor: Colours.app_main,
                labelStyle: TextStyle(fontSize: Dimens.font_sp15),
                unselectedLabelStyle: TextStyle(fontSize: Dimens.font_sp13),
                tabs: tabs.map((e) => Tab(child: Text(e))).toList())),
        floatingActionButton: UnicornDialer(
//          backgroundColor: Colors.black,
          parentButtonBackground: Colors.lightBlue,
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(Icons.add),
          childButtons: childButtons,
        ),
        body: TabBarView(
            controller: _controller, children: [SystemNotificationPage(), SystemNotificationPage()]));
  }

  Text _getBadgeText(dynamic content) {
    return Text(
      content.toString(),
      style: TextStyle(fontSize: Dimens.font_sp10, color: Colors.white),
    );
  }

  List<Widget> _renderActions() {
    return [FlatButton(child: Text('返回'), onPressed: () => NavigatorUtils.goBack(context))];
  }

  void checkAndRequestNotificationPermission() async {
    PermissionStatus permission =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.notification);

    if (permission != PermissionStatus.granted) {
//      Map<PermissionGroup, PermissionStatus> permissions =
      await PermissionHandler().requestPermissions([PermissionGroup.notification]);
      permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.notification);
      if (permission != PermissionStatus.granted) {
        int random = Random().nextInt(100);
        if (random == 79) {
          print(random);
          Utils.showSimpleConfirmDialog(
              context,
              '无法发送通知',
              '你未开启"允许Wall发送通知"选项，将收不到包括用户私信，点赞评论等的通知',
              ClickableText('知道了', () {
                NavigatorUtils.goBack(context);
              }),
              ClickableText('去设置', () async {
                await PermissionHandler().openAppSettings();
              }),
              barrierDismissible: false);
        }
      }
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
