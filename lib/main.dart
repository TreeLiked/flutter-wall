import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/shared_data.dart';
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

  AlmondDonutsState();

  @override
  void initState() {
    super.initState();
    _validateLogin();
  }

  @override
  Widget build(BuildContext context) {
    print(window.physicalSize.width.toString() + "==========================");
    print(window.physicalSize.height.toString() + "==========================");

    print(loginState);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'iap',
      home: loginState == 1 ? Login() : Index(),
    );
  }

  Future _validateLogin() async {
    String s = await SharedPreferenceUtil.readStringValue(
            AuthConstant.LOCAL_ACCOUNT_ID)
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
