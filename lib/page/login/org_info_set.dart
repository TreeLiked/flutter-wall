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
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/result.dart';
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
import 'package:iap_app/util/common_util.dart';
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

  @override
  void initState() {
    super.initState();
    // List.copyRange(filterList, 0, _orgList);
    _controller = TextEditingController();
    _queryUnTask = queryUnis("");
  }

  Future<List<University>> queryUnis(String name) async {
    // await Future.delayed(Duration(seconds: 3));
    return await UniversityApi.blurQueryUnis(name);
  }

  _finishAll() async {
    Utils.showDefaultLoadingWithBonuds(context, text: '正在加载');
    RegTemp.regTemp.orgId = _cId;
    RegTemp rt = RegTemp.regTemp;
    Result res =
        await MemberApi.register(rt.phone, rt.nick, rt.avatarUrl, rt.orgId);
    if (res != null && res.isSuccess && res.code == "1") {
      String token = res.message;
      await prefix0.SpUtil.putString(SharedConstant.LOCAL_ACCOUNT_TOKEN, token);
      await prefix0.SpUtil.putInt(SharedConstant.LOCAL_ORG_ID, _cId);
      await prefix0.SpUtil.putString(SharedConstant.LOCAL_ORG_NAME, _cName);

      Account acc = await MemberApi.getMyAccount(token);
      AccountLocalProvider accountLocalProvider =
          Provider.of<AccountLocalProvider>(context);
      accountLocalProvider.setAccount(acc);
      _loadStorageTweetTypes();
      Application.setAccount(acc);
      Application.setAccountId(acc.id);
      Application.setOrgId(_cId);
      Application.setOrgName(_cName);
      NavigatorUtils.goBack(context);
      NavigatorUtils.push(context, Routes.index, clearStack: true);
    } else {
      NavigatorUtils.goBack(context);
      ToastUtil.showToast(context, '该手机号已被注册，请登录');
      Future.delayed(Duration(seconds: 2)).then((_) {
        NavigatorUtils.push(context, LoginRouter.loginIndex, clearStack: true);
      });
    }
  }

  Future<void> _loadStorageTweetTypes() async {
    TweetTypesFilterProvider tweetTypesFilterProvider =
        Provider.of<TweetTypesFilterProvider>(context);
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
                    color: ThemeUtils.isDark(context)
                        ? Color(0xff363636)
                        : Color(0xfff2f2f2),
                    height: ScreenUtil().setHeight(80),
                    margin: EdgeInsets.symmetric(horizontal: Dimens.gap_dp5),
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) async {
                        setState(() {
                          _queryUnTask = queryUnis(_controller.text);
                        });
                      },
                      decoration: InputDecoration(
                          hintText: '输入大学以搜索',
                          hintStyle: TextStyles.textGray12,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          suffixIcon: GestureDetector(
                            child: Icon(
                              Icons.clear,
                              color: Colors.grey,
                            ),
                            onTap: () => _controller.clear(),
                          ),
                          filled: true,
                          fillColor: Color(0xfff5f6f7),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 0.0, style: BorderStyle.none),
                            borderRadius: BorderRadius.circular(15),
                          )),
                      maxLines: 1,
                    ),
                  ),
                  Expanded(
                      child: Container(
                          margin: EdgeInsets.all(0),
                          padding: EdgeInsets.all(0),
                          child: FutureBuilder<List<University>>(
                              builder: (context,
                                  AsyncSnapshot<List<University>> async) {
                                //在这里根据快照的状态，返回相应的widget
                                if (async.connectionState ==
                                        ConnectionState.active ||
                                    async.connectionState ==
                                        ConnectionState.waiting) {
                                  return Container(
                                    margin: EdgeInsets.only(
                                        bottom: ScreenUtil().setHeight(500)),
                                    child: new SpinKitThreeBounce(
                                      color: Colors.lightGreen,
                                      size: 18,
                                    ),
                                  );
                                }
                                if (async.connectionState ==
                                    ConnectionState.done) {
                                  if (async.hasError) {
                                    return new Center(
                                      child: new Text("${async.error}"),
                                    );
                                  } else if (async.hasData) {
                                    List<University> list = async.data;
                                    // setState(() {
                                    //   filterList = list;
                                    // });

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
                                return Container(
                                  height: 10,
                                );
                              },
                              future: _queryUnTask)))
                ],
              )
            : Container(
                margin: EdgeInsets.only(top: ScreenUtil().setHeight(200)),
                width: double.infinity,
                height: ScreenUtil().setHeight(100),
                alignment: Alignment.center,
                child: RichText(
                  softWrap: true,
                  text: TextSpan(children: [
                    TextSpan(
                        text: '您已经选择：', style: TextStyle(color: Colors.black)),
                    TextSpan(
                        text: '$_cName，',
                        style: TextStyle(color: Colors.black)),
                    TextSpan(
                        text: '点击',
                        style: const TextStyle(color: Colors.black)),
                    TextSpan(
                      text: ' 重新选择',
                      style: TextStyle(color: Theme.of(context).accentColor),
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
