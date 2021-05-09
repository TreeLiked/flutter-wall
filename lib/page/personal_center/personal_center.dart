
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iap_app/api/invite.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/click_item.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/gender.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/setting_router.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/AccountProfileUtil.dart';
import 'package:iap_app/util/PermissionUtil.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:provider/provider.dart';

class PersonalCenter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PersonCenterState();
  }
}

class PersonCenterState extends State<PersonalCenter> with AutomaticKeepAliveClientMixin<PersonalCenter> {
  bool onInvite = false;

  @override
  void initState() {
    super.initState();
    checkOnInvite();
  }


  @override
  void dispose() {
    super.dispose();
  }

  checkOnInvite() {
    InviteAPI.checkIsInInvitation().then((res) {
      if (res != null && res.isSuccess) {
        setState(() {
          this.onInvite = true;
        });
      }
    });
  }

  void loopColor() {

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<AccountLocalProvider>(builder: (_, provider, __) {
      return Container(
        margin: const EdgeInsets.only(top: 10.0),
        child: Column(
          children: <Widget>[
            Container(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                AccountAvatar(
                    avatarUrl: provider.account.avatarUrl ?? PathConstant.DEFAULT_PROFILE,
                    whitePadding: true,
                    size: 70,
                    gender: provider.account.profile == null
                        ? Gender.UNKNOWN
                        : Gender.parseGender(provider.account.profile.gender),
                    onTap: () async => {
                          if (await PermissionUtil.checkAndRequestPhotos(context))
                            {
                              AccountProfileUtil.cropAndUpdateProfile(provider, context, (Result r) {
                                if (r != null && r.isSuccess) {
                                  setState(() {
                                    provider.account.avatarUrl = r.data;
                                  });
                                } else {
                                  ToastUtil.showToast(context, '上传失败，请稍候重试');
                                }
                              })
                            }
                        }),
                GestureDetector(
                    onTap: () => NavigatorUtils.push(context, SettingRouter.accountInfoPage),
                    child: Container(
                        margin: const EdgeInsets.only(top: 15.0),
                        child: Text(provider.account.nick ?? "",
                            style:
                                const TextStyle(fontSize: Dimens.font_sp18)))),
                GestureDetector(
                    onTap: () => NavigatorUtils.push(context, SettingRouter.accountInfoPage),
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 15.0),
                      child: Text(provider.account.signature ?? "",
                          style: const TextStyle(fontSize: Dimens.font_sp14, color: Color(0xffaeb4bd))),
                    )),
              ],
            )),
            Container(
              child: Column(
                children: <Widget>[
                  _getGroupSetting("组织", [
                    ClickItem(
                      title: '我的大学',
                      content: Application.getOrgName ?? TextConstant.TEXT_UN_CATCH_ERROR,
                    ),
                    ClickItem(
                      title: '我的发布',
                      onTap: () {
                        NavigatorUtils.push(context, SettingRouter.historyPushPage);
                      },
                    ),
                    ClickItem(
                      title: '我的订阅',
                      onTap: () {
                        NavigatorUtils.push(context, SettingRouter.mySubscribePage);
                      },
                    ),
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
                    ),
                    onInvite
                        ? ClickItem(
                            title: '内测',
                            onTap: () => NavigatorUtils.push(context, SettingRouter.invitePage),
                          )
                        : Gaps.empty,
                  ]),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

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
