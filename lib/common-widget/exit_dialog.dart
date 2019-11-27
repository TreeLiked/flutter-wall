import 'package:flustars/flustars.dart';
import 'package:flustars/flustars.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/base_dialog.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/fluro_navigator.dart' as prefix1;
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:provider/provider.dart';

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
    AccountLocalProvider accountLocalProvider =
        Provider.of<AccountLocalProvider>(context);
    TweetTypesFilterProvider filterProvider =
        Provider.of<TweetTypesFilterProvider>(context);
    return BaseDialog(
      title: "提示",
      child: const Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: const Text("您确定要退出登录吗？", style: TextStyles.textSize16),
      ),
      onPressed: () async {
        Utils.showDefaultLoading(context);
        Application.setAccount(null);
        Application.setAccountId(null);
        await prefix0.SpUtil.clear();
        prefix1.NavigatorUtils.goBack(context);
        NavigatorUtils.push(context, Routes.loginPage, clearStack: true);
      },
    );
  }
}
