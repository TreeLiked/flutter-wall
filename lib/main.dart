import 'dart:io';
import 'dart:ui';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/index/index.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/page/splash_page.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/theme_provider.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
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
    print(window.physicalSize.width.toString() + "==========================");
    print(window.physicalSize.height.toString() + "==========================");

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(builder: (_) => AccountLocalProvider()),
          ChangeNotifierProvider(builder: (_) => ThemeProvider()),
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
            // supportedLocales: const [Locale('zh', 'CH'), Locale('en', 'US')]
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

Future _validateLogin(
    BuildContext context, AccountLocalProvider accountLocalProvider) async {
  // SharedPreferenceUtil.readStringValue('');
  Account acc = await MemberApi.getMyAccount("");
  if (acc == null) {
    print('acc null------');
    NavigatorUtils.push(context, Routes.loginPage, clearStack: true);
  } else {
    print(acc.toJson());
    accountLocalProvider.setAccount(acc);
  }

  // String s = await SharedPreferenceUtil.readStringValue(
  //         SharedConstant.LOCAL_ACCOUNT_ID)
  //     .catchError((onError) => print(onError));
  // if (!StringUtil.isEmpty(s)) {
  //   setState(() {
  //     loginState = 1;
  //   });
  // } else {
  //   setState(() {
  //     loginState = 0;
  //   });

  //   SharedPreferenceUtil.setStringValue(
  //       SharedConstant.LOCAL_ACCOUNT_ID, 'e5e5d7e2006c4788b6b24509dfe481b3');
  // }
  // Future<dynamic> future = Future(() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString("loginToken");
  // });

  // future.then((val) {
  //   if (val == null) {
  //     setState(() {
  //       loginState = 0;
  //     });
  //   } else {
  //     setState(() {
  //       loginState = 1;
  //     });
  //   }
  // }).catchError((_) {
  //   print("catchError");
  // });
  // }
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
