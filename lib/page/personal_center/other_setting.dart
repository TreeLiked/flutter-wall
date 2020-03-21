import 'package:flustars/flustars.dart' as flutter_stars;
import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/click_item.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/setting_router.dart';
import 'package:iap_app/util/toast_util.dart';

/// design/8设置/index.html
class OtherSetting extends StatefulWidget {
  @override
  _OtherSettingState createState() => _OtherSettingState();
}

class _OtherSettingState extends State<OtherSetting> {
  @override
  Widget build(BuildContext context) {
    String theme = flutter_stars.SpUtil.getString(SharedConstant.THEME);
    String themeMode;
    switch (theme) {
      case "Dark":
        themeMode = "开启";
        break;
      case "Light":
        themeMode = "关闭";
        break;
      default:
        themeMode = "跟随系统";
        break;
    }

    return Scaffold(
      appBar: MyAppBar(
        centerTitle: "其他设置",
      ),
      body: Column(
        children: <Widget>[
          Gaps.vGap5,
          ClickItem(
              title: "夜间模式",
              content: themeMode,
              onTap: () {
                NavigatorUtils.push(context, SettingRouter.themePage);
              }),
          ClickItem(
              title: "清除缓存",
              onTap: () {
                imageCache.clear();
                ToastUtil.showToast(context, '清除成功');
              }),
          ClickItem(
              title: "恢复已屏蔽内容",
              onTap: () async {
                await flutter_stars.SpUtil.remove(SharedConstant.MY_UN_LIKED);
                ToastUtil.showToast(context, '恢复成功，请手动刷新');
              })
        ],
      ),
    );
  }

// void _showUpdateDialog() {
//   showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return UpdateDialog();
//       }
//   );
// }
}
