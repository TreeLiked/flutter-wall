import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Login extends StatefulWidget {
  Login();
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<Login> {
  LoginState() {
    print('LOGINSTATE state construct');
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
