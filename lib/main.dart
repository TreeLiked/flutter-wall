import 'dart:ui';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/config/routes.dart';
import 'package:iap_app/global/theme_constant.dart';
import 'package:iap_app/index/index.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/page/login_page.dart';
import 'package:iap_app/util/shared.dart';
import 'package:iap_app/util/string.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/tweet.dart';

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
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
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
    _validateLogin();
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

    print(loginState);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'iap',
      theme: ThemeConstant.lightTheme,
      home: Index(),
      onGenerateRoute: Application.router.generator,
    );
  }

  Future _validateLogin() async {
    Account acc = new Account();
    acc.id = "e5e5d7e2006c4788b6b24509dfe481b3";
    acc.nick = "长安归故里";
    acc.avatarUrl =
        "https://tva1.sinaimg.cn/large/006y8mN6ly1g8dw00yhe7j30u011i0vj.jpg";
    Application.setAccount(acc);
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
