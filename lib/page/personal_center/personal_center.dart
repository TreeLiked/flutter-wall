import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/click_item.dart';
import 'package:iap_app/common-widget/exit_dialog.dart';
import 'package:iap_app/common-widget/switch_item.dart';
import 'package:iap_app/common-widget/update_dialog.dart';
import 'package:iap_app/component/up_down_item.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/routes/setting_router.dart';
import 'package:iap_app/util/fluro_convert_utils.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/widget_util.dart';

class PersonalCenter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PersonCenterState();
  }
}

class PersonCenterState extends State<PersonalCenter>
    with AutomaticKeepAliveClientMixin {
  String _accSig = "不是所有的存在，都留下看得见的痕迹";
  @override
  Widget build(BuildContext context) {
    super.build(context);

    // showOverlayProfile(context);

    return new Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
              pinned: false,
              snap: false,
              expandedHeight: ScreenUtil().setHeight(200),
              elevation: 0.5,
              floating: false,
              leading: Icon(Icons.notifications),
              bottom: PreferredSize(
                // Add this code
                preferredSize: Size.fromHeight(
                    ScreenUtil().setHeight(200)), // Add this code
                child: Text(''), // Add this code
              ),
              flexibleSpace: Container(
                padding: EdgeInsets.only(top: ScreenUtil.statusBarHeight + 10),
                // margin: EdgeInsets.only(bottom: 40),
                decoration: BoxDecoration(
                  // color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  // boxShadow: [
                  //   BoxShadow(
                  //       color: Colors.white,
                  //       blurRadius: 10.0,
                  //       spreadRadius: 5.0),
                  // ],
                  gradient: new LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: ThemeUtils.isDark(context)
                          ? [
                              Color(0xff363636),
                              Theme.of(context).backgroundColor
                            ]
                          : [
                              Color(0xfffdfcfb),
                              Color(0xffe2d1c3),
                            ]),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        padding: const EdgeInsets.only(top: 50),
                        margin: EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        // width: double.infinity,
                        // height: 160,
                        decoration: BoxDecoration(
                            // color: Colors.white,
                            // borderRadius: BorderRadius.all(Radius.circular(5)),
                            // boxShadow: [
                            //   BoxShadow(
                            //       color: Colors.white10,
                            //       blurRadius: 1.0,
                            //       spreadRadius: 1.0)
                            // ],
                            // border: Border.all(width: 0.5, color: Colors.white),
                            ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 2, color: Colors.white),
                                borderRadius:
                                    BorderRadius.all((Radius.circular(50))),
                              ),
                              child: ClipOval(
                                  child: CachedNetworkImage(
                                imageUrl: Application.getAccount.avatarUrl,
                                width:
                                    SizeConstant.PERSONAL_CENTER_PROFILE_SIZE,
                                height:
                                    SizeConstant.PERSONAL_CENTER_PROFILE_SIZE,
                                fit: BoxFit.cover,
                              )),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text('长安归故里',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500)),
                                  Container(
                                    margin: EdgeInsets.only(left: 10),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 0),
                                    decoration: BoxDecoration(
                                        color: Colors.yellowAccent,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5),
                                          bottomLeft: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                        )),
                                    child: Text('高级认证'),
                                  )
                                ],
                              ),
                            ),
                            // Container(
                            //   margin: EdgeInsets.only(top: 5),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.start,
                            //     crossAxisAlignment: CrossAxisAlignment.center,
                            //     children: <Widget>[
                            //       Text('南京工程学院',
                            //           style: TextStyle(
                            //               fontSize: 17,
                            //               color: Colors.black,
                            //               fontWeight: FontWeight.w400)),
                            //     ],
                            //   ),
                            // )
                          ],
                        )),
                  ],
                ),
                // title: Text('Demo'),
                // collapseMode: CollapseMode.pin,
              )),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(top: 5),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        UpDownItem(
                            WidgetUtil.getAsset(PathConstant.ICON_ARTICLE,
                                size: 25),
                            Text('我的发布'),
                            null),
                        UpDownItem(
                            WidgetUtil.getAsset(PathConstant.ICON_LOVE_PLUS,
                                size: 25),
                            Text('我点赞的'),
                            null),
                        UpDownItem(
                            WidgetUtil.getAsset(PathConstant.ICON_STAR,
                                size: 25),
                            Text('我的收藏'),
                            () => Fluttertoast.showToast(
                                msg: '收藏功能暂未开放',
                                gravity: ToastGravity.CENTER,
                                backgroundColor: Colors.black54)),
                      ],
                    ),
                  ),
                  Container(
                    // color: Colors.white,

                    child: Column(
                      children: <Widget>[
                        _getGroupSetting([
                          ClickItem(
                            title: '我的组织',
                            content: '南京工程学院',
                            onTap: () {},
                          ),
                          ClickItem(
                            title: '我的身份',
                            content: '普通用户',
                          )
                        ]),
                        _getGroupSetting([
                          ClickItem(
                            title: '我的签名',
                            maxLines: 2,
                            content: _accSig,
                            onTap: () {
                              NavigatorUtils.pushResult(
                                  context,
                                  Routes.inputTextPage +
                                      "?title=" +
                                      FluroConvertUtils.fluroCnParamsEncode(
                                          '修改签名') +
                                      "&hintText=" +
                                      FluroConvertUtils.fluroCnParamsEncode(
                                          _accSig), (res) {
                                setState(() {
                                  this._accSig = res;
                                });
                              });
                            },
                          ),
                        ]),
                        _getGroupSetting([
                          ClickItem(
                            title: '隐私设置',
                            onTap: () {
                              NavigatorUtils.push(
                                  context, SettingRouter.privateSettingPage);
                            },
                          ),
                          ClickItem(
                            title: '其他设置',
                            onTap: () {
                              NavigatorUtils.push(
                                  context, SettingRouter.otherSettingPage);
                            },
                          )
                        ]),
                        _getGroupSetting([
                          ClickItem(
                            title: '绑定手机号',
                            content: '17601508663',
                            onTap: () {},
                          )
                        ]),
                        _getGroupSetting([
                          ClickItem(
                            title: '检查更新',
                            onTap: () {
                              _showUpdateDialog();
                            },
                          ),
                          ClickItem(
                            title: '关于我们',
                            onTap: () => NavigatorUtils.push(
                                context, SettingRouter.aboutPage),
                          )
                        ]),
                        _getGroupSetting([
                          _getSettingItem(
                            ListTile(
                              title: Text(
                                "注销登录",
                                style: TextStyle(color: Colors.redAccent),
                              ),
                              onTap: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => ExitDialog());
                              },
                            ),
                          ),
                        ])
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // void showOverlayProfile(BuildContext context) {
  //   Future.delayed(Duration(milliseconds: 200)).then((val) {
  //     OverlayState overlayState = Overlay.of(context);
  //     OverlayEntry entry = new OverlayEntry(builder: (context) {
  //       return Positioned(
  //         top: ScreenUtil.statusBarHeight + 15,
  //         left: (ScreenUtil.screenWidthDp -
  //                 SizeConstant.PERSONAL_CENTER_PROFILE_SIZE) /
  //             2,
  //         child: Container(
  //           decoration: BoxDecoration(
  //             border: Border.all(width: 2, color: Colors.white),
  //             borderRadius: BorderRadius.all((Radius.circular(50))),
  //           ),
  //           child: ClipOval(
  //             child: Image.network(
  //               "https://tva1.sinaimg.cn/large/006y8mN6ly1g8oaz0rsjrj30u011ijvq.jpg",
  //               width: SizeConstant.PERSONAL_CENTER_PROFILE_SIZE,
  //               height: SizeConstant.PERSONAL_CENTER_PROFILE_SIZE,
  //               fit: BoxFit.cover,
  //             ),
  //           ),
  //         ),
  //       );
  //     });
  //     overlayState.insert(entry);
  //   });
  // }

  Widget _getSettingItem(ListTile lst) {
    return Container(
      margin: EdgeInsets.only(top: 3),
      child: Material(
        child: InkWell(
          child: lst,
        ),
      ),
    );
  }

  Widget _getGroupSetting(List<Widget> lsts) {
    return Container(
      margin: EdgeInsets.only(top: 6),
      child: Column(children: lsts),
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

  @override
  bool get wantKeepAlive => true;
}

class PrivateSetting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PrivateSettingState();
  }
}

class PrivateSettingState extends State<PrivateSetting> {
  bool _displayTwwet = false;
  bool _displayGender;
  bool _displayLoc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: '隐私设置',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SwitchItem(
              title: '展示历史推文',
              initBool: _displayTwwet,
              onTap: (val) {
                setState(() {
                  this._displayTwwet = val;
                });
              },
            ),
            SwitchItem(
              title: '展示我的社交联系方式',
              initBool: _displayTwwet,
            ),
            SwitchItem(
              title: '展示我的地区',
              initBool: _displayTwwet,
            ),
          ],
        ),
      ),
    );
  }
}
