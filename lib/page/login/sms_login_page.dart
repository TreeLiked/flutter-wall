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
    // Toast.show("去登录......");
    Utils.showDefaultLoading(context);
    // MemberApi.checkVerificationCode(
    //         _phoneController.text, _vCodeController.text)
    //     .then((res) async {
    //   if (res.isSuccess) {
    MemberApi.login(_phoneController.text).then((res) async {
      if (res.isSuccess && res.code == "1") {
        // 已经存在账户，直接登录
        String token = res.message;
        // 设置token
        prefix0.SpUtil.putString(SharedConstant.LOCAL_ACCOUNT_TOKEN, token);
        _loadStorageTweetTypes();
        Account acc = await MemberApi.getMyAccount(token);
        AccountLocalProvider accountLocalProvider =
            Provider.of<AccountLocalProvider>(context);
        accountLocalProvider.setAccount(acc);
        print(accountLocalProvider.account.toJson());
        Application.setAccount(acc);
        Application.setAccountId(acc.id);
        NavigatorUtils.goBack(context);
        NavigatorUtils.push(context, Routes.index, clearStack: true);
      } else {
        RegTemp.regTemp.phone = _phoneController.text;
        NavigatorUtils.goBack(context);
        NavigatorUtils.push(context, LoginRouter.loginInfoPage);
      }
      // });
      //     } else {
      //       NavigatorUtils.goBack(context);
      //       RegTemp.regTemp.phone = '';
      //       ToastUtil.showToast(context, '您输入的验证码有误');
      // }
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
            "登录丨注册",
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
            // onChange: (String val) {
            //   if (val != null) {
            //     if (val.length == 4) {
            //       _phoneController.text =
            //           val.substring(0, 3) + " " + val.substring(3);
            //       return;
            //     }
            //     if (val.length == 8) {
            //       _phoneController.text = val.substring(0, 3) +
            //           " " +
            //           val.substring(3, 7) +
            //           " " +
            //           val.substring(7);
            //       return;
            //     }
            //   }
            // },
          ),
          Gaps.vGap8,
          MyTextField(
            focusNode: _nodeText2,
            controller: _vCodeController,
            maxLength: 6,
            keyboardType: TextInputType.number,
            hintText: "请输入验证码",
            getVCode: () async {
              Utils.showDefaultLoadingWithBonuds(context);
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
          Gaps.vGap8,
          // Container(
          //     alignment: Alignment.centerLeft,
          //     child: GestureDetector(
          //       child: RichText(
          //         text: TextSpan(
          //           text: '提示：未注册账号的手机号，请先',
          //           style: Theme.of(context).textTheme.subtitle.copyWith(fontSize: 14.0),
          //           children: <TextSpan>[
          //             TextSpan(text: '注册', style: TextStyle(color: Theme.of(context).errorColor)),
          //             TextSpan(text: '。'),
          //           ],
          //         ),
          //       ),
          //       onTap: (){
          //         NavigatorUtils.push(context, LoginRouter.registerPage);
          //       },
          //     )
          // ),
          Gaps.vGap15,
          Gaps.vGap10,
          MyButton(
            onPressed: _isClick ? _login : null,
            text: "登录",
          ),
          // Container(
          //   height: 40.0,
          //   alignment: Alignment.centerRight,
          //   child: GestureDetector(
          //     child: Text(
          //       '忘记密码',
          //       style: Theme.of(context).textTheme.subtitle,
          //     ),
          //     onTap: (){
          //       NavigatorUtils.push(context, LoginRouter.resetPasswordPage);
          //     },
          //   ),
          // )
        ],
      ),
    );
  }
}
