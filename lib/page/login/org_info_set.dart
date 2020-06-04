import 'dart:async';

import 'package:flustars/flustars.dart' as prefix0;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/bezier_bounce_footer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/api/univer.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/result_code.dart';
import 'package:iap_app/model/university.dart';
import 'package:iap_app/page/login/reg_temp.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/login_router.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/http_util.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:provider/provider.dart';

class OrgInfoCPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrgInfoCPageState();
  }
}

class _OrgInfoCPageState extends State<OrgInfoCPage> {
  List<University> filterList = [];

  TextEditingController _controller;
  Future _queryUnTask;

  bool _haveChoice = false;
  int _cId;
  String _cName = "";

  Duration durationTime = Duration(seconds: 1);

  // 防抖函数
  Timer timer;

  @override
  void initState() {
    super.initState();
    // List.copyRange(filterList, 0, _orgList);
    _controller = TextEditingController();
    _queryUnTask = queryUnis("");
  }

  Future<List<University>> queryUnis(String name) async {
    // await Future.delayed(Duration(seconds: 3));

    return await UniversityApi.blurQueryUnis(name.trim());
  }

  _finishAll() async {
    Utils.showDefaultLoadingWithBounds(context, text: '正在生成');
    RegTemp.regTemp.orgId = _cId;
    RegTemp rt = RegTemp.regTemp;
    Result res = await MemberApi.register(rt.phone, rt.nick, rt.avatarUrl, rt.orgId, rt.invitationCode);

    if (res != null && res.isSuccess) {
      String token = res.data;
      await prefix0.SpUtil.putString(SharedConstant.LOCAL_ACCOUNT_TOKEN, token);
      await prefix0.SpUtil.putInt(SharedConstant.LOCAL_ORG_ID, _cId);
      await prefix0.SpUtil.putString(SharedConstant.LOCAL_ORG_NAME, _cName);
      Application.setLocalAccountToken(token);
      httpUtil.updateAuthToken(token);
      httpUtil2.updateAuthToken(token);

      Account acc = await MemberApi.getMyAccount(token);
      if (acc == null) {
        ToastUtil.showToast(context, TextConstant.TEXT_SERVICE_ERROR);
        NavigatorUtils.goBack(context);
        return;
      }
      AccountLocalProvider accountLocalProvider = Provider.of<AccountLocalProvider>(context);
      accountLocalProvider.setAccount(acc);
      _loadStorageTweetTypes();
      Application.setAccount(acc);
      Application.setAccountId(acc.id);
      Application.setOrgId(_cId);
      Application.setOrgName(_cName);
      NavigatorUtils.goBack(context);
      NavigatorUtils.push(context, Routes.splash, clearStack: true);
    } else {
      NavigatorUtils.goBack(context);
      if (res != null) {
        print(res.toString());

        if (res.code == MemberResultCode.UN_REGISTERED_PHONE) {
          ToastUtil.showToast(context, '该手机号已被注册，请登录');
          await Future.delayed(Duration(seconds: 1)).then((_) {
            NavigatorUtils.push(context, LoginRouter.loginIndex, clearStack: true);
          });
          return;
        }
        if (res.code == MemberResultCode.ERROR_REGISTER) {
          ToastUtil.showToast(context, '注册失败');
          NavigatorUtils.push(context, LoginRouter.loginIndex, clearStack: true);
          return;
        }

        if (res.code == MemberResultCode.INVALID_INVOCATION_CODE) {
          ToastUtil.showToast(context, '邀请码无效');
          NavigatorUtils.push(context, LoginRouter.loginIndex, clearStack: true);
          return;
        }

        if (res.code == MemberResultCode.ERROR_NICK_EXISTED) {
          ToastUtil.showToast(context, '昵称已存在');
          NavigatorUtils.push(context, LoginRouter.loginIndex, clearStack: true);
          return;
        }

        if (res.code == MemberResultCode.ERROR_NICK_EXISTED) {
          ToastUtil.showToast(context, '昵称已存在');
          NavigatorUtils.push(context, LoginRouter.loginIndex, clearStack: true);
          return;
        }
        ToastUtil.showServiceExpToast(context);
        NavigatorUtils.push(context, LoginRouter.loginIndex, clearStack: true);
      }
    }
  }

