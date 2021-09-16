import 'package:flutter/material.dart';
import 'package:iap_app/api/report.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';

class ReportPage extends StatelessWidget {
  static const REPORT_TWEET = "TWEET";
  static const REPORT_TWEET_IMAGE = "TWEET_IMAGE";
  static const REPORT_TWEET_REPLY = "TWEET_TYPE";
  static const REPORT_TOPIC = "TOPIC";
  static const REPORT_TOPIC_REPLY = "TOPIC_REPLY";
  static const REPORT_ACCOUNT = "ACCOUNT";
  static const REPORT_CIRCLE = "CIRCLE";

  static const REPORT_SYSTEM = "SYSTEM";

  final String type;
  final String refId;
  final String title;

  ReportPage(this.type, this.refId, this.title);

  TextEditingController _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeUtils.isDark(context);
    return Scaffold(
      appBar: MyAppBar(
        isBack: true,
        title: title ?? "问题反馈",
        centerTitle: title ?? '问题反馈',
        actionName: "发送",
        onPressed: () => sendReport(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: ThemeUtils.isDark(context)
                      ? ColorConstant.DEFAULT_BAR_BACK_COLOR_DARK
                      : ColorConstant.TWEET_RICH_BG,
                  borderRadius: BorderRadius.circular(8.0)),
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0),
              margin: const EdgeInsets.only(left: 2.0, right: 2.0),
              child: TextField(
                keyboardAppearance: Theme.of(context).brightness,
                controller: _controller,
                autofocus: true,
                cursorColor: Colors.blue,
                maxLengthEnforced: true,
                maxLength: 128,
                keyboardType: TextInputType.multiline,
                autocorrect: false,
                maxLines: 8,
                style: const TextStyle(height: 1.5, fontSize: Dimens.font_sp15),
                decoration: new InputDecoration(
                  hintText: '请具体描述',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendReport(BuildContext context) {
    String text = _controller.text;
    if (text == null || text.trim().length == 0) {
      ToastUtil.showToast(context, '请描述具体反馈信息');
      return;
    } else {
      Utils.showDefaultLoading(context);
      ReportAPI.sendReport(type, refId, text).then((res) {
        NavigatorUtils.goBack(context);
        if (res == null) {
          ToastUtil.showToast(context, TextConstant.TEXT_SERVICE_ERROR);
        } else {
          if (res.isSuccess) {
            ToastUtil.showToast(context, '反馈成功，有结果我们会第一时间通知您');
            _controller.clear();
            NavigatorUtils.goBack(context);
          } else {
            ToastUtil.showToast(context, '反馈失败');
          }
        }
      });
    }
  }
}
