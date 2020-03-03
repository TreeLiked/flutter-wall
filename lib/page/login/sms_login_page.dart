import 'dart:async';

import 'package:flustars/flustars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as prefix2;
import 'package:iap_app/api/member.dart';
import 'package:iap_app/api/univer.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/component/text_field.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/university.dart';
import 'package:iap_app/page/login/reg_temp.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/theme_provider.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/login_router.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/http_util.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class LoginPage extends StatefulWidget {
  @override
  _SMSLoginPageState createState() => _SMSLoginPageState();
}

class _SMSLoginPageState extends State<LoginPage> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _vCodeController = TextEditingController();

  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();

  bool _canGetCode = false;
  bool _codeWaiting = false;

  bool _showCodeInput = false;

  /// 倒计时秒数
  final int second = 90;

  /// 当前秒数
  int s;
  StreamSubscription _subscription;

  bool isDark = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SpUtil.getInstance();
      // 由于SpUtil未初始化，所以MaterialApp获取的为默认主题配置，这里同步一下。
      Provider.of<ThemeProvider>(context).syncTheme();
    });
    _phoneController.addListener(_verifyPhone);
//    _vCodeController.addListener(_verifyCode);
  }

  void _verifyPhone() {
    if (!_codeWaiting) {
      String phone = _phoneController.text;
      bool isCodeClick = true;
      if (phone.isEmpty || phone.length < 11) {
        isCodeClick = false;
      }
      setState(() {
        this._canGetCode = isCodeClick;
      });
    }
  }

  void _verifyCode(String val) {
    String phone = _phoneController.text;
    String vCode = _vCodeController.text;
    if (phone.isEmpty || phone.length < 11 || vCode.isEmpty || vCode.length != 6) {
      return;
    }

    _login();
  }

  void _login() async {
    Utils.showDefaultLoadingWithBounds(context, text: '正在验证');
    Result r = await MemberApi.checkVerificationCode(_phoneController.text, _vCodeController.text);
    if (!r.isSuccess) {
      NavigatorUtils.goBack(context);
      ToastUtil.showToast(context, '验证码不正确');
      return;
    }
    MemberApi.login(_phoneController.text).then((res) async {
      if (res.isSuccess && res.code == "1") {
        // 已经存在账户，直接登录
        String token = res.message;
        // 设置token
        Application.setLocalAccountToken(token);
        httpUtil.updateAuthToken(token);
        httpUtil2.updateAuthToken(token);
        await SpUtil.putString(SharedConstant.LOCAL_ACCOUNT_TOKEN, token);

        _loadStorageTweetTypes();
        // 查询账户信息
        Account acc = await MemberApi.getMyAccount(token);
        if (acc == null) {
          NavigatorUtils.goBack(context);
          ToastUtil.showToast(context, '数据错误，请退出程序重试');
          return;
        }
        AccountLocalProvider accountLocalProvider = Provider.of<AccountLocalProvider>(context);
        accountLocalProvider.setAccount(acc);
        print(accountLocalProvider.account.toJson());
        Application.setAccount(acc);
        Application.setAccountId(acc.id);

        University university = await UniversityApi.queryUnis(token);
        if (university == null) {
          // 错误，有账户无组织
          print("--------------ERROR--------------");
          ToastUtil.showToast(context, '数据错误');
          return;
        } else {
          SpUtil.putInt(SharedConstant.LOCAL_ORG_ID, university.id);
          SpUtil.putString(SharedConstant.LOCAL_ORG_NAME, university.name);
          Application.setOrgName(university.name);
          Application.setOrgId(university.id);
        }
        _subscription?.cancel();
//        _phoneController?.removeListener(() {});
//        _vCodeController?.removeListener(() {});
//        NavigatorUtils.goBack(context);
        NavigatorUtils.push(context, Routes.splash, clearStack: true);
      } else {
        if (res.code == "-1") {
          NavigatorUtils.goBack(context);
          ToastUtil.showToast(context, '错误的手机号，非法请求');
          return;
        }
        RegTemp.regTemp.phone = _phoneController.text;
        NavigatorUtils.goBack(context);
        NavigatorUtils.push(context, LoginRouter.loginInfoPage);
      }
    });
  }

  Future<void> _loadStorageTweetTypes() async {
    TweetTypesFilterProvider tweetTypesFilterProvider = Provider.of<TweetTypesFilterProvider>(context);
    tweetTypesFilterProvider.updateTypeNames();
  }

  @override
  Widget build(BuildContext context) {
    isDark = ThemeUtils.isDark(context);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
          padding: EdgeInsets.only(top: prefix2.ScreenUtil().setHeight(110)),
          child: defaultTargetPlatform == TargetPlatform.iOS
              ? FormKeyboardActions(
                  child: _buildBody(),
                )
              : SingleChildScrollView(
                  child: _buildBody(),
                )),
    );
  }

  _buildBody() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("登录后即可展示自己", style: TextStyles.textBold24),
          _renderSubBody(),
          Gaps.vGap30,
          Container(
            color: !isDark ? Color(0xfff7f8f8) : Colours.dark_bg_color_darker,
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  margin: const EdgeInsets.only(right: 10),
                  child: Text('+86', style: TextStyles.textSize16),
                ),
                Gaps.vLine,
                Expanded(
                  child: MyTextField(
                    focusNode: _nodeText1,
                    controller: _phoneController,
                    maxLength: 11,
                    keyboardType: TextInputType.phone,
                    hintText: "请输入手机号",
                  ),
                )
              ],
            ),
          ),
          _showCodeInput
              ? Container(
                  color: !isDark ? Color(0xfff7f8f8) : Colours.dark_bg_color_darker,
                  margin: const EdgeInsets.only(top: 5),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        margin: const EdgeInsets.only(right: 10),
                        child: Text('验证码', style: TextStyles.textSize16),
                      ),
                      Gaps.vLine,
                      Expanded(
                        child: MyTextField(
                          focusNode: _nodeText2,
                          controller: _vCodeController,
                          maxLength: 6,
                          keyboardType: TextInputType.phone,
                          hintText: "请输入验证码",
                          onChange: _verifyCode,
                        ),
                      )
                    ],
                  ),
                )
              : Gaps.empty,
          _renderHit(),
          Gaps.vGap8,
          _renderGetCodeLine(),
          Gaps.vGap16,
