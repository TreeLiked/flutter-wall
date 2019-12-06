import 'dart:core';

import 'package:flutter/material.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/click_item.dart';
import 'package:iap_app/common-widget/dialog/radio_sel_dialog.dart';
import 'package:iap_app/common-widget/radio_item.dart';
import 'package:iap_app/common-widget/simple_confirm.dart';
import 'package:iap_app/component/widget_sliver_future_builder.dart';
import 'package:iap_app/model/account/account_setting.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/toast_util.dart';

class PrivateSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PrivateSettingPageState();
  }
}

class _PrivateSettingPageState extends State<PrivateSettingPage> {
  Function _getSettingTask;

  String _openText = "打开";
  String _closeText = "关闭";

  static const String _TRUE = "TRUE";
  static const String _FALSE = "FALSE";

  List<RadioItem> items = [
    RadioItem(key: _TRUE, value: '打开'),
    RadioItem(key: _FALSE, value: '关闭')
  ];

  @override
  void initState() {
    super.initState();
    _getSettingTask = getData;
  }

  Future<Map<String, dynamic>> getData(BuildContext context) async {
    Map<String, dynamic> settings = await MemberApi.getAccountSetting();
    return settings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          centerTitle: '隐私设置',
          actionName: '说明',
          onPressed: () {
            Utils.displayDialog(
                context,
                SimpleConfirmDialog('隐私设置说明',
                    '您可以选择哪些信息显示在个人的资料页面上，剩余的资料将被严格保密。\n例如您可以选择显示QQ，那么其他用户则可以通过您的个人资料页添加您的QQ'));
          },
        ),
        body: CustomSliverFutureBuilder(
          futureFunc: _getSettingTask,
          builder: (context, data) {
            return _renderItems(data);
          },
        ));
  }

  String _getOpenCloseText(bool b) {
    return b ? _openText : _closeText;
  }

  Widget _renderItems(Map<String, dynamic> settingMap) {
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        ClickItem(
            title: "展示历史推文",
            content: _getOpenCloseText(
                settingMap[AccountSettingKeys.displayHistoryTweet]),
            onTap: () {
              _showRadioDialog(
                  '展示历史推文',
                  settingMap[AccountSettingKeys.displayHistoryTweet]
                      .toString()
                      .toUpperCase(), (k, v) {
                _updateSomething(AccountSettingKeys.displayHistoryTweet, k,
                    (trueCallback) {
                  setState(() {
                    settingMap[AccountSettingKeys.displayHistoryTweet] =
                        (k == _TRUE) ? true : false;
                  });
                });
              });
            }),
        ClickItem(
            title: "显示姓名",
            content:
                _getOpenCloseText(settingMap[AccountSettingKeys.displayName]),
            onTap: () {
              _showRadioDialog(
                  '展示我的姓名',
                  settingMap[AccountSettingKeys.displayName]
                      .toString()
                      .toUpperCase(), (k, v) {
                _updateSomething(AccountSettingKeys.displayName, k,
                    (trueCallback) {
                  setState(() {
                    settingMap[AccountSettingKeys.displayName] =
                        (k == _TRUE) ? true : false;
                  });
                });
              });
            }),
        ClickItem(
            title: "显示性别",
            content:
                _getOpenCloseText(settingMap[AccountSettingKeys.displaySex]),
            onTap: () {
              _showRadioDialog(
                  '展示我的性别',
                  settingMap[AccountSettingKeys.displaySex]
                      .toString()
                      .toUpperCase(), (k, v) {
                _updateSomething(AccountSettingKeys.displaySex, k,
                    (trueCallback) {
                  setState(() {
                    settingMap[AccountSettingKeys.displaySex] =
                        (k == _TRUE) ? true : false;
                  });
                });
              });
            }),
        ClickItem(
            title: "显示年龄",
            content:
                _getOpenCloseText(settingMap[AccountSettingKeys.displayAge]),
            onTap: () {
              _showRadioDialog(
                  '展示我的年龄',
                  settingMap[AccountSettingKeys.displayAge]
                      .toString()
                      .toUpperCase(), (k, v) {
                _updateSomething(AccountSettingKeys.displayAge, k,
                    (trueCallback) {
                  setState(() {
                    settingMap[AccountSettingKeys.displayAge] =
                        (k == _TRUE) ? true : false;
                  });
                });
              });
            }),
        ClickItem(
            title: "展示地区",
            content:
                _getOpenCloseText(settingMap[AccountSettingKeys.displayRegion]),
            onTap: () {
              _showRadioDialog(
                  '展示我的地区',
                  settingMap[AccountSettingKeys.displayRegion]
                      .toString()
                      .toUpperCase(), (k, v) {
                _updateSomething(AccountSettingKeys.displayRegion, k,
                    (trueCallback) {
                  setState(() {
                    settingMap[AccountSettingKeys.displayRegion] =
                        (k == _TRUE) ? true : false;
                  });
                });
              });
            }),
        ClickItem(
            title: "显示手机号 [如果绑定]",
            content:
                _getOpenCloseText(settingMap[AccountSettingKeys.displayPhone]),
            onTap: () {
              _showRadioDialog(
                  '展示我的手机号',
                  settingMap[AccountSettingKeys.displayPhone]
                      .toString()
                      .toUpperCase(), (k, v) {
                _updateSomething(AccountSettingKeys.displayPhone, k,
                    (trueCallback) {
                  setState(() {
                    settingMap[AccountSettingKeys.displayPhone] =
                        (k == _TRUE) ? true : false;
                  });
                });
              });
            }),
        ClickItem(
            title: "显示QQ [如果有]",
            content:
                _getOpenCloseText(settingMap[AccountSettingKeys.displayQQ]),
            onTap: () {
              _showRadioDialog(
                  '展示我的QQ',
                  settingMap[AccountSettingKeys.displayQQ]
                      .toString()
                      .toUpperCase(), (k, v) {
                _updateSomething(AccountSettingKeys.displayQQ, k,
                    (trueCallback) {
                  setState(() {
                    settingMap[AccountSettingKeys.displayQQ] =
                        (k == _TRUE) ? true : false;
                  });
                });
              });
            }),
        ClickItem(
            title: "显示微信 [如果有]",
            content:
                _getOpenCloseText(settingMap[AccountSettingKeys.displayWeChat]),
            onTap: () {
              _showRadioDialog(
                  '展���我的微信',
                  settingMap[AccountSettingKeys.displayWeChat]
                      .toString()
                      .toUpperCase(), (k, v) {
                _updateSomething(AccountSettingKeys.displayWeChat, k,
                    (trueCallback) {
                  setState(() {
                    settingMap[AccountSettingKeys.displayWeChat] =
                        (k == _TRUE) ? true : false;
                  });
                });
              });
            }),
      ],
    ));
  }

  Future<void> _updateSomething(String key, String value, callback) async {
    Utils.showDefaultLoadingWithBonuds(context);
    Result r = await MemberApi.updateAccountSetting(key, value);
    if (r != null && r.isSuccess) {
      callback(true);
    } else {
      ToastUtil.showToast(context, '修改失败，请稍候重试');
    }
    Navigator.pop(context);
  }

  _showRadioDialog(String title, String initItemKey, callback) {
    showElasticDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return RadioSelectDialog(
            initRadioItemKey: initItemKey,
            items: items,
            title: title,
            onPressed: (key, value) {
              callback(key, value);
            },
          );
        });
  }
}
