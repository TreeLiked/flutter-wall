import 'package:flustars/flustars.dart' as prefix0;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/my_button.dart';
import 'package:iap_app/component/text_field.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/page/login/reg_temp.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/login_router.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _SMSLoginPageState createState() => _SMSLoginPageState();
}

class _SMSLoginPageState extends State<LoginPage> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _vCodeController = TextEditingController();
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  bool _isClick = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_verify);
    _vCodeController.addListener(_verify);
  }

  void _verify() {
    String name = _phoneController.text;
    String vCode = _vCodeController.text;
    bool isClick = true;
    if (name.isEmpty || name.length < 11) {
      isClick = false;
    }
    if (vCode.isEmpty || vCode.length < 6) {
      isClick = false;
    }
    if (isClick != _isClick) {
      setState(() {
        _isClick = isClick;
      });
    }
  }

  void _login() {
    Utils.showDefaultLoadingWithBounds(context, text: '正在更新');
    MemberApi.login(_phoneController.text).then((res) async {
      if (res.isSuccess && res.code == "1") {
        // 已经存在账户，直接登录
        String token = res.message;
        // 设置token
        prefix0.SpUtil.putString(SharedConstant.LOCAL_ACCOUNT_TOKEN, token);
        _loadStorageTweetTypes();
        // 获取账户信息
        Account acc = await MemberApi.getMyAccount(token);
        // 绑定账户数据到本地账户数据提供器
        AccountLocalProvider accountLocalProvider =
            Provider.of<AccountLocalProvider>(context);
        accountLocalProvider.setAccount(acc);
        Application.setAccount(acc);
        Application.setAccountId(acc.id);
        NavigatorUtils.goBack(context);
        // 页面跳转到首页
        NavigatorUtils.push(context, Routes.index, clearStack: true);
      } else {
        RegTemp.regTemp.phone = _phoneController.text;
        NavigatorUtils.goBack(context);
        NavigatorUtils.push(context, LoginRouter.loginInfoPage);
      }
    });
  }

  Future<void> _loadStorageTweetTypes() async {
    TweetTypesFilterProvider tweetTypesFilterProvider =
        Provider.of<TweetTypesFilterProvider>(context);
    tweetTypesFilterProvider.updateTypeNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(isBack: false),
        body: defaultTargetPlatform == TargetPlatform.iOS
            ? FormKeyboardActions(
                child: _buildBody(),
              )
            : SingleChildScrollView(
                child: _buildBody(),
              ));
  }

  _buildBody() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            "修改绑定手机号",
            style: TextStyles.textBold26,
          ),
          Gaps.vGap16,
          MyTextField(
            focusNode: _nodeText1,
            config: Utils.getKeyboardActionsConfig(
                context, [_nodeText1, _nodeText2]),
            controller: _phoneController,
            maxLength: 11,
            keyboardType: TextInputType.phone,
            hintText: "请输入手机号",
          ),
          Gaps.vGap8,
          MyTextField(
            focusNode: _nodeText2,
            controller: _vCodeController,
            maxLength: 6,
            keyboardType: TextInputType.number,
            hintText: "请输入验证码",
            getVCode: () async {
              Utils.showDefaultLoadingWithBounds(context);
              Result res = await MemberApi.sendPhoneVerificationCode(
                  _phoneController.text);
              NavigatorUtils.goBack(context);
              if (res.isSuccess) {
                ToastUtil.showToast(context, '发送成功');
                return Future.value(true);
              } else {
                ToastUtil.showToast(context, res.message);
                return Future.value(false);
              }
            },
          ),
          Gaps.vGap50,
          MyButton(
            onPressed: _isClick ? _login : null,
            text: "完成",
          )
        ],
      ),
    );
  }
}
