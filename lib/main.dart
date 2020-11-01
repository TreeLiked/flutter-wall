import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:common_utils/common_utils.dart';
import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/page/splash_page.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/theme_provider.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/util/JPushUtil.dart';
import 'package:iap_app/util/umeng_util.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:provider/provider.dart';

void main() {
//  TestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AlmondDonuts());

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // 透明状态栏
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class AlmondDonuts extends StatefulWidget {
  static const bool inProduction = const bool.fromEnvironment("dart.vm.product");

  @override
  State<StatefulWidget> createState() {
    return AlmondDonutsState();
  }
}

class AlmondDonutsState extends State<AlmondDonuts> {
  final JPush _jPush = JPush();

  AlmondDonutsState() {
    final fluro.Router router = fluro.Router();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  @override
  void initState() {
    super.initState();

    initPlatformState();
    initUMengAnalytics();

    LogUtil.init(tag: "Wall",maxLen: 1024);
    LogUtil.e("Main 生产环境=${AlmondDonuts.inProduction}", tag: "AlmondDonuts");
    _jPush.getRegistrationID().then((rid) {
      if (rid != null && rid.length != 0) {
        Application.setDeviceId(rid);
        // _getAndUpdateDeviceInfo(rid);
      } else {
        LogUtil.e("获取不到RegistrationId", tag: "AlmondDonuts");
      }
    });

    // var fireDate = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + 3000);
    // var localNotification = LocalNotification(
    //     id: 234,
    //     title: 'fadsfa',
    //     buildId: 1,
    //     content: 'fdas',
    //     fireTime: fireDate,
    //     subtitle: 'fasf',
    //     badge: 5,
    //     extra: {"fa": "0"});
    // _jPush.sendLocalNotification(localNotification).then((res) {
    //   print(res);
    // });
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
    JPushUtil.jPush = _jPush;
    _jPush.setup(
      appKey: "2541d486ffc85cf504572f6e",
      channel: "developer-default",
//      channel: "flutter_channel",
      production: AlmondDonuts.inProduction,
      debug: !AlmondDonuts.inProduction,
    );
//    _jPush.applyPushAuthority(new NotificationSettingsIOS(sound: true, alert: true, badge: true));
    if (!mounted) return;
  }

  Future<void> initUMengAnalytics() async {
    await UMengUtil.initUMengAnalytics();
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
