import 'package:fluro/fluro.dart';
import 'package:iap_app/page/notification/campus_main.dart';
import 'package:iap_app/page/notification/interactive_main.dart';
import 'package:iap_app/page/notification/system_main.dart';
import 'package:iap_app/routes/router_init.dart';

class NotificationRouter implements IRouterProvider {
  static String systemMain = "/notification/system";
  static String interactiveMain = "/notification/interactive";
  static String campusMain = "/notification/campus";

  @override
  void initRouter(Router router) {
    router.define(systemMain, handler: Handler(handlerFunc: (_, params) {
      return SystemNotificationMainPage();
    }));
    router.define(interactiveMain, handler: Handler(handlerFunc: (_, params) {
      return InteractiveNotificationMainPage();
    }));
    router.define(campusMain, handler: Handler(handlerFunc: (_, params) {
      return CampusNotificationMainPage();
    }));
    // router.define(accountManagerPage, handler: Handler(handlerFunc: (_, params) => AccountManagerPage()));
  }
}
