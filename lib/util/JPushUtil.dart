import 'package:jpush_flutter/jpush_flutter.dart';

class JPushUtil {




  static JPush _jPush;


  static JPush get jPush => _jPush;

  static set jPush(JPush value) {
    _jPush = value;
  }


}
