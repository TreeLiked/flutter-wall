import 'dart:io';
import 'dart:ui';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/page/login/account_info_set.dart';
import 'package:iap_app/page/splash_page.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/theme_provider.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:provider/provider.dart';

void main() {
  // var tweetBloc = TweetBloc();

  runApp(
      // Provider<List<BaseTweet>>.value(
      //   child: ChangeNotifierProvider.value(
      //     value: tweetBloc,
      //     child: AlmondDonuts(),
      //   ),
      // ),
      AlmondDonuts());

  // 透明状态栏
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
  // runApp(MultiProvider(providers: [
  //   Provider<TweetBloc>.value(value: tweetBloc),
  // ], child: Iap()));
}

class AlmondDonuts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AlmondDonutsState();
  }
}

class AlmondDonutsState extends State<AlmondDonuts> {
  var loginState;

  AlmondDonutsState() {
    final Router router = Router();
    Routes.configureRoutes(router);
    Application.router = router;

    PaintingBinding.instance.imageCache.clear();
//   DefaultCacheManger manager = new DefaultCacheManager();
// manager.emtyCache();
  }

  @override
  void initState() {
    super.initState();

    // SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //     statusBarColor: Color(0xff000000),
    //     statusBarIconBrightness: Brightness.dark));
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
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
            title: 'Flutter Deer',
            //showPerformanceOverlay: true, //显示性能标签
            debugShowCheckedModeBanner: false,
            theme: provider.getTheme(),
            darkTheme: provider.getTheme(isDarkMode: true),
            home: SplashPage(),
            onGenerateRoute: Application.router.generator,
            // localizationsDelegates: const [
            //   GlobalMaterialLocalizations.delegate,
            //   GlobalWidgetsLocalizations.delegate,
            //   GlobalCupertinoLocalizations.delegate,
            // ],
            // supportedLocales: const [
            //   Locale('zh', 'CH'),
            //   Locale('en', 'US')
            // ]
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

  // return new MaterialApp(
  //   debugShowCheckedModeBanner: false,
  //   title: 'iap',
  //   theme: ThemeConstant.lightTheme,
  //   home: Index(),
  //   onGenerateRoute: Application.router.generator,
  // );
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
