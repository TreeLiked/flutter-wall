import 'dart:async';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as prefix0;
import 'package:iap_app/api/member.dart';
import 'package:iap_app/api/univer.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/model/university.dart';
import 'package:iap_app/page/index/index.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/theme_provider.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/image_utils.dart';
import 'package:iap_app/util/log_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int _status = 0;
  // List<String> _guideList = ["app_start_1", "app_start_2", "app_start_3"];
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Log.init();
      await SpUtil.getInstance();
      // 由于SpUtil未初始化，所以MaterialApp获取的为默认主题配置，这里同步一下。
      Provider.of<ThemeProvider>(context).syncTheme();
      // if (SpUtil.getBool(Constant.keyGuide, defValue: true)){
      //   /// 预先缓存图片，避免直接使用时因为首次加载造成闪动
      //   _guideList.forEach((image){
      //     precacheImage(ImageUtils.getAssetImage(image), context);
      //   });
      // }
      _initSplash();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _initSplash() {
    _subscription = Observable.just(1)
        .delay(Duration(milliseconds: 1500))
        .listen((_) async {
      String storageToken =
          SpUtil.getString(SharedConstant.LOCAL_ACCOUNT_TOKEN, defValue: '');
      print(storageToken);
      if (storageToken == '') {
        _goLogin();
      } else {
        await MemberApi.getMyAccount(storageToken).then((acc) async {
          if (acc == null) {
            _goLogin();
          } else {
            AccountLocalProvider accountLocalProvider =
                Provider.of<AccountLocalProvider>(context);
            accountLocalProvider.setAccount(acc);
            Application.setAccount(acc);
            Application.setAccountId(acc.id);

            int orgId =
                SpUtil.getInt(SharedConstant.LOCAL_ORG_ID, defValue: -1);
            String orgName =
                SpUtil.getString(SharedConstant.LOCAL_ORG_NAME, defValue: "");
            if (orgId == -1 || orgName == "") {
              University university =
                  await UniversityApi.queryUnis(storageToken);
              if (university == null) {
                // 错误，有账户无组织
                print("ERROR , ------------");
                ToastUtil.showToast(context, '数据错误');
              } else {
                if (university == null ||
                    university.id == null ||
                    university.name == null) {
                  ToastUtil.showToast(context, '数据错误');
                  return;
                }
                await SpUtil.putInt(SharedConstant.LOCAL_ORG_ID, university.id);
                await SpUtil.putString(
                    SharedConstant.LOCAL_ORG_NAME, university.name);
                Application.setOrgName(university.name);
                Application.setOrgId(university.id);
              }
            } else {
              print('$orgId---------------------orgId');
              print('$orgName---------------------orgName');

              Application.setOrgId(orgId);
              Application.setOrgName(orgName);
            }
            setState(() {
              _status = 1;
            });
            _loadStorageTweetTypes();
          }
        });
      }
    });
  }

  Future<void> _loadStorageTweetTypes() async {
    TweetTypesFilterProvider tweetTypesFilterProvider =
        Provider.of<TweetTypesFilterProvider>(context);
    tweetTypesFilterProvider.updateTypeNames();
  }

  _goLogin() {
    NavigatorUtils.push(context, Routes.loginPage, replace: true);
  }

  @override
  Widget build(BuildContext context) {
    prefix0.ScreenUtil.instance = prefix0.ScreenUtil(width: 750, height: 1334)
      ..init(context);
    Application.screenWidth = prefix0.ScreenUtil.screenWidthDp;
    Application.screenHeight = prefix0.ScreenUtil.screenHeightDp;

    return Material(
        child: _status == 0
            ? Image.asset(
                ImageUtils.getImgPath("start_page", format: "jpg"),
                width: double.infinity,
                fit: BoxFit.fill,
                height: double.infinity,
              )
            : Index());
  }
}
