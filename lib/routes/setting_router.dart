import 'package:fluro/fluro.dart';
import 'package:iap_app/page/common/org_sel_page.dart';
import 'package:iap_app/page/personal_center/about_page.dart';
import 'package:iap_app/page/personal_center/other_setting.dart';
import 'package:iap_app/page/personal_center/personal_center.dart';
import 'package:iap_app/page/personal_center/theme_page.dart';
import 'package:iap_app/routes/router_init.dart';
import 'package:iap_app/util/fluro_convert_utils.dart';

class SettingRouter implements IRouterProvider {
  static String settingPage = "/pc";
  static String aboutPage = "/pc/about";
  static String privateSettingPage = "/pc/private";

  static String otherSettingPage = "/pc/other";
  static String themePage = "/pc/other/theme";

  static String orgChoosePage = "/pc/org";

  @override
  void initRouter(Router router) {
    router.define(settingPage,
        handler: Handler(handlerFunc: (_, params) => PersonalCenter()));

    router.define(privateSettingPage,
        handler: Handler(handlerFunc: (_, params) => PrivateSetting()));
    router.define(aboutPage,
        handler: Handler(handlerFunc: (_, params) => AboutPage()));

    router.define(otherSettingPage,
        handler: Handler(handlerFunc: (_, params) => OtherSetting()));
    router.define(themePage,
        handler: Handler(handlerFunc: (_, params) => ThemePage()));

    router.define(orgChoosePage, handler: Handler(handlerFunc: (_, params) {
      print('=====================================');
      String title = params['title'].first;
      title = FluroConvertUtils.fluroCnParamsDecode(title);
      String hintText = params['hintText'].first;
      hintText = FluroConvertUtils.fluroCnParamsDecode(hintText);
      print("$title  ---  $hintText");

      return OrgChoosePage(title, hintText: hintText);
    }));
    // router.define(accountManagerPage, handler: Handler(handlerFunc: (_, params) => AccountManagerPage()));
  }
}
