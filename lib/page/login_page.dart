import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/time_util.dart';

class Login extends StatefulWidget {
  Login();
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<Login> {
  LoginState() {
    print('TweetDETAIL state construct');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: NetworkImage(
            'https://tva1.sinaimg.cn/large/006y8mN6ly1g801c0t6fij30u01sxe83.jpg'),
      )),
    );
  }
}
