import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/api/invite.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/component/container_text.dart';
import 'package:iap_app/component/container_widget.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart';

class InvitationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InvitationPageState();
  }
}

class _InvitationPageState extends State<InvitationPage> {
  bool onInvite = false;
  bool init = true;
  Map<String, dynamic> myInvite;

  @override
  void initState() {
    super.initState();
    checkOnInvite();
  }

  checkOnInvite() {
    InviteAPI.checkIsInInvitation().then((res) async {
      if (res != null && res.isSuccess) {
        await checkMyInvitation();
        setState(() {
          this.init = false;
          this.onInvite = true;
        });
      } else {
        setState(() {
          this.init = false;
          this.onInvite = false;
        });
      }
    });
  }

  checkMyInvitation() async {
    await InviteAPI.checkMyInvitation().then((argsMap) async {
      if (argsMap != null) {
        print(argsMap);
        setState(() {
          this.myInvite = argsMap;
        });
      }
    });
  }

  refresh(BuildContext context) async {
    Utils.showDefaultLoadingWithBounds(context);
    await checkMyInvitation();
    NavigatorUtils.goBack(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        centerTitle: '我的内测',
        actionName: '刷新',
        isBack: true,
        onPressed: init ? null : () => refresh(context),
      ),
      body: SingleChildScrollView(
        child: init
            ? ContainerWidget(
                widget: WidgetUtil.getLoadingAnimation(),
              )
            : onInvite
                ? myInvite != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _simpleTitle('我的邀请码'),
                          _renderMyCode(),
                          _simpleTitle('剩余可邀请次数', topMargin: 15.0),
                          _renderLeftTimes(),
                          _simpleTitle('我的邀请', topMargin: 15.0),
                          _renderMyUsers(context),
                          _simpleTitle('注意事项', topMargin: 15.0),
                          _renderAttention(),
                        ],
                      )
                    : ContainerText(text: '服务错误', style: TextStyles.textSize14)
                : ContainerText(
                    text: '当前没有内测',
                    style: TextStyles.textSize14,
                  ),
      ),
    );
  }

  _renderMyCode() {
    String code = myInvite['icode'];
    if (code == null) {
      code = "服务异常";
    }
    return Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text(
                '$code',
                style: const TextStyle(
                    fontSize: Dimens.font_sp18, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ),
            Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Utils.copyTextToClipBoard(code);
                    ToastUtil.showToast(context, '复制成功', length: Toast.LENGTH_SHORT);
                  },
                  child: Text(
                    '复制',
                    style: const TextStyle(
                        fontSize: Dimens.font_sp14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Colors.blueAccent),
                  ),
                )),
          ],
        ));
  }

  _renderLeftTimes() {
    int left = myInvite['restTimes'] as int;
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10.0),
      child: Text(
        '$left',
        style: TextStyle(
            fontSize: Dimens.font_sp16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: left >= 7 ? Colors.blueAccent : left >= 4 ? Colors.amber : Colors.red),
      ),
    );
  }

  _renderMyUsers(BuildContext context) {
    List<dynamic> accounts = myInvite['invitees'];
    if (accounts == null || accounts.length == 0) {
      return ContainerText(
        text: '暂无用户',
        style: TextStyle(
          fontSize: Dimens.font_sp14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      );
    }
    List<Account> acc = accounts.map((f) => Account.fromJson(f)).toList();

    return Container(
        alignment: Alignment.topLeft,
        margin: const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 20.0,
          runSpacing: 21.0,
          children: acc
              .map((f) => AccountAvatar(
                    avatarUrl: f.avatarUrl,
                    whitePadding: true,
                    onTap: () => NavigatorUtils.goAccountProfile2(context, f),
                  ))
              .toList(),
        ));
  }

  Widget _renderAttention() {
    return Container(
      margin: const EdgeInsets.only(left: 15.0, top: 10.0),
      child: Text('邀请码只能用于邀请相同组织的用户，不同组织无法邀请！',
          softWrap: true, style: TextStyle(color: Colors.grey, fontSize: Dimens.font_sp13p5)),
    );
  }

  _simpleTitle(String title, {double topMargin = 0.0}) {
    return Container(
      margin: EdgeInsets.only(left: 15.0, top: topMargin),
      child: Text('$title', style: TextStyles.textGray14),
    );
  }
}