  Future<void> _loadStorageTweetTypes() async {
    TweetTypesFilterProvider tweetTypesFilterProvider = Provider.of<TweetTypesFilterProvider>(context);
    tweetTypesFilterProvider.updateTypeNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          centerTitle: '选择大学',
          actionName: '完成',
          onPressed: _haveChoice ? _finishAll : null,
        ),
        body: !_haveChoice
            ? Column(
                children: <Widget>[
                  Gaps.vGap16,
                  Container(
//                    height: ScreenUtil().setHeight(80),
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: ThemeUtils.isDark(context) ? Color(0xff363636) : Color(0xfff2f2f2),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: Dimens.gap_dp5),
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) async {
                        setState(() {
                          _queryUnTask = queryUnis(_controller.text);
                        });
                      },
                      onChanged: (val) async {
                        setState(() {
                          timer?.cancel();
                          timer = new Timer(durationTime, () {
                            setState(() {
                              _queryUnTask = queryUnis(val);
                            });
                          });
                        });
                      },
                      style: TextStyles.textBold14,
                      decoration: InputDecoration(
                          hintText: '输入大学以搜索，英文缩写也可以哦',
                          hintStyle: TextStyles.textGray14,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          suffixIcon: GestureDetector(
                            child: Icon(
                              Icons.clear,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              _controller.clear();
                              setState(() {
                                _queryUnTask = queryUnis("");
                              });
                            },
                          ),
//                          filled: true,
//                          fillColor: Color(0xfff5f6f7),
                          border: InputBorder.none),
                      maxLines: 1,
                    ),
                  ),
                  Expanded(
                      child: Container(
                          margin: EdgeInsets.all(0),
                          padding: EdgeInsets.all(0),
                          child: FutureBuilder<List<University>>(
                              builder: (context, AsyncSnapshot<List<University>> async) {
                                //在这里根据快照的状态，返回相应的widget
                                if (async.connectionState == ConnectionState.active ||
                                    async.connectionState == ConnectionState.waiting) {
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 500
//                                    ScreenUtil().setHeight(500)
                                        ),
                                    child: new SpinKitThreeBounce(
                                      color: Colors.lightGreen,
                                      size: 18,
                                    ),
                                  );
                                }
                                if (async.connectionState == ConnectionState.done) {
                                  if (async.hasError) {
                                    return new Center(
                                      child: new Text("${async.error}"),
                                    );
                                  } else if (async.hasData) {
                                    List<University> list = async.data;
                                    // setState(() {
                                    //   filterList = list;
                                    // });
                                    if (list == null || list.length == 0) {
                                      return Padding(
//                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.only(top: 37),
                                          child: Text('没有满足条件的数据', style: TextStyles.textGray14));
                                    }

                                    return ListView.builder(
                                        itemCount: list.length,
                                        itemBuilder: (context, index) {
                                          return new ListTile(
                                            onTap: () {
                                              // list[index].
                                              setState(() {
                                                _haveChoice = true;
                                                _cName = list[index].name;
                                                _cId = list[index].id;
                                              });
                                            },
                                            title: new Text(list[index].name),
                                          );
                                        });
                                  }
                                }
                                return Gaps.empty;
                              },
                              future: _queryUnTask)))
                ],
              )
            : Container(
                margin: EdgeInsets.only(
                    top:
//                ScreenUtil().setHeight(200)
                        100),
                width: double.infinity,
                height: 100,
//                height: ScreenUtil().setHeight(100),
                alignment: Alignment.center,
                child: RichText(
                  softWrap: true,
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(
                        text: '您已经选择：', style: TextStyle(color: Colors.black, fontSize: Dimens.font_sp15)),
                    TextSpan(
                        text: '$_cName\n\n',
                        style: TextStyle(color: Colors.black, fontSize: Dimens.font_sp15)),
                    TextSpan(
                      text: '重新选择',
                      style: TextStyle(color: Theme.of(context).accentColor, fontSize: Dimens.font_sp15),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          setState(() {
                            _haveChoice = false;
                          });
                        },
                    )
                  ]),
                )));
  }
}
