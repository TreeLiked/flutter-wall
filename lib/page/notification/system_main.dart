import 'dart:io';
import 'dart:ui';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/click_item.dart';
import 'package:iap_app/common-widget/exit_dialog.dart';
import 'package:iap_app/common-widget/simple_confirm.dart';
import 'package:iap_app/common-widget/text_clickable_iitem.dart';
import 'package:iap_app/component/bottom_sheet_choic_item.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account/account_edit_param.dart';
import 'package:iap_app/model/gender.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/page/common/image_crop.dart';
import 'package:iap_app/part/notification/my_sn_card.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/resources.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/routes/setting_router.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/image_utils.dart';
import 'package:iap_app/util/oss_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SystemNotificationMainPage extends StatefulWidget {
  @override
  _SystemNotificationMainPageState createState() => _SystemNotificationMainPageState();
}

class _SystemNotificationMainPageState extends State<SystemNotificationMainPage> {
  bool isDark = false;

  List<SystemCard> sysMsgList;

  @override
  void initState() {
    super.initState();
    this._fetchSystemMessages();
  }

  void _fetchSystemMessages() async {
    Future.delayed(Duration(seconds: 1)).then((val) {
      List<SystemCard> list = List();
      list.add(SystemCard(
        title: '举报提醒',
        content: '您已被举报，请注意',
        isDark: isDark,
        date: DateTime.now(),
      ));
      list.add(SystemCard(
        title: '系统升级提醒',
        content: '最新版本2.0.0已经发布，快来看看吧',
        cover: 'https://tva1.sinaimg.cn/large/006tNbRwgy1gbk9g49bfsj30u01hcnpd.jpg',
        isDark: isDark,
        onClick: () {},
      ));
      setState(() {
        print('-------------------');
        this.sysMsgList = list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
//    _fetchSystemMessages();
    List<SystemCard> list = List();
    list.add(SystemCard(
      title: '举报提醒',
      content: '您又被举报，请充值解锁账户',
      isDark: isDark,
      date: DateTime.now(),
    ));
    list.add(SystemCard(
      title: '举报提醒',
      content: '您已被举报，请注意',
      isDark: isDark,
      date: DateTime.now(),
    ));

    list.add(SystemCard(
      title: '系统升级提醒',
      content: '最新版本2.0.0已经发布，快来看看吧',
      cover: 'https://tva1.sinaimg.cn/large/006tNbRwgy1gbk9g49bfsj30u01hcnpd.jpg',
      isDark: isDark,
      onClick: () {},
      date: DateTime(2020, 1, 28, 11, 39, 10),
    ));
    list.add(SystemCard(
      title: '系统推荐提醒',
      content: '最新IU已经发布，快来看看吧',
      cover: 'https://tva1.sinaimg.cn/large/006tNbRwgy1gbjc0u844qj30u011hadd.jpg',
      isDark: isDark,
      onClick: () {},
      date: DateTime(2019, 1, 28, 11, 39, 10),
    ));
    this.sysMsgList = list;

    isDark = ThemeUtils.isDark(context);
    return Scaffold(
//        backgroundColor: isDark ? Colours.dark_bg_color : Colours.bg_color,
        appBar: const MyAppBar(
          centerTitle: "系统消息",
          isBack: true,
        ),
        body: sysMsgList != null && sysMsgList.length > 0
            ? SingleChildScrollView(
                child: Column(children: sysMsgList),
              )
            : Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.only(top: 50),
                child: sysMsgList == null ? CupertinoActivityIndicator() : Text('暂无消息'),
              ));
  }
}

class SystemCard extends StatelessWidget {
  final String title;
  final String cover;
  final String content;
  final String jumpUrl;
  final Function onClick;
  final DateTime date;


  final bool isDark;

  SystemCard(
      {this.title, this.cover, this.content, this.jumpUrl, this.onClick, this.isDark = false, this.date});

  @override
  Widget build(BuildContext context) {
    return MyShadowCard(
        onClick: onClick,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _dateTimeContainer(context),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Text(
                    title ?? "系统通知",
                    style: MyDefaultTextStyle.getMainTextBodyStyle(isDark),
                  )),
                  onClick != null
                      ? Container(
                          margin: const EdgeInsets.only(right: 4.0),
                          height: 8.0,
                          width: 8.0,
                          decoration: BoxDecoration(
                            color: Colours.app_main,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        )
                      : Gaps.empty,
                  onClick != null ? Images.arrowRight : Gaps.empty
                ],
              ),
              Gaps.vGap8,
              Gaps.line,
              cover != null
                  ? Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: 180,
                      ),
                      child: ClipRRect(
                        child: FadeInImage(
                          placeholder: ImageUtils.getImageProvider('https://via.placeholder.com/180'),
                          image: NetworkImage(cover),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: const BorderRadius.all(const Radius.circular(10)),
                      ),
                    )
                  : Gaps.empty,
              Gaps.vGap8,
              Text(content ?? '', style: MyDefaultTextStyle.getSubTextBodyStyle(isDark)),
            ],
          ),
        ));
  }

  _dateTimeContainer(context) {
    return date != null
        ? Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.only(bottom: 10),
            child: Text(TimeUtil.getShortTime(date), style: MyDefaultTextStyle.getTweetTimeStyle(context)),
          )
        : Gaps.empty;
  }
}
