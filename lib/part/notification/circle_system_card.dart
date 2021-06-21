import 'package:common_utils/common_utils.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/api/circle.dart';
import 'package:iap_app/api/message.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/imgae_container.dart';
import 'package:iap_app/common-widget/my_flat_button.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:iap_app/model/message/circle_system_message.dart';
import 'package:iap_app/model/message/topic_reply_message.dart';
import 'package:iap_app/model/message/tweet_praise_message.dart';
import 'package:iap_app/model/message/tweet_reply_message.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/page/circle/circle_home.dart';
import 'package:iap_app/part/notification/red_point.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/routes/square_router.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart';

class CircleSystemCard extends StatefulWidget {
  CircleSystemMessage message;

  CircleSystemCard(this.message);

  @override
  State<StatefulWidget> createState() {
    return _CircleSystemCardState(message);
  }
}

class _CircleSystemCardState extends State<CircleSystemCard> {
  CircleSystemMessage message;

  MessageType mt;

  BuildContext thisContext;
  bool isDark = false;

  _CircleSystemCardState(this.message);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    thisContext = context;
    isDark = ThemeUtils.isDark(context);

    mt = message.messageType;

    Account account = message.applyAccount;

    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (mt == MessageType.CIRCLE_APPLY) {
            return;
          }
          if (mt == MessageType.CIRCLE_APPLY_RES) {
            MessageAPI.readThisMessage(message.id).then((res) {
              message.readStatus = ReadStatus.READ;
            });
            return;
          }
        },
        child: Container(
            margin: const EdgeInsets.only(left: 15.0, bottom: 2.0, right: 15.0, top: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                        margin: const EdgeInsets.only(right: 10.0),
                        child: AccountAvatar(
                            cache: true,
                            size: 40.0,
                            avatarUrl: account == null ? PathConstant.WALL_PROFILE : account.avatarUrl,
                            onTap: () => _handleGoAccount(account)))
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _buildHead(),
                      Gaps.vGap4,
                      _buildBody(),
                      Gaps.vGap5,
                      _buildOptions(),
                      Gaps.line
                    ],
                  ),
                ),
              ],
            )));
  }

  Widget _buildHead() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
            child: GestureDetector(
          child: Text('${message.title}', style: pfStyle.copyWith(fontSize: Dimens.font_sp14)),
          onTap: () => _handleGoAccount(message.applyAccount),
        )),
        Expanded(
            child: Container(
                child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            RedPoint(message, color: Colors.lightGreen),
            _buildTime(message.sentTime),
          ],
        )))
      ],
    );
  }

  _buildTime(DateTime dt) {
    return Container(
        margin: const EdgeInsets.only(left: 5.0),
        child: Text(TimeUtil.getShortTime(dt), style: MyDefaultTextStyle.getTweetTimeStyle(thisContext)));
  }

  _buildBody() {
    if (mt == MessageType.CIRCLE_APPLY) {
      return Container(
          child: RichText(
        text: TextSpan(style: _getClickTextStyle(), children: [
          TextSpan(
              text: '${message.applyAccount.nick}',
              recognizer: TapGestureRecognizer()..onTap = () => _handleGoAccount(message.applyAccount)),
          TextSpan(text: '申请加入', style: pfStyle.copyWith(color: Colors.grey)),
          TextSpan(
              text: '${message.approval.circleName}',
              recognizer: TapGestureRecognizer()..onTap = () => _handleGoCircleHome(message.circleId)),
          TextSpan(
              text: '，${TimeUtil.getShortTime(message.approval.gmtModified)}',
              style: pfStyle.copyWith(color: Colors.grey))
        ]),
      ));
    } else if (mt == MessageType.CIRCLE_APPLY_RES) {
      bool invalid = message.approval.status == -2;
      bool agree = message.approval.status == 1;
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(style: _getClickTextStyle(), children: [
                  TextSpan(
                      text:
                          '${message.applyAccount.id == Application.getAccountId ? '你' : message.applyAccount.nick}',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _handleGoAccount(message.applyAccount)),
                  TextSpan(text: '申请加入', style: pfStyle.copyWith(color: Colors.grey)),
                  TextSpan(
                      text: '${message.approval.circleName}',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _handleGoCircleHome(message.circleId)),
                  TextSpan(
                      text: '，${TimeUtil.getShortTime(message.approval.gmtCreated)}',
                      style: pfStyle.copyWith(color: Colors.grey))
                ]),
              )),
          Container(
              margin: const EdgeInsets.only(top: 10.0),
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                    style: _getClickTextStyle(),
                    children: invalid
                        ? [
                            TextSpan(text: '申请已失效', style: pfStyle.copyWith(color: Colors.grey)),
                          ]
                        : [
                            TextSpan(
                                text:
                                    '${message.optAccount.id == Application.getAccountId ? '你 ' : message.optAccount.nick}',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _handleGoAccount(message.optAccount)),
                            TextSpan(
                                text: '已${agree ? '同意' : '拒绝'}加入',
                                style: pfStyle.copyWith(color: agree ? Colors.green : Colors.orange)),
                            TextSpan(
                                text: '，${TimeUtil.getShortTime(message.approval.gmtModified)}',
                                style: pfStyle.copyWith(color: Colors.grey)),
                          ]),
              )),
        ],
      );
    } else if (mt == MessageType.CIRCLE_SIMPLE_SYS) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              margin: const EdgeInsets.only(top: 10.0),
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(style: pfStyle, children: [
                  TextSpan(text: '${message.content}', style: pfStyle.copyWith(color: Colors.grey))
                ]),
              )),
        ],
      );
    } else {
      return Gaps.empty;
    }
  }

  _buildOptions() {
    if (mt == MessageType.CIRCLE_APPLY) {
      if (message.readStatus == ReadStatus.IGNORED) {
        return Container(
          alignment: Alignment.centerRight,
          child: Text('已忽略',
              style: pfStyle.copyWith(
                  color: ColorConstant.TWEET_DISABLE_COLOR_TEXT_COLOR, fontSize: Dimens.font_sp13p5)),
        );
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _renderBtn(Icon(Icons.check_circle_outline, size: 20, color: Colors.green), '同意', Colors.green,
              () => _handleApply(true)),
          Gaps.hGap10,
          TextButton(
              child: Text(
                '拒绝',
                style: pfStyle.copyWith(color: Colors.orange),
              ),
              onPressed: () => _handleApply(false)),
          Gaps.hGap10,
          TextButton(
              child: Text('忽略'),
              onPressed: () async {
                Utils.showDefaultLoading(thisContext);
                Result r = await MessageAPI.ignoreThisMessage(message.id);
                Utils.closeLoading(thisContext);
                if (r.isSuccess) {
                  setState(() {
                    this.message.readStatus = ReadStatus.IGNORED;
                  });
                } else {
                  ToastUtil.showToast(thisContext, r.message);
                }
              }),
        ],
      );
    }
    return Gaps.empty;
  }

  void _handleGoAccount(Account account) {
    if (account == null) {
      return null;
    }
    NavigatorUtils.goAccountProfile2(thisContext ?? Application.context, account);
  }

  void _handleGoCircleHome(int circleId) {
    CircleApi.queryCircleDetail(circleId).then((resCircle) {
      if (resCircle != null) {
        Navigator.push(thisContext ?? Application.context,
            MaterialPageRoute(builder: (context) => CircleHome(resCircle, circleId: circleId)));
      }
    });
  }

  Widget _renderBtn(Icon icon, String text, Color textColor, Function onTap) {
    return InkWell(
      splashColor: textColor,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
            color: isDark ? ColorConstant.TWEET_RICH_BG_DARK : ColorConstant.TWEET_RICH_BG,
            borderRadius: BorderRadius.circular(6.0)),
        child: Row(
          children: [icon, Gaps.hGap5, Text('$text', style: pfStyle.copyWith(color: textColor))],
        ),
      ),
    );
  }

  TextStyle _getClickTextStyle() {
    return MyDefaultTextStyle.getTweetNickStyle(Dimens.font_sp15, context: thisContext, bold: false)
        .copyWith(color: isDark ? Colors.grey : Color(0xff6C7B8B));
  }

  void _handleApply(bool agree) {
    Utils.showDefaultLoadingWithBounds(thisContext, text: '正在处理');
    CircleApi.handleCircleApply(message.approval.id, message.id, agree).then((res) {
      Utils.closeLoading(thisContext);
      if (res.isSuccess) {
        setState(() {
          dynamic msgJson = res.data;
          CircleSystemMessage csmn = CircleSystemMessage.fromJson(msgJson);
          setState(() {
            message = csmn;
          });
        });
      } else {
        ToastUtil.showToast(thisContext, res.message);
      }
    });
  }
}
