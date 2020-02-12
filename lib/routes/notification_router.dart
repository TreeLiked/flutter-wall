import 'package:fluro/fluro.dart';
import 'package:iap_app/page/account_profile.dart';
import 'package:iap_app/page/common/org_sel_page.dart';
import 'package:iap_app/page/notification/interactive_main.dart';
import 'package:iap_app/page/notification/sn.page.dart';
import 'package:iap_app/page/notification/system_main.dart';
import 'package:iap_app/page/personal_center/about_page.dart';
import 'package:iap_app/page/personal_center/account_bind.dart';
import 'package:iap_app/page/personal_center/account_info.dart';
import 'package:iap_app/page/personal_center/account_public_info.dart';
import 'package:iap_app/page/personal_center/history_push.dart';
import 'package:iap_app/page/personal_center/notification_page.dart';
import 'package:iap_app/page/personal_center/other_setting.dart';
import 'package:iap_app/page/personal_center/personal_center.dart';
import 'package:iap_app/page/personal_center/private_setting.dart';
import 'package:iap_app/page/personal_center/theme_page.dart';
import 'package:iap_app/routes/router_init.dart';
import 'package:iap_app/util/fluro_convert_utils.dart';

class NotificationRouter implements IRouterProvider {
  static String systemMain = "/notification/system";
  static String interactiveMain = "/notification/interactive";

  @override
  void initRouter(Router router) {
    router.define(systemMain, handler: Handler(handlerFunc: (_, params) {
      return SystemNotificationMainPage();
    }));
    router.define(interactiveMain, handler: Handler(handlerFunc: (_, params) {
      return InteractiveNotificationMainPage();
    }));
    // router.define(accountManagerPage, handler: Handler(handlerFunc: (_, params) => AccountManagerPage()));
  }
}
