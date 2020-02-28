import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:device_info/device_info.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/api/device.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/page/common/org_sel_page.dart';
import 'package:iap_app/page/login/account_info_set.dart';
import 'package:iap_app/page/login/org_info_set.dart';
import 'package:iap_app/page/splash_page.dart';
import 'package:iap_app/page/tweet_detail.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/theme_provider.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/util/string.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(AlmondDonuts());

  // 透明状态栏
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class AlmondDonuts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AlmondDonutsState();
  }
}

class AlmondDonutsState extends State<AlmondDonuts> {
  final JPush _jPush = JPush();

  AlmondDonutsState() {
    final Router router = Router();
    Routes.configureRoutes(router);
    Application.router = router;

//    PaintingBinding.instance.imageCache.clear();
//   DefaultCacheManger manager = new DefaultCacheManager();
// manager.emtyCache();
  }

  @override
  void initState() {
    super.initState();

    initPlatformState();
    print('------------------main--------------------------');
    _jPush.getRegistrationID().then((rid) {
      if (rid != null && rid.length != 0) {
        Application.setDeviceId(rid);
        _getAndUpdateDeviceInfo(rid);
      }
    });

//    var fireDate = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + 3000);
//    var localNotification = LocalNotification(
//        id: 234,
//        title: 'fadsfa',
//        buildId: 1,
//        content: 'fdas',
//        fireTime: fireDate,
//        subtitle: 'fasf',
//        badge: 5,
//        extra: {"fa": "0"});
//    _jPush.sendLocalNotification(localNotification).then((res) {
//      print(res);
//    });
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Color(0xff000000), statusBarIconBrightness: Brightness.dark));
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  addEventListeners() {
    _jPush.addEventHandler(
      // 接收通知回调方法。
      onReceiveNotification: (Map<String, dynamic> message) async {
        print("flutter onReceiveNotification: $message");
      },
      // 点击通知回调方法。
      onOpenNotification: (Map<String, dynamic> message) async {
        print("flutter onOpenNotification: $message");
        _jPush.clearAllNotifications();

        Map<String, dynamic> extraMap;
        if (Platform.isAndroid) {
          extraMap = json.decode(message['extras']['cn.jpush.android.EXTRA']);
        } else if (Platform.isIOS) {
          extraMap = message;
        } else {
          return;
        }
        print(extraMap);
        if (extraMap == null) {
          return;
        }
        if (extraMap.containsKey("JUMP")) {
          this._handleJump(extraMap);
        }
      },
      // 接收自定义消息回调方法。
      onReceiveMessage: (Map<String, dynamic> message) async {
        print("flutter onReceiveMessage: $message");
      },
    );
  }

  _handleJump(Map<String, dynamic> extraMap) {
    if (Application.context == null) {
      return;
    }
    String jumpKey = extraMap['JUMP'].toString();
    int refId = int.parse(extraMap['REF_ID']);
    if (jumpKey == 'TWEET_DETAIL') {
      _forwardTweetDetail(refId);
    }
  }

  _forwardTweetDetail(tweetId) async {
    print('跳转到 -> tweet detail $tweetId');
    NavigatorUtils.push(Application.context, Routes.tweetDetail + "?tweetId=$tweetId");

//    Navigator.push(
//      Application.context,
//      MaterialPageRoute(builder: (context) => TweetDetail(null, tweetId: tweetId)),
//    );
  }

  Future<void> initPlatformState() async {
    addEventListeners();
    _jPush.setup(
      appKey: "2541d486ffc85cf504572f6e",
      channel: "developer-default",
//      channel: "flutter_channel",
      production: false,
      debug: true,
    );
    if (Platform.isIOS) {
      _jPush.applyPushAuthority(new NotificationSettingsIOS(sound: true, alert: true, badge: true));
    }
//    _jPush.applyPushAuthority(new NotificationSettingsIOS(sound: true, alert: true, badge: true));
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(builder: (_) => AccountLocalProvider()),
          ChangeNotifierProvider(builder: (_) => TweetTypesFilterProvider()),
          ChangeNotifierProvider(builder: (_) => ThemeProvider()),
          ChangeNotifierProvider(builder: (_) => TweetProvider()),
        ],
        child: Consumer<ThemeProvider>(builder: (_, provider, __) {
          return MaterialApp(
            title: 'Wall',
            //showPerformanceOverlay: true, //显示性能标签
            debugShowCheckedModeBanner: false,
            theme: provider.getTheme(),
            darkTheme: provider.getTheme(isDarkMode: true),
//            home: SplashPage(),
            home: SplashPage(),
            onGenerateRoute: Application.router.generator,
            // localizationsDelegates: const [
            //   GlobalMaterialLocalizations.delegate,
            //   GlobalWidgetsLocalizations.delegate,
            //   GlobalCupertinoLocalizations.delegate,
            // ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate
            ],
            supportedLocales: const [const Locale('zh', 'CH')],
          );
        }));

    // return ChangeNotifierProvider<ThemeProvider>(
    //   builder: (_) => ThemeProvider(),
    //   child: Consumer<ThemeProvider>(
    //     builder: (_, provider, __) {
    //       return MaterialApp(
    //           title: 'Flutter Deer',
    //           //showPerformanceOverlay: true, //显示性能标签
    //           debugShowCheckedModeBanner: false,
    //           theme: provider.getTheme(),
    //           darkTheme: provider.getTheme(isDarkMode: true),
    //           home: SplashPage(),
    //           onGenerateRoute: Application.router.generator,
    //           // localizationsDelegates: const [
    //           //   GlobalMaterialLocalizations.delegate,
    //           //   GlobalWidgetsLocalizations.delegate,
    //           //   GlobalCupertinoLocalizations.delegate,
    //           // ],
    //           supportedLocales: const [Locale('zh', 'CH'), Locale('en', 'US')]);
    //     },
    //   ),
    // );
  }

  void _getAndUpdateDeviceInfo(String regId) async {
    print("reg id 获取成功---$regId");
    DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print(iosInfo);
      _updateDeviceInfo("IPHONE", "IOS", iosInfo.systemVersion, regId);
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print(_readAndroidBuildData(androidInfo));
      _updateDeviceInfo(androidInfo.brand.toUpperCase(), "ANDROID", androidInfo.device, regId);
    } else {
      debugPrint("Unsupport Platform type");
    }
  }

  void _updateDeviceInfo(String name, String platform, String model, String regId) async {
    DeviceApi.updateDeviceInfo(Application.getAccountId, name, platform, model, regId);
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId
    };
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
