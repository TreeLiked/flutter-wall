import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/base_dialog.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';

class ExitDialog extends StatefulWidget {
  ExitDialog({
    Key key,
  }) : super(key: key);

  @override
  _ExitDialog createState() => _ExitDialog();
}

class _ExitDialog extends State<ExitDialog> {
  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: "提示",
      child: const Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: const Text("您确定要退出登录吗？", style: TextStyles.textSize16),
      ),
      onPressed: () {
        Application.setAccount(null);
        Application.setAccountId("");
        SpUtil.putString(SharedConstant.LOCAL_ACCOUNT_TOKEN, '');
        NavigatorUtils.push(context, Routes.loginPage, clearStack: true);
      },
    );
  }
}
