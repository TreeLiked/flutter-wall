import 'dart:core';

import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/switch_item.dart';

class PrivateSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PrivateSettingPageState();
  }
}

class _PrivateSettingPageState extends State<PrivateSettingPage> {
  bool _displayTwwet = false;
  bool _displayGender = false;
  bool _displayLoc = false;

  Future _getSettingTask;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: '隐私设置',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SwitchItem(
              title: '展示历史推文',
              initBool: _displayTwwet,
              onTap: (val) {
                setState(() {
                  this._displayTwwet = val;
                });
              },
            ),
            SwitchItem(
              title: '展示历史推文',
              initBool: _displayTwwet,
              onTap: (val) {
                setState(() {
                  this._displayTwwet = val;
                });
              },
            ),
            SwitchItem(
              title: '展示历史推文',
              initBool: _displayTwwet,
              onTap: (val) {
                setState(() {
                  this._displayTwwet = val;
                });
              },
            ),
            SwitchItem(
              title: '展示历史推文',
              initBool: _displayTwwet,
              onTap: (val) {
                setState(() {
                  this._displayTwwet = val;
                });
              },
            ),
            SwitchItem(
              title: '展示我的社交联系方式',
              initBool: _displayTwwet,
            ),
            SwitchItem(
              title: '展示我的地区',
              initBool: _displayTwwet,
            ),
          ],
        ),
      ),
    );
  }
}
