import 'dart:io';

import 'package:jpush_flutter/jpush_flutter.dart';

class JPushUtil {
  static JPush _jPush;

  static bool _firstRequest = true;

  static JPush get jPush => _jPush;

  static set jPush(JPush value) {
    _jPush = value;
  }

  static bool get firstRequest => _firstRequest;

  static set firstRequest(bool value) {
    _firstRequest = value;
  }

  static void requestOnlyOnce() async {
    if (firstRequest && Platform.isIOS) {
      _jPush.applyPushAuthority(new NotificationSettingsIOS(sound: true, alert: true, badge: true));
      firstRequest = false;
    }
  }
}
