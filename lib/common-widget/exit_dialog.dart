
import 'package:flustars/flustars.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:iap_app/api/device.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/base_dialog.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/fluro_navigator.dart' as prefix1;
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/http_util.dart';
import 'package:iap_app/util/message_util.dart';

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
      onPressed: () async {
        Utils.showDefaultLoading(context);

        if (Application.getDeviceId != null) {
          DeviceApi.removeDeviceInfo(Application.getAccountId, Application.getDeviceId);
        }
        Application.setLocalAccountToken(null);

        Application.setAccount(null);
        Application.setAccountId(null);
        await prefix0.SpUtil.remove(SharedConstant.LOCAL_ACCOUNT_TOKEN);
        await prefix0.SpUtil.remove(SharedConstant.LOCAL_ACCOUNT_ID);

        await prefix0.SpUtil.remove(SharedConstant.LOCAL_ORG_ID);
        await prefix0.SpUtil.remove(SharedConstant.LOCAL_ORG_NAME);

        await prefix0.SpUtil.remove(SharedConstant.LOCAL_FILTER_TYPES);
        await prefix0.SpUtil.remove(SharedConstant.MY_UN_LIKED);
        await prefix0.SpUtil.clear();
        // MessageUtil.close();

        await MessageUtil.notificationStreamCntCtrl.close();
        httpUtil.clearAuthToken();
        httpUtil2.clearAuthToken();
        prefix1.NavigatorUtils.goBack(context);
        NavigatorUtils.push(context, Routes.loginPage, clearStack: true);
      },
    );
  }
}
