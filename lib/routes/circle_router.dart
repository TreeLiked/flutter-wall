import 'package:fluro/fluro.dart';
import 'package:iap_app/page/circle/circle_tweet_create.dart';
import 'package:iap_app/page/common/org_sel_page.dart';
import 'package:iap_app/page/personal_center/about_page.dart';
import 'package:iap_app/page/personal_center/account_bind.dart';
import 'package:iap_app/page/personal_center/account_info.dart';
import 'package:iap_app/page/personal_center/account_public_info.dart';
import 'package:iap_app/page/personal_center/account_school_info.dart';
import 'package:iap_app/page/personal_center/history_push.dart';
import 'package:iap_app/page/personal_center/institute_info_set.dart';
import 'package:iap_app/page/personal_center/invitation.dart';
import 'package:iap_app/page/personal_center/my_subscribe.dart';
import 'package:iap_app/page/personal_center/notification_page.dart';
import 'package:iap_app/page/personal_center/other_setting.dart';
import 'package:iap_app/page/personal_center/personal_center.dart';
import 'package:iap_app/page/personal_center/private_setting.dart';
import 'package:iap_app/page/personal_center/theme_page.dart';
import 'package:iap_app/routes/router_init.dart';
import 'package:iap_app/util/fluro_convert_utils.dart';

class CircleRouter implements IRouterProvider {
  static const String HOME = "/circle/home";
  static const String CREATE = "/circle/home/create";

  @override
  void initRouter(FluroRouter router) {
    router.define(HOME, handler: Handler(handlerFunc: (_, params) {
      String title = params['title'].first;
      title = FluroConvertUtils.fluroCnParamsDecode(title);
      String hintText = params['hintText'].first;
      hintText = FluroConvertUtils.fluroCnParamsDecode(hintText);
      return OrgChoosePage(title, hintText: hintText);
    }));

    router.define(CREATE, handler: Handler(handlerFunc: (_, params) {
      return CircleTweetCreatePage();
    }));
    // router.define(accountManagerPage, handler: Handler(handlerFunc: (_, params) => AccountManagerPage()));
  }
}
