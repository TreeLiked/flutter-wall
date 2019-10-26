import 'dart:ui';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/config/routes.dart';
import 'package:iap_app/global/theme_constant.dart';
import 'package:iap_app/index/index.dart';
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
  }

  @override
  void initState() {
    super.initState();
    _validateLogin();
    // SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //     statusBarColor: Color(0xff000000),
    //     statusBarIconBrightness: Brightness.dark));
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
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
      home: loginState == 1 ? Login() : Index(),
      onGenerateRoute: Application.router.generator,
    );
  }

  Future _validateLogin() async {
    String s = await SharedPreferenceUtil.readStringValue(
            SharedConstant.LOCAL_ACCOUNT_ID)
        .catchError((onError) => print(onError));
    if (!StringUtil.isEmpty(s)) {
      setState(() {
        loginState = 1;
      });
    } else {
      setState(() {
        loginState = 0;
      });
    }
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
