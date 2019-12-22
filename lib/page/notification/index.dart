import 'dart:math';

import 'package:badges/badges.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/text_clickable_iitem.dart';
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

class NotificationIndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    print('NotificationIndexPage create state');
    return _NotificationIndexPageState();
  }
}

class _NotificationIndexPageState extends State<NotificationIndexPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<NotificationIndexPage> {
  TabController _controller;
  int _currentIndex = 0;
  List<String> titleTabs = ['私信', "评论", "点赞", "通知"];

  List<Widget> tabs;

  bool isDark = false;

  @override
  void initState() {
    super.initState();

    _controller = TabController(vsync: this, length: titleTabs.length, initialIndex: _currentIndex)
      ..addListener(() {
        setState(() {
          _currentIndex = _controller.index;
        });
      });

    tabs = [
      Badge(
          badgeColor: Colours.dark_app_main,
          position: BadgePosition.topRight(top: 0),
          animationDuration: Duration(milliseconds: 300),
          animationType: BadgeAnimationType.slide,
          badgeContent: Text(
            "11",
            style: TextStyle(color: Colors.white),
          ),
          child: Tab(text: titleTabs[0])),
      Badge(
          badgeColor: Colours.dark_app_main,
          position: BadgePosition.topRight(top: 0),
          animationDuration: Duration(milliseconds: 300),
          animationType: BadgeAnimationType.slide,
          badgeContent: Text(
            "11",
            style: TextStyle(color: Colors.white),
          ),
          child: Tab(text: titleTabs[1])),
      Badge(
          badgeColor: Colours.dark_app_main,
          position: BadgePosition.topRight(top: 0),
          animationDuration: Duration(milliseconds: 300),
          animationType: BadgeAnimationType.slide,
          badgeContent: Text(
            "11",
            style: TextStyle(color: Colors.white),
          ),
          child: Tab(text: titleTabs[2])),
      Badge(
          badgeColor: Colours.dark_app_main,
          position: BadgePosition.topRight(top: 0),
          animationDuration: Duration(milliseconds: 300),
          animationType: BadgeAnimationType.slide,
          badgeContent: null,
          child: Tab(text: titleTabs[3])),
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    checkAndRequestNotificationPermission();
    isDark = ThemeUtils.isDark(context);
    Color _badgeColor = isDark ? Colours.dark_app_main : Colours.app_main;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('消息'),
        bottom: PreferredSize(
          child: TabBar(
            tabs: [
              Badge(
                  badgeColor: _badgeColor,
                  position: BadgePosition.topRight(top: 0),
                  animationDuration: Duration(milliseconds: 300),
                  animationType: BadgeAnimationType.slide,
                  badgeContent: _getBadgeText(9),
                  child: Tab(text: titleTabs[0])),
              Badge(
                  badgeColor: _badgeColor,
                  position: BadgePosition.topRight(top: 0),
                  animationDuration: Duration(milliseconds: 300),
                  animationType: BadgeAnimationType.slide,
                  badgeContent: _getBadgeText(5),
                  child: Tab(text: titleTabs[1])),
              Badge(
                  badgeColor: _badgeColor,
                  position: BadgePosition.topRight(top: 0),
                  animationDuration: Duration(milliseconds: 300),
                  animationType: BadgeAnimationType.slide,
                  badgeContent: _getBadgeText("99+"),
                  child: Tab(text: titleTabs[2])),
              Badge(
                  badgeColor: _badgeColor,
                  position: BadgePosition.topRight(top: 0),
                  animationDuration: Duration(milliseconds: 300),
                  animationType: BadgeAnimationType.slide,
                  badgeContent: null,
                  child: Tab(text: titleTabs[3])),
            ],
            controller: _controller,
            indicatorColor: Colours.app_main,
            labelColor: Colours.app_main,
            unselectedLabelColor: isDark ? Colours.dark_text : Colours.text,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(fontSize: Dimens.font_sp14),
            unselectedLabelStyle: TextStyle(fontSize: Dimens.font_sp13),
          ),
          preferredSize: Size.fromHeight(38),
        ),
        actions: _renderActions(),
      ),
      body: SafeArea(
        top: false,
        child: TabBarView(controller: _controller, children: [
          PersonalMessagePage(),
          PersonalMessagePage(),
          PersonalMessagePage(),
          SystemNotificationPage(),
        ]),
      ),
    );
  }

  Text _getBadgeText(dynamic content) {
    return Text(
      content.toString(),
      style: TextStyle(fontSize: Dimens.font_sp10, color: Colors.white),
    );
  }

  List<Widget> _renderActions() {
    if (_currentIndex == 0) {
      return [IconButton(icon: Icon(Icons.notifications_none), onPressed: () {})];
    }
    if (_currentIndex == 3) {
      return [
        FlatButton(
            child: Text('全部已读',
                style:
                    TextStyle(fontSize: Dimens.font_sp12, color: isDark ? Colours.dark_text : Colours.text)),
            onPressed: () {})
      ];
    }
    return [];
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
