import 'package:fluro/fluro.dart';
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
import 'package:iap_app/page/common/avatar_origin.dart';
import 'package:iap_app/page/common/tweet_type_select.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/setting_router.dart';
import 'package:iap_app/style/text_style.dart';
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

class PersonCenterState extends State<PersonalCenter> with AutomaticKeepAliveClientMixin<PersonalCenter> {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<AccountLocalProvider>(builder: (_, provider, __) {
      return Scaffold(
        // backgroundColor: Color(0xfffafafa),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
                pinned: false,
                snap: false,
                expandedHeight: ScreenUtil().setHeight(180),
                elevation: 0.5,
                floating: false,
                bottom: PreferredSize(
                  // Add this code
                  preferredSize: Size.fromHeight(ScreenUtil().setHeight(180)), // Add this code
                  child: Text(''), // Add this code
                ),
                flexibleSpace: Container(
                  padding: EdgeInsets.only(top: ScreenUtil.statusBarHeight + 10),
                  // margin: EdgeInsets.only(bottom: 40),
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                    gradient: new LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomCenter,
                        colors: ThemeUtils.isDark(context)
                            ? [
                                Theme.of(context).backgroundColor,
                                Color(0xff363636),
                              ]
                            : [
//                                Color(0xffc4c5c7),
//                                Color(0xffebebeb),
//                                Color(0xfffeada6),
                                Color(0xffeef1f5),
//                                Color(0xffe6e9f0),
                                Color(0xfff5efef),
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
                              Hero(
                                tag: "avatar",
                                child: AccountAvatar(
                                  avatarUrl: Application.getAccount.avatarUrl,
                                  size: SizeConstant.PERSONAL_CENTER_PROFILE_SIZE,
                                  whitePadding: true,
                                  onTap: () {
                                    Navigator.push(context, PageRouteBuilder(pageBuilder:
                                        (BuildContext context, Animation animation,
                                            Animation secondaryAnimation) {
                                      return new FadeTransition(
                                        opacity: animation,
                                        child: AvatarOriginPage(Application.getAccount.avatarUrl),
                                      );
                                    }));
                                  },
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
                                child: Text(provider.account.nick,
                                    softWrap: true,
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
                                child: Text(provider.account.signature,
                                    softWrap: true,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey)),
                              ),
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
//                    Container(
//                      // color: Theme.of(context).scaffoldBackgroundColor,
//                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
//                      child: Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceAround,
//                        children: <Widget>[
//                          UpDownItem(const LoadAssetIcon(PathConstant.ICON_ARTICLE, width: 25, height: 25),
//                              Text('发布'), () => NavigatorUtils.push(context, SettingRouter.historyPushPage)),
//                          UpDownItem(const LoadAssetIcon(PathConstant.ICON_LOVE_PLUS, width: 25, height: 25),
//                              Text('点赞'), () {}),
//                          UpDownItem(const LoadAssetIcon(PathConstant.ICON_STAR, width: 25, height: 25),
//                              Text('收藏'), () => ToastUtil.showToast(context, '收藏功能暂未开放')),
//                        ],
//                      ),
//                    ),
                    Container(
                      // color: Colors.white,

                      child: Column(
                        children: <Widget>[
                          _getGroupSetting("组织", [
                            ClickItem(
                              title: '我的组织',
                              content: Application.getOrgName ?? TextConstant.TEXT_UN_CATCH_ERROR,
                              onTap: () {
                                ToastUtil.showToast(context, '组织切换功能暂未开放');
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
                            ),
                            ClickItem(
                              title: '我的发布',
                              onTap: () {
                                NavigatorUtils.push(context, SettingRouter.historyPushPage);
                              },
                            )
                          ]),
//                          _getGroupSetting("账户", [
////                            ClickItem(
////                              title: '我的订阅',
////                              onTap: () {
//////                                ToastUtil.showToast(context, '订阅功能暂未开放');
////                                Navigator.push(
////                                    context,
////                                    MaterialPageRoute(
////                                        builder: (context) => TweetTypeSelectPage(
////                                              title: "订阅内容类型",
////                                              subTitle: '我的订阅',
////                                              filter: false,
////                                              subScribe: true,
////                                              initFirst: [],
////                                              callback: (resultNames) async {
////                                                print("callbacl result names");
////                                                print(resultNames);
////                                              },
////
////                                              // callback: (_) {
////                                              //   // _refreshController.requestRefresh();
////                                              //   _esRefreshController.resetLoadState();
////                                              //   _esRefreshController.callRefresh();
////                                              // },
////                                            )));
////                              },
////                            ),
//                          ]),

                          _getGroupSetting("设置", [
                            ClickItem(
                              title: '个人资料',
                              onTap: () {
                                NavigatorUtils.push(context, SettingRouter.accountInfoPage);
                              },
                            ),
                            ClickItem(
                              title: '隐私设置',
                              onTap: () {
                                NavigatorUtils.push(context, SettingRouter.privateSettingPage);
                              },
                            ),

                            ClickItem(
                              title: '其他设置',
                              onTap: () {
                                NavigatorUtils.push(context, SettingRouter.otherSettingPage);
                              },
                            ),
                          ]),
                          _getGroupSetting("其它", [
                            ClickItem(
                              title: '关于我们',
                              onTap: () => NavigatorUtils.push(context, SettingRouter.aboutPage),
                            )
                          ]),
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

  Widget _getGroupSetting(String title, List<Widget> widgets) {
    return Container(
        // color: Colors.blue,1
        margin: EdgeInsets.only(top: 5, left: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 15),
              child: Text(
                '$title',
                style: MyDefaultTextStyle.getTweetTimeStyle(context),
              ),
            ),
            Column(children: widgets),
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
