import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/click_item.dart';
import 'package:iap_app/component/up_down_item.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/setting_router.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:provider/provider.dart';

class PersonalCenter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PersonCenterState();
  }
}

class PersonCenterState extends State<PersonalCenter>
    with AutomaticKeepAliveClientMixin<PersonalCenter> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    // AccountLocalProvider accountLocalProvider =
    //     Provider.of<AccountLocalProvider>(context);
    return Consumer<AccountLocalProvider>(builder: (_, provider, __) {
      return Scaffold(
        // backgroundColor: Color(0xfffafafa),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
                pinned: false,
                snap: false,
                expandedHeight: ScreenUtil().setHeight(160),
                elevation: 0.5,
                floating: false,
                leading: Icon(Icons.notifications),
                bottom: PreferredSize(
                  // Add this code
                  preferredSize: Size.fromHeight(
                      ScreenUtil().setHeight(160)), // Add this code
                  child: Text(''), // Add this code
                ),
                flexibleSpace: Container(
                  padding:
                      EdgeInsets.only(top: ScreenUtil.statusBarHeight + 10),
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
                        begin: Alignment.topLeft,
                        end: Alignment.bottomCenter,
                        colors: ThemeUtils.isDark(context)
                            ? [
                                Theme.of(context).backgroundColor,
                                Color(0xff363636),
                              ]
                            : [
                                Color(0xffc4c5c7),
                                Color(0xffebebeb),
                              ]),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          padding: const EdgeInsets.only(top: 10),
                          margin: EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          child: Column(
                            children: <Widget>[
                              AccountAvatar(
                                avatarUrl: Application.getAccount.avatarUrl,
                                size: SizeConstant.PERSONAL_CENTER_PROFILE_SIZE,
                                whitePadding: true,
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    top: ScreenUtil().setHeight(20)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Container(
                                        child: MediaQuery.removePadding(
                                      context: context,
                                      child: Text(provider.account.nick,
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500)),
                                    )),
                                  ],
                                ),
                              ),
                              // Container(
                              //   margin: EdgeInsets.only(top: 5),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     crossAxisAlignment: CrossAxisAlignment.center,
                              //     children: <Widget>[
                              //       Text('���京工程学院',
                              //           style: TextStyle(
                              //               fontSize: 17,
                              //               color: Colors.black,
                              //               fontWeight: FontWeight.w400)),
                              //     ],
                              //   ),
                              // )
                            ],
                          )),
                      // Container(
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.end,
                      //     children: <Widget>[
                      //       Container(
                      //         margin: EdgeInsets.only(
                      //             right: 15, top: ScreenUtil().setHeight(20)),
                      //         padding: EdgeInsets.symmetric(
                      //           horizontal: 10,
                      //         ),
                      //         decoration: BoxDecoration(
                      //             gradient: new LinearGradient(
                      //                 begin: Alignment.centerLeft,
                      //                 end: Alignment.centerRight,
                      //                 colors: [
                      //                   Color(0xffe2d1c3),
                      //                   Color(0xfffdfcfb),
                      //                 ]),
                      //             borderRadius: BorderRadius.circular(8)),
                      //         child: Text(
                      //           '高级认证',
                      //           style: TextStyles.textHint14,
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // ),
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
                      // color: Theme.of(context).scaffoldBackgroundColor,
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          UpDownItem(
                              WidgetUtil.getAsset(PathConstant.ICON_ARTICLE,
                                  size: 25),
                              Text('我的发布'),
                              () => NavigatorUtils.push(
                                  context, SettingRouter.historyPushPage)),
                          UpDownItem(
                              WidgetUtil.getAsset(PathConstant.ICON_LOVE_PLUS,
                                  size: 25),
                              Text('我点赞的'),
                              null),
                          UpDownItem(
                              WidgetUtil.getAsset(PathConstant.ICON_STAR,
                                  size: 25),
                              Text('我的收藏'),
                              () => ToastUtil.showToast(context, '收藏功能暂未开放')),
                        ],
                      ),
                    ),
                    Gaps.line,
                    Container(
                      // color: Colors.white,

                      child: Column(
                        children: <Widget>[
                          _getGroupSetting([
                            ClickItem(
                              title: '我的组织',
                              content: Application.getOrgName ??
                                  TextConstant.TEXT_UNCATCH_ERROR,
                              onTap: () {
                                ToastUtil.showToast(context, '组织切换功能暂无开放');
                                // NavigatorUtils.push(
                                //     context,
                                //     SettingRouter.orgChoosePage +
                                //         Utils.packConvertArgs({
                                //           'title': '更换组织',
                                //           'hintText': '点击搜索'
                                //         }));
                              },
                            ),
                            ClickItem(
                              title: '我的身份',
                              content: '普通用户',
                            )
                          ]),
                          _getGroupSetting([
                            ClickItem(
                              title: '我的信息',
                              onTap: () {
                                NavigatorUtils.push(
                                    context, SettingRouter.accountInfoPage);
                              },
                            ),
                            ClickItem(
                              title: '我的订阅',
                              onTap: () {
                                ToastUtil.showToast(context, '订阅功能暂未开放');
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
                            )
                          ]),
                          _getGroupSetting([
                            ClickItem(
                              title: '其他设置',
                              onTap: () {
                                NavigatorUtils.push(
                                    context, SettingRouter.otherSettingPage);
                              },
                            ),
                            ClickItem(
                              title: '关于我们',
                              onTap: () => NavigatorUtils.push(
                                  context, SettingRouter.aboutPage),
                            )
                          ]),
                          _getGroupSetting([]),
                          // _getGroupSetting([
                          //   _getSettingItem(
                          //     ListTile(
                          //       title: Text(
                          //         "退出登录",
                          //         style: TextStyle(color: Colors.redAccent),
                          //       ),
                          //       onTap: () {
                          //         showDialog(
                          //             context: context,
                          //             barrierDismissible: false,
                          //             builder: (_) => ExitDialog());
                          //       },
                          //     ),
                          //   ),
                          // ])
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
    });
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
      margin: EdgeInsets.all(0),
      color: Colors.white,
      // padding: EdgeInsets.only(top: 3),
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: InkWell(
          child: lst,
        ),
      ),
    );
  }

  Widget _getGroupSetting(List<Widget> lsts) {
    return Container(
      // color: Colors.blue,
      margin: EdgeInsets.only(top: 5),
      child: Column(children: lsts),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