//          _renderOtherLine(),
        ],
      ),
    );
  }

  _renderSubBody() {
    return Container(
        margin: const EdgeInsets.only(top: 15),
        child: RichText(
          softWrap: true,
          maxLines: 3,
          text: TextSpan(children: [
            TextSpan(text: "登录即表示同意 ", style: TextStyles.textGray14),
            TextSpan(text: "Wall用户协议", style: TextStyles.textClickable),
            TextSpan(text: " 和 ", style: TextStyles.textGray14),
            TextSpan(text: "隐私协议", style: TextStyles.textClickable),
          ]),
        ));
  }

  _renderHit() {
    return Container(
        margin: const EdgeInsets.only(top: 15),
        child: Text(
          '未注册的手机号通过验证后将自动注册',
          style: TextStyles.textGray14,
        ));
  }

  _renderGetCodeLine() {
    return Container(
        width: double.infinity,
        color: _canGetCode ? Colors.lightBlue : (!isDark ? Color(0xffD7D6D9) : Colours.dark_bg_color_darker),
        margin: const EdgeInsets.only(top: 15),
        child: FlatButton(
          child: Text(!_codeWaiting ? '获取短信验证码' : '重新获取 $s(s)', style: TextStyle(color: Colors.white)),
          onPressed: _codeWaiting
              ? null
              : () async {
                  String phone = _phoneController.text;
                  if (phone.isEmpty || phone.length < 11) {
                    ToastUtil.showToast(context, '手机号格式不正确');
                    return Future.value(false);
                  } else {
                    Utils.showDefaultLoadingWithBounds(context);
                    Result res = await MemberApi.sendPhoneVerificationCode(_phoneController.text);
                    NavigatorUtils.goBack(context);
                    if (res.isSuccess) {
                      ToastUtil.showToast(context, '发送成功');
                      _nodeText1.unfocus();
                      _nodeText2.requestFocus();
                      setState(() {
                        s = second;
                        this._showCodeInput = true;
                        this._canGetCode = false;
                        _codeWaiting = true;
                      });
                      _subscription =
                          Observable.periodic(Duration(seconds: 1), (i) => i).take(second).listen((i) {
                        setState(() {
                          s = second - i - 1;
                          if (s < 1) {
                            _canGetCode = true;
                            _codeWaiting = false;
                          }
                        });
                      });
                      return Future.value(true);
                    } else {
                      ToastUtil.showToast(context, res.message);
                      return Future.value(false);
                    }
                  }
                },
        ));
  }

  _renderOtherLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        RichText(
          softWrap: true,
          maxLines: 1,
          text: TextSpan(children: [
            TextSpan(
                text: "其他方式登录",
                style: TextStyles.textClickable,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    ToastUtil.showToast(context, '社会化登录暂未开放');
                  }),
          ]),
        )
      ],
    );
  }
}
