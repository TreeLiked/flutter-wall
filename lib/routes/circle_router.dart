import 'package:fluro/fluro.dart';
import 'package:iap_app/page/circle/circle_create.dart';
import 'package:iap_app/page/common/org_sel_page.dart';
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
      return CircleCreatePage(true);
    }));
    // router.define(accountManagerPage, handler: Handler(handlerFunc: (_, params) => AccountManagerPage()));
  }
}
