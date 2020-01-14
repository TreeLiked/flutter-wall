import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/switch_item.dart';

class NotificationSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NotificationSettingPage();
  }
}

class _NotificationSettingPage extends State<NotificationSettingPage> {
  bool enablePushTopic = false;
  bool enablePushTweet = true;
  bool enablePushActivity = true;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: MyAppBar(
        centerTitle: '通知设置',
        actionName: '保存',
        onPressed: () {

        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SwitchItem(
              title: '内容推送',
              initBool: enablePushTweet,
              onTap: (val) {
                setState(() {
                  this.enablePushTweet = val;
                });
              },
            ),
            SwitchItem(
              title: '话题推送',
              initBool: enablePushTopic,
              onTap: (val) {
                setState(() {
                  this.enablePushTopic = val;
                });
              },
            ),
            SwitchItem(
              title: '活动推送',
              initBool: enablePushActivity,
              onTap: (val) {
                setState(() {
                  this.enablePushActivity = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
