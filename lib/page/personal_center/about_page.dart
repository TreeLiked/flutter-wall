import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/click_item.dart';
import 'package:iap_app/common-widget/simple_confirm.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/page/common/report_page.dart';
import 'package:iap_app/res/gaps.dart';
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
  static const double _logoSize = 77.0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);
    bool ios = Platform.isIOS;
    return Scaffold(
      appBar: const MyAppBar(
        title: "关于我们",
      ),
      body: Column(
        children: <Widget>[
          Gaps.vGap30,
          GestureDetector(
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: isDark ? Colors.white12 : Colors.black12, width: 1.0),
                    borderRadius: BorderRadius.circular(10.0)),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LoadAssetImage(
                      'wall_logo',
                      width: _logoSize,
                      height: _logoSize,
                    ))),
            onTap: () => ToastUtil.showToast(context, "Hey ~ Contact and join me"),
          ),

          Gaps.vGap30,
//          ClickItem(
//              title: "Github",
//              content: "请我喝咖啡",
//              onTap: () {
//                NavigatorUtils.goWebViewPage(context, "Wall", "https://gitee.com/treeliked/iap-app");
//              }),
          ClickItem(
            title: "关于我们",
            content: 'iutr.tech'.toUpperCase(),
          ),
          ClickItem(
              title: "使用须知",
              content: '服务协议',
              onTap: () {
                print(Api.API_AGREEMENT);
                NavigatorUtils.goWebViewPage(
                    context, "Wall服务协议", "http://almond-donuts.iutr.tech:8088/terms.html");
              }),
          GestureDetector(
            child: ClickItem(
              title: '检查更新',
              content: 'v${ios ? SharedConstant.VERSION_REMARK_IOS : SharedConstant.VERSION_REMARK_ANDROID}',
              onTap: () async {
                Utils.showDefaultLoadingWithBounds(context);
                VersionUtils.checkUpdate(context: context).then((result) {
                  NavigatorUtils.goBack(context);
                  VersionUtils.displayUpdateDialog(result, context: context);
                });
              },
            ),
            onLongPress: () => ToastUtil.showToast(context, Application.getDeviceId ?? "NULL"),
          ),
          ClickItem(
            title: "问题反馈",
            onTap: () => NavigatorUtils.goReportPage(context, ReportPage.REPORT_SYSTEM, "-1", "系统反馈"),
          ),
          ClickItem(
            title: '联系我们',
            onTap: () async {
              Utils.displayDialog(
                  context,
                  SimpleConfirmDialog(
                    '联系我们',
                    '你可以添加微信号：dlwlrma73或发送邮件到 im.lqs2@icloud.com和我联系',
                  ),
                  barrierDismissible: true);
            },
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
