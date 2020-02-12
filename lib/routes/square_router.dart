import 'package:fluro/fluro.dart';
import 'package:iap_app/page/login/account_info_set.dart';
import 'package:iap_app/page/login/org_info_set.dart';
import 'package:iap_app/page/login/sms_login_page.dart';
import 'package:iap_app/page/square/topic/topic_create.dart';
import 'package:iap_app/page/square/topic/topic_detail_page.dart';
import 'package:iap_app/routes/router_init.dart';

class SquareRouter implements IRouterProvider {
  static String squareIndex = "/home/square";
  static String topicPageView = "/home/square/topic";
  static String topicDetail = "/home/square/topic/detail";
  static String topicCreate = "/home/square/topic/create";
  static String activityPageView = "/home/square/activity";
  static String activityDetail = "/home/square/activity/detail";

  @override
  void initRouter(Router router) {
    router.define(topicDetail, handler: Handler(handlerFunc: (_, params) {
      int topicId = int.parse(params['topicId']?.first);
      return TopicDetailPage(topicId);
    }));

    router.define(topicCreate, handler: Handler(handlerFunc: (_, params) {
      return TopicCreatePage();
    }));
  }
}
