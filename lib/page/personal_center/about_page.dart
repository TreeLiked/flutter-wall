import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/click_item.dart';
import 'package:iap_app/common-widget/update_dialog.dart';
import 'package:iap_app/page/common/report_page.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/resources.dart';
import 'package:iap_app/routes/fluro_navigator.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('about page state build');

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
                  child: FadeInImage.assetNetwork(
                      placeholder: 'images/avatar.png',
                      image: 'https://tva1.sinaimg.cn/large/006tNbRwgy1gbk9g49bfsj30u01hcnpd.jpg',
                      fit: BoxFit.fitWidth,
                      width: 100,
                      height: 100))),

          Gaps.vGap10,
          ClickItem(
              title: "Github",
              content: "请我喝咖啡",
              onTap: () {
                NavigatorUtils.goWebViewPage(context, "Wall", "https://gitee.com/treeliked/iap-app");
              }),
          ClickItem(
              title: "作者",
              content: 'iutr.tech',
              onTap: () {
                NavigatorUtils.goWebViewPage(context, "作者Git", "https://gitee.com/treeliked");
              }),

          ClickItem(
            title: '检查更新',
            content: '1.0.0 Beta',
            onTap: () {
              _showUpdateDialog();
            },
          ),
          ClickItem(
            title: "问题反馈",
            onTap: () => NavigatorUtils.goReportPage(context, ReportPage.REPORT_SYSTEM, "-1"),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return UpdateDialog();
        });
  }
}
