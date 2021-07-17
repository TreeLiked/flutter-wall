import 'package:fluro/fluro.dart';
import 'package:iap_app/page/notification/campus_main.dart';
import 'package:iap_app/page/notification/circle_main.dart';
import 'package:iap_app/page/notification/interactive_main.dart';
import 'package:iap_app/page/notification/system_main.dart';
import 'package:iap_app/routes/router_init.dart';

class NotificationRouter implements IRouterProvider {
  static String systemMain = "/notification/system";
  static String interactiveMain = "/notification/interactive";
  static String circleMain = "/notification/circle";
  static String campusMain = "/notification/campus";

  @override
  void initRouter(FluroRouter router) {
    router.define(systemMain, handler: Handler(handlerFunc: (_, params) {
      return SystemNotificationMainPage();
    }));
    router.define(interactiveMain, handler: Handler(handlerFunc: (_, params) {
      return InteractiveNotificationMainPage();
    }));
    router.define(campusMain, handler: Handler(handlerFunc: (_, params) {
      return CampusNotificationMainPage();
    }));
    router.define(circleMain, handler: Handler(handlerFunc: (_, params) {
      return CircleNotificationMainPage();
    }));
    // router.define(accountManagerPage, handler: Handler(handlerFunc: (_, params) => AccountManagerPage()));
  }
}
