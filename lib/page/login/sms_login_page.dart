import 'dart:async';

import 'package:flustars/flustars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as prefix2;
import 'package:iap_app/api/api.dart';
import 'package:iap_app/api/invite.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/api/univer.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/component/text_field.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/result_code.dart';
import 'package:iap_app/model/university.dart';
import 'package:iap_app/page/login/reg_temp.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/theme_provider.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/login_router.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/http_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/version_utils.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _SMSLoginPageState createState() => _SMSLoginPageState();
}

class _SMSLoginPageState extends State<LoginPage> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _vCodeController = TextEditingController();
  TextEditingController _iCodeController = TextEditingController();

  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final FocusNode _nodeText3 = FocusNode();

  bool _canGetCode = false;
  bool _codeWaiting = false;

  bool _showCodeInput = false;
  bool _showInvitationCodeInput = false;

  /// 倒计时秒数
  final int second = 90;

  /// 当前秒数
  int s;
  StreamSubscription _subscription;

  bool isDark = false;

  @override
  void initState() {
    super.initState();
    isDark = false;
    VersionUtils.checkUpdate().then((result) {
      if (result != null) {
        VersionUtils.displayUpdateDialog(result, slient: true);
      }
    });
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

  void _verifyInvitationCode(String val) async {
    String phone = _phoneController.text;
    String vCode = _vCodeController.text;
    String iCode = _iCodeController.text;
    if (phone.isEmpty ||
        phone.length < 11 ||
        iCode.isEmpty ||
        iCode.length != 6 ||
        vCode.isEmpty ||
        vCode.length != 6) {
      return;
    }
    await InviteAPI.checkCodeValid(iCode).then((res) {
      if (res != null && res.isSuccess) {
        RegTemp.regTemp.invitationCode = iCode;
        _login();
      } else {
        ToastUtil.showToast(context, '无效的邀请码');
      }
    });
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
      if (res.isSuccess) {
        // 已经存在账户，直接登录
        String token = res.data ?? res.message;
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
        // 绑定账户信息到本地账户数据提供器
        AccountLocalProvider accountLocalProvider = Provider.of<AccountLocalProvider>(context);
        accountLocalProvider.setAccount(acc);
        print(accountLocalProvider.account.toJson());
        Application.setAccount(acc);
        Application.setAccountId(acc.id);

        // 获取用户所在的大学信息
        University university = await UniversityApi.queryUnis(token);
        if (university == null) {
          // 错误，有账户无组织
          ToastUtil.showToast(context, '数据错误');
          return;
        } else {
          // 验证成功，写入用户相关信息到本地
          SpUtil.putInt(SharedConstant.LOCAL_ORG_ID, university.id);
          SpUtil.putString(SharedConstant.LOCAL_ORG_NAME, university.name);
          Application.setOrgName(university.name);
          Application.setOrgId(university.id);
        }
        _subscription?.cancel();
        // 跳转到首页
        NavigatorUtils.push(context, Routes.splash, clearStack: true);
      } else {
        if (res.code == MemberResultCode.INVALID_PHONE) {
          NavigatorUtils.goBack(context);
          ToastUtil.showToast(context, '错误的手机号，非法请求');
          return;
        }
        if (res.code == MemberResultCode.UN_REGISTERED_PHONE) {
          // 未注册流程
          NavigatorUtils.goBack(context);
          Result r = await InviteAPI.checkIsInInvitation();
          if (r.isSuccess && StringUtil.isEmpty(RegTemp.regTemp.invitationCode)) {
            // 开启内测
            setState(() {
              this._showInvitationCodeInput = true;
            });
            return;
          }
          RegTemp.regTemp.phone = _phoneController.text;
          RegTemp.regTemp.invitationCode = _iCodeController.text;
          // 跳转到个人信息页面
          NavigatorUtils.push(context, LoginRouter.loginInfoPage);
        } else {
          NavigatorUtils.goBack(context);
          if (StringUtil.isEmpty(res.message)) {
            ToastUtil.showServiceExpToast(context);
          } else {
            ToastUtil.showToast(context, res.message);
          }
        }
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
          padding: EdgeInsets.only(top: prefix2.ScreenUtil().setHeight(200)),
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
          Text("登录后即可加入Wall", style: TextStyles.textBold24),
          // Gaps.vGap5,
          // Text("与上千万大学生发掘精彩", style: TextStyles.textBold14),
          _renderSubBody(),
          Gaps.vGap30,
          Container(
            decoration: BoxDecoration(
              color: !isDark ? Color(0xfff7f8f8) : Colours.dark_bg_color_darker,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  margin: const EdgeInsets.only(right: 10),
                  child: Text('+ 86', style: TextStyles.textSize16),
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

          _showInvitationCodeInput
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _renderHit('应用内测中，请输入邀请码', color: Colors.lightGreen),
                    Container(
                        color: !isDark ? Color(0xfff7f8f8) : Colours.dark_bg_color_darker,
                        margin: const EdgeInsets.only(top: 5),
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              margin: const EdgeInsets.only(right: 10),
                              child: Text('邀请码', style: TextStyles.textSize16),
                            ),
                            Gaps.vLine,
                            Expanded(
                              child: MyTextField(
                                focusNode: _nodeText3,
                                controller: _iCodeController,
                                maxLength: 6,
                                keyboardType: TextInputType.text,
                                hintText: "请输入邀请码",
                                onChange: _verifyInvitationCode,
                              ),
                            )
                          ],
                        ))
                  ],
                )
              : Gaps.empty,
          _renderHit('未注册的手机号通过验证后将自动注册'),
          Gaps.vGap8,
          _renderGetCodeLine(),
          Gaps.vGap30,
          // _renderOtherLine(),
        ],
      ),
    );
  }

  _renderSubBody() {
    return Container(
        margin: const EdgeInsets.only(top: 15),
        child: RichText(
          softWrap: true,
          maxLines: 8,
          text: TextSpan(children: [
            TextSpan(text: "登录即表示同意 ", style: TextStyles.textGray14),
            TextSpan(
                text: "Wall服务协议",
                style: TextStyles.textClickable,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => NavigatorUtils.goWebViewPage(context, "Wall服务协议", Api.API_AGREEMENT)),
          ]),
        ));
  }

  _renderHit(String text, {Color color = Colours.text_gray, double size = Dimens.font_sp14}) {
    return Container(
        margin: const EdgeInsets.only(top: 15),
        child: Text('$text',
            style: TextStyle(
              color: color,
              fontSize: size,
            )));
  }

  _renderGetCodeLine() {
    return Container(
        width: double.infinity,
//        color: _canGetCode ? Colors.amber : (!isDark ? Color(0xffD7D6D9) : Colours.dark_bg_color_darker),
        margin: const EdgeInsets.only(top: 15),
        child: FlatButton(
          child: Text(!_codeWaiting ? '获取短信验证码' : '重新获取 $s(s)', style: TextStyle(color: Colors.white)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          color: _canGetCode
              ? Colors.amber
              : !isDark
                  ? Color(0xffD7D6D9)
                  : Colours.dark_bg_color_darker,
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          disabledColor: !isDark ? Color(0xffD7D6D9) : Colours.dark_bg_color_darker,
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
                    if (res == null) {
                      ToastUtil.showToast(context, TextConstant.TEXT_SERVICE_ERROR);
                      return;
                    }
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
                      _subscription = Stream.periodic(Duration(seconds: 1), (int i) {
                        setState(() {
                          s = second - i - 1;
                          if (s < 1) {
                            _canGetCode = true;
                            _codeWaiting = false;
                          }
                        });
                      }).take(second).listen((event) {});
                      // _subscription =
                      //     Observable.periodic(Duration(seconds: 1), (i) => i).take(second).listen((i) {
                      //       setState(() {
                      //         s = second - i - 1;
                      //         if (s < 1) {
                      //           _canGetCode = true;
                      //           _codeWaiting = false;
                      //         }
                      //       });
                      // });
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
