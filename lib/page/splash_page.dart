import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as prefix0;
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:iap_app/api/common.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/api/univer.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/model/university.dart';
import 'package:iap_app/page/index/index.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/theme_provider.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/account_device_util.dart';
import 'package:iap_app/util/http_util.dart';
import 'package:iap_app/util/log_utils.dart';
import 'package:iap_app/util/shared.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/umeng_util.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int _status = 0;
  bool _hasAd = false;
  bool _displayAd = false;
  int _adLeftTime = 0;
  int _addTotalTime = 0;
  StreamSubscription _adLeftTimeSub;

  static const String TAG = "SplashPage";

  bool _hasGuide = false;
  bool _displayGuide = false;
  Map<String, dynamic> _adValueMap;

  int _currentGuideIndex = 0;
  static String version = Platform.isIOS
      ? SharedConstant.VERSION_REMARK_IOS.substring(0, SharedConstant.VERSION_REMARK_IOS.lastIndexOf("."))
      : SharedConstant.VERSION_REMARK_ANDROID
          .substring(0, SharedConstant.VERSION_REMARK_IOS.lastIndexOf("."));

  // List<String> _guideList = ["app_start_1", "app_start_2", "app_start_3"];
  StreamSubscription _subscription;

  // 默认该版本的引导页面数目
  int _guideLen = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ignore: invalid_use_of_visible_for_testing_member
      // await Log.init();
      await SpUtil.getInstance();
      // LogUtil.init();
      // 由于SpUtil未初始化，所以MaterialApp获取的为默认主题配置，这里同步一下。
      Provider.of<ThemeProvider>(context, listen: false).syncTheme();
      // if (SpUtil.getBool(Constant.keyGuide, defValue: true)){
      //   /// 预先缓存图片，避免直接使用时因为首次加载造成闪动
      //   _guideList.forEach((image){
      //     precacheImage(ImageUtils.getAssetImage(image), context);
      //   });
      // }
      _checkGuideNeed();
      _initSplash();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _adLeftTimeSub?.cancel();
    super.dispose();
  }

  void _checkOrDisplayAd() async {
    Map<String, dynamic> splashAd = await CommonApi.getSplashAd();
    if (splashAd != null && splashAd.isNotEmpty) {
      if (splashAd.containsKey("imageUrl")) {
        setState(() {
          _adValueMap = splashAd;
          _adLeftTime = splashAd["displayMs"] ~/ 1000;
          _addTotalTime = _adLeftTime;
          _hasAd = true;
          print(splashAd);
        });
      }
    }
  }

  void _initSplash() {
    _subscription = TimerStream("", Duration(milliseconds: 2000)).listen((_) async {
      String storageToken = SpUtil.getString(SharedConstant.LOCAL_ACCOUNT_TOKEN, defValue: '');
      LogUtil.e("------执行登录------, storageToken: $storageToken", tag: TAG);
      if (storageToken == '') {
        _goLogin();
      } else {
        httpUtil.updateAuthToken(storageToken);
        httpUtil2.updateAuthToken(storageToken);
        LogUtil.e("有storageToken", tag: TAG);
        await MemberApi.getMyAccount(storageToken).then((acc) async {
          LogUtil.e("登录完成--------", tag: TAG);
          if (acc == null) {
            _goLogin();
          } else {
            AccountLocalProvider accountLocalProvider =
                Provider.of<AccountLocalProvider>(context, listen: false);
            LogUtil.e("调用getMyAccount结果: ${acc.toJson()}", tag: TAG);
            accountLocalProvider.setAccount(acc);

            Application.setAccount(acc);
            Application.setAccountId(acc.id);

            int orgId = SpUtil.getInt(SharedConstant.LOCAL_ORG_ID, defValue: -1);

            String orgName = SpUtil.getString(SharedConstant.LOCAL_ORG_NAME, defValue: "");
            if (orgId == -1 || orgName == "") {
              University university = await UniversityApi.queryUnis(storageToken);
              if (university == null) {
                // 错误，有账户无组织
                ToastUtil.showToast(context, '数据错误');
              } else {
                if (university == null || university.id == null || university.name == null) {
                  ToastUtil.showToast(context, '数据错误');
                  return;
                }
                await SpUtil.putInt(SharedConstant.LOCAL_ORG_ID, university.id);
                await SpUtil.putString(SharedConstant.LOCAL_ORG_NAME, university.name);
                Application.setOrgName(university.name);
                Application.setOrgId(university.id);
              }
            } else {
              LogUtil.e("登录成功，orgId: $orgId, orgName: $orgName", tag: TAG);
              Application.setOrgId(orgId);
              Application.setOrgName(orgName);
            }
            Application.setLocalAccountToken(storageToken);
            AccountDeviceUtil.getAndUpdateDeviceInfo(Application.getDeviceId);
            decideWhatToDo();
            _clearCacheIfNecessary();
          }
        });
      }
    });
  }

  void decideWhatToDo() {
    if (_hasGuide) {
      setState(() {
        _displayGuide = true;
      });
      return;
    }
    if (_hasAd) {
      setState(() {
        _displayAd = true;
      });
      _delayAndForwardIndex((_adValueMap["displayMs"] as int));
      return;
    }
    // 其他情况
    setState(() {
      _status = 1;
    });
  }

  void _delayAndForwardIndex(int ms) {
    _adLeftTimeSub = Stream.periodic(Duration(seconds: 1), (int i) {
      setState(() {
        _adLeftTime = _addTotalTime - i - 1;
        if (_adLeftTime < 1) {
          _status = 1;
          _displayAd = false;
        }
      });
    }).take(_addTotalTime).listen((event) {});
    TimerStream("", Duration(milliseconds: ms)).listen((_) async {
      setState(() {
        _status = 1;
        _displayAd = false;
      });
    });
  }

  Future<void> _clearCacheIfNecessary() async {
    String date = await SharedPreferenceUtil.readStringValue(SharedConstant.LAST_CLEAR_CACHE);
    if (date == null) {
      await SharedPreferenceUtil.setStringValue(
          SharedConstant.LAST_CLEAR_CACHE, DateTime.now().millisecondsSinceEpoch.toString());
      return;
    }

    int nowMs = DateUtil.getNowDateMs();
    int lastClearDateMs = int.parse(date);
    if (nowMs - lastClearDateMs > 3 * 24 * 3600 * 1000) {
      // 超过三天没有清理缓存了
      PaintingBinding.instance.imageCache.clear();
      var defaultCacheManager = DefaultCacheManager();
      defaultCacheManager.emptyCache();
      await SharedPreferenceUtil.setStringValue(SharedConstant.LAST_CLEAR_CACHE, nowMs.toString());
    }
  }

  Future<void> _loadStorageTweetTypes() async {
    TweetTypesFilterProvider tweetTypesFilterProvider = Provider.of<TweetTypesFilterProvider>(context);
    tweetTypesFilterProvider.updateTypeNames();
  }

  Future<void> _checkGuideNeed() async {
    // setState(() {
    //   _hasGuide = true;
    // });
    String versionVal = SpUtil.getString(version, defValue: "0");
    print(version);
    print(versionVal);
    LogUtil.e("获取引导版本字段，$versionVal");
    if (versionVal == "0") {
      await SpUtil.putString(version, "1");
      setState(() {
        _hasGuide = true;
      });
      return;
    } else {
      // 没有引导页面去找广告啊
      _checkOrDisplayAd();
    }
  }

  _goLogin() {
    NavigatorUtils.push(context, Routes.loginPage, replace: true);
  }

  @override
  Widget build(BuildContext context) {
    prefix0.ScreenUtil.init(context, width: 1242, height: 2688);
    // prefix0.ScreenUtil.instance = prefix0.ScreenUtil(width: 750, height: 1334)..init(context);
    Application.screenWidth = prefix0.ScreenUtil.screenWidth;
    Application.screenHeight = prefix0.ScreenUtil.screenHeight;
    Application.context = context;

    Widget w;
    if (_displayGuide) {
      w = Stack(
        children: [
          Swiper(
              itemBuilder: (BuildContext context, int index) {
                return LoadAssetImage("guide/${index + 1}", width: double.infinity, height: double.infinity);
                // return CachedNetworkImage(
                //     imageUrl: _guideImages[index],
                //     width: double.infinity,
                //     fit: BoxFit.cover,
                //     placeholder: (context, _) => const CupertinoActivityIndicator(),
                //     height: double.infinity,
                //     fadeInCurve: Curves.linear);
              },
              onIndexChanged: (index) {
                setState(() {
                  _currentGuideIndex = index;
                });
              },
              loop: false,
              layout: SwiperLayout.DEFAULT,
              itemCount: _guideLen),
          Positioned(
            top: prefix0.ScreenUtil().setHeight(30) + prefix0.ScreenUtil.statusBarHeight,
            right: prefix0.ScreenUtil().setWidth(60),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.black12,
              ),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
              child: GestureDetector(
                // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                child: Text(
                  _currentGuideIndex == _guideLen - 1 ? "完成" : "跳过",
                  style: pfStyle.copyWith(fontSize: Dimens.font_sp14, color: Colors.black54),
                ),
                onTap: () {
                  setState(() {
                    _status = 1;
                    _displayAd = false;
                    _displayGuide = false;
                  });
                },
              ),
            ),
          ),
          Positioned(
            bottom: prefix0.ScreenUtil().setHeight(200),
            left: 0,
            child: Container(
              // height: 100,
              width: Application.screenWidth,
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _xiaoHuaKuai(_currentGuideIndex == 0),
                    _xiaoHuaKuai(_currentGuideIndex == 1),
                    _xiaoHuaKuai(_currentGuideIndex == 2),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      if (_displayAd) {
        UMengUtil.userGoPage(UMengUtil.PAGE_AD);
        w = Stack(
          children: [
            GestureDetector(
              child: CachedNetworkImage(
                imageUrl: _adValueMap["imageUrl"],
                width: double.infinity,
                fit: BoxFit.cover,
                height: double.infinity,
                fadeInCurve: Curves.linear,
              ),
              onTap: () => NavigatorUtils.goWebViewPage(
                  context, _adValueMap["jumpTitle"], _adValueMap["jumpUrl"],
                  source: "1"),
            ),
            Positioned(
              top: prefix0.ScreenUtil().setHeight(30) + prefix0.ScreenUtil.statusBarHeight,
              right: prefix0.ScreenUtil().setWidth(30),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black38,
                ),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                child: GestureDetector(
                  // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  child: Text(
                    "广告剩余 $_adLeftTime s丨跳过",
                    style: pfStyle.copyWith(fontSize: Dimens.font_sp14, color: Colors.white70),
                  ),
                  onTap: () {
                    setState(() {
                      _status = 1;
                      _displayAd = false;
                    });
                  },
                ),
              ),
            )
          ],
        );
      } else {
        if (_status == 0) {
          w = CachedNetworkImage(
            imageUrl: PathConstant.APP_LAUNCH_IMAGE,
            width: double.infinity,
            fit: BoxFit.cover,
            height: double.infinity,
            fadeInCurve: Curves.linear,
          );
        } else {
          return Index();
        }
      }
    }

    return Material(child: w);
    // child: OrgInfoCPage());
  }

  Widget _xiaoHuaKuai(bool currentThis) {
    return Container(
      color: currentThis ? Colors.lightBlue : Colors.white24,
      width: Application.screenWidth * 0.1,
      height: 2.0,
    );
  }
}
