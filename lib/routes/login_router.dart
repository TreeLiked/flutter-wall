import 'package:fluro/fluro.dart';
import 'package:iap_app/page/login/account_info_set.dart';
import 'package:iap_app/page/login/org_info_set.dart';
import 'package:iap_app/page/login/sms_login_page.dart';
import 'package:iap_app/routes/router_init.dart';

class LoginRouter implements IRouterProvider {
  static String loginIndex = "/login";
  static String loginInfoPage = "/login/info";
  static String loginOrgPage = "/login/org";

  @override
  void initRouter(Router router) {
    router.define(loginIndex,
        handler: Handler(handlerFunc: (_, params) => LoginPage()));

    router.define(loginInfoPage,
        handler: Handler(handlerFunc: (_, params) => AccountInfoCPage()));

    router.define(loginOrgPage,
        handler: Handler(handlerFunc: (_, params) => OrgInfoCPage()));
  }
}
