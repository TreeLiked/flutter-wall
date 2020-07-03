import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/click_item.dart';
import 'package:iap_app/common-widget/update_dialog.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/model/version/pub_v.dart';
import 'package:iap_app/page/common/report_page.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/resources.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/version_utils.dart';
import 'package:iap_app/util/widget_util.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  static const double _logoWidth = 88.0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('about page state build');

    final bool isDark = ThemeUtils.isDark(context);
    bool ios = Platform.isIOS;
    return Scaffold(
      appBar: const MyAppBar(
        title: "关于我们",
      ),
      body: Column(
        children: <Widget>[
          Gaps.vGap50,
//          FlutterLogo(
//            size: 100.0,
//            colors: _colors[Random.secure().nextInt(7)],
//            textColor: _randomColor(),
//            style: _styles[Random.secure().nextInt(3)],
//            curve: _curves[Random.secure().nextInt(12)],
//          ),
          Container(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LoadAssetImage(
                    'wall_logo',
                    width: _logoWidth,
                    height: _logoWidth,
                    color: Colors.amber,
                  ))),

          Gaps.vGap10,
//          ClickItem(
//              title: "Github",
//              content: "请我喝咖啡",
//              onTap: () {
//                NavigatorUtils.goWebViewPage(context, "Wall", "https://gitee.com/treeliked/iap-app");
//              }),
          ClickItem(
            title: "关于我们",
            content: '满月',
          ),
          ClickItem(
              title: "使用须知",
              content: '服务协议',
              onTap: () {
                print(Api.API_AGREEMENT);
                NavigatorUtils.goWebViewPage(
                    context, "Wall服务协议", "http://almond-donuts.iutr.tech:8088/terms.html");
              }),
          ClickItem(
            title: '检查更新',
            content: 'v${ios?SharedConstant.VERSION_REMARK_IOS:SharedConstant.VERSION_REMARK_ANDROID}',
            onTap: () async {
              Utils.showDefaultLoadingWithBounds(context);
              VersionUtils.checkUpdate(context: context).then((result) {
                NavigatorUtils.goBack(context);
                VersionUtils.displayUpdateDialog(result, context: context);
              });
            },
          ),
          ClickItem(
            title: "问题反馈",
            onTap: () => NavigatorUtils.goReportPage(context, ReportPage.REPORT_SYSTEM, "-1", "系统反馈"),
          ),

          ClickItem(
              title: "分享给朋友",
              onTap: () {
                Utils.copyTextToClipBoard(Api.API_SHARE);
                ToastUtil.showToast(context, '分享链接已复制到粘贴板');
                NavigatorUtils.goWebViewPage(context, "分享给朋友", Api.API_SHARE);
              }),
        ],
      ),
    );
  }
}
