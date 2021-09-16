import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/api/tweet_type_subscribe.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/simple_confirm.dart';
import 'package:iap_app/component/tweet/tweet_card.dart';
import 'package:iap_app/component/widget_sliver_future_builder.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/PermissionUtil.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart';

class MySubscribePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MySubscribePageState();
  }
}

class _MySubscribePageState extends State<MySubscribePage> {
  EasyRefreshController _easyRefreshController;
  Function _getSubscribedTask;

  List<String> _subscribeNames = List();

  bool isDark = false;

  Future<Result<dynamic>> _getMySubscribedTypes(BuildContext context) async {
    Result<dynamic> data = await TtSubscribe.getMySubscribeTypes();
    if (data != null) {
      if (data.isSuccess) {
        setState(() {
          List<dynamic> names = data.data;
          _subscribeNames = names.map((e) => e.toString()).toList();
        });
        print(_subscribeNames);
        ToastUtil.showToast(context, "点击图标订阅或取消订阅喔～");
      } else {
        ToastUtil.showToast(context, data.message);
      }
    } else {
      ToastUtil.showServiceExpToast(context);
    }
    return data;
  }

  @override
  void initState() {
    super.initState();
    _easyRefreshController = EasyRefreshController();
    _getSubscribedTask = _getMySubscribedTypes;
  }

  @override
  void dispose() {
    _easyRefreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isDark = ThemeUtils.isDark(context);
    return Scaffold(
      appBar: MyAppBar(
          centerTitle: "我的订阅",
          actionName: "说明",
          onPressed: () {
            Utils.displayDialog(
                context, SimpleConfirmDialog('订阅说明', '如果您订阅了某一个类型的标签，在该标签下有内容更新时，您将会收到通知。\n您需要赋予Wall通知权限。'));
          }),
      body: CustomSliverFutureBuilder(
          futureFunc: _getSubscribedTask,
          builder: (context, data) => Container(
                margin: EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                  top: ScreenUtil().setHeight(80),
                ),
                child: _buildBody(context, data),
              )),
    );
  }

  _buildBody(BuildContext context, dynamic data) {
    List<TweetTypeEntity> entities =
        new List.from(TweetTypeUtil.getFilterableTweetTypeMap().values, growable: false);
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, //每行三列
          childAspectRatio: 1.0, //显示区域宽高相等
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
        ),
        itemCount: entities.length,
        itemBuilder: (context, index) {
          //如果显示到最后一个并且Icon总数小于200时继续获取数据
          // if (index == _icons.length - 1 && _icons.length < 200) {
          //   _retrieveIcons();
          // }
          TweetTypeEntity tt = entities[index];
          bool sub = _subscribeNames.contains(tt.name);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              if (!(await PermissionUtil.checkAndRequestNotification(context, showTipIfDetermined: true))) {
                // 没有通知权限
                ToastUtil.showToast(context, "通知权限未开启");
                return;
              }
              _subOrCancel(context, tt.name, sub);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: isDark ? ColorConstant.DEFAULT_BAR_BACK_COLOR_DARK : ColorConstant.DEFAULT_BACK_COLOR,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(tt.iconData, size: 30, color: sub ? tt.iconColor : Colors.grey),
                  Gaps.vGap10,
                  Text(tt.zhTag,
                      style:
                          pfStyle.copyWith(fontSize: Dimens.font_sp14, color: sub ? tt.color : Colors.grey)),
                  sub
                      ? Container(
                          color: tt.iconColor,
                          width: (Application.screenWidth - 30) / 15,
                          height: 1,
                          margin: const EdgeInsets.only(top: 10.0),
                        )
                      : Gaps.empty
                ],
              ),
            ),
          );
        });
  }

  void _subOrCancel(BuildContext context, String name, bool cancel) async {
    Utils.showDefaultLoadingWithAsyncCall(context, () async {
      Result r;
      if (cancel) {
        // 取消订阅
        r = await TtSubscribe.unSubscribeType(name);
      } else {
        r = await TtSubscribe.subscribeType(name);
      }
      if (r == null || !r.isSuccess) {
        ToastUtil.showToast(context, "操作失败，请稍后重试");
      } else {
        setState(() {
          if (cancel) {
            if (_subscribeNames.contains(name)) {
              _subscribeNames.remove(name);
            }
            ToastUtil.showToast(context, "已取消订阅");
          } else {
            if (!_subscribeNames.contains(name)) {
              _subscribeNames.add(name);
            }
            ToastUtil.showToast(context, "订阅成功");
          }
        });
      }
    });

    // if (cancel) {
    //   _subscribeNames.remove(tt.name);
    // } else {
    //   _subscribeNames.add(tt.name);
    // }
  }
}
