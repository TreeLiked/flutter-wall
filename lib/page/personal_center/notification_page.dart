import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/click_item.dart';

class NotificationSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NotificationSettingPage();
  }
}

class _NotificationSettingPage extends State<NotificationSettingPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: MyAppBar(
        centerTitle: '通知设置',
        actionName: '保存',
        onPressed: () {},
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ClickItem(title: '1',),
            ClickItem(title: '1',),
            ClickItem(title: '1',),
          ],
        ),
      ),
    );
  }
}
