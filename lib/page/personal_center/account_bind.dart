import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/click_item.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/account_edit_param.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/routes/setting_router.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:provider/provider.dart';

class AccountBindPage extends StatefulWidget {
  @override
  _AccountBindPageState createState() => _AccountBindPageState();
}

class _AccountBindPageState extends State<AccountBindPage> {
  String _unBindText = "未绑定";

  String _mobile;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchAccountProfile();
  }

  void _fetchAccountProfile() async {
    Account acc = await MemberApi.getAccountProfile(Application.getAccountId);
    print(acc.toJson());
    if (acc != null) {
      setState(() {
        _mobile = acc.profile.mobile;
      });
    } else {
      ToastUtil.showToast(Application.context, '信息加载失败');
      setState(() {
        _mobile = "加载失败";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountLocalProvider>(builder: (_, provider, __) {
      return Scaffold(
        appBar: const MyAppBar(
          centerTitle: "绑定信息",
        ),
        body: Column(
          children: <Widget>[
            ClickItem(
                title: "手机",
                content: _mobile ?? _unBindText,
//                onTap: () {
//                  NavigatorUtils.pushResult(
//                      context,
//                      Routes.inputTextPage +
//                          Utils.packConvertArgs({
//                            'title': '修改手机',
//                            'hintText': provider.account.mobile ?? _unBindText,
//                            'limit': 11,
//                            'kt': 1,
//                          }), (res) {
//                    String content = res.toString();
//                    if (!StringUtil.isEmpty(content)) {
//                      _updateSomething(AccountEditParam(AccountEditKey.MOBILE, content), (success) {
//                        setState(() {
//                          // provider.account.nick = content;
//                        });
//                      });
//                    } else {
//                      ToastUtil.showToast(context, '手机号格式错误');
//                    }
//                  });
//                }
                ),
//            ClickItem(
//              title: 'QQ',
//              content: provider.account.qq ?? _unBindText,
//              onTap: () {
//                NavigatorUtils.pushResult(
//                    context,
//                    Routes.inputTextPage +
//                        Utils.packConvertArgs({
//                          'title': '修改签名',
//                          'hintText': provider.account.signature ?? '',
//                          'limit': 64
//                        }), (res) {
//                  if (!StringUtil.isEmpty(res.toString())) {
//                    _updateSomething(
//                        AccountEditParam(
//                            AccountEditKey.SIGNATURE, res.toString()),
//                        (success) {
//                      setState(() {
//                        provider.account.signature = res.toString();
//                      });
//                    });
//                  }
//                });
//              },
//            ),
//            ClickItem(
//                title: "微信",
//                content: provider.account.weixin ?? _unBindText,
//                onTap: () {
//                  NavigatorUtils.push(
//                      context, SettingRouter.accountPrivateInfoPage);
//                }),
          ],
        ),
      );
    });
  }

  Future<void> _updateSomething(AccountEditParam param, final callback) async {
    Utils.showDefaultLoadingWithBounds(context, text: "正在更新");
    Result r = await MemberApi.modAccount(param);
    if (r != null && r.isSuccess) {
      callback(true);
    } else {
      ToastUtil.showToast(context, '修改失败，请稍候重试');
    }
    Navigator.pop(context);
  }
}
