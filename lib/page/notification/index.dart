import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/app_bar.dart';

class NotificationIndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    print('NotificationIndexPage create state');
    return _NotificationIndexPageState();
  }
}

class _NotificationIndexPageState extends State<NotificationIndexPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        centerTitle: '消息',
        isBack: false,
      ),
    );
  }
}
