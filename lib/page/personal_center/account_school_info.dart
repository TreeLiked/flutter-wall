import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/click_item.dart';
import 'package:iap_app/common-widget/simple_confirm.dart';
import 'package:iap_app/model/account/account_edit_param.dart';
import 'package:iap_app/model/account/school/account_campus_profile.dart';
import 'package:iap_app/model/account/school/institute.dart';
import 'package:iap_app/model/result.dart' as prefix1;
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/routes/setting_router.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/toast_util.dart';

class AccountSchoolInfoPage extends StatefulWidget {
  @override
  _AccountSchoolInfoPageState createState() => _AccountSchoolInfoPageState();
}

class _AccountSchoolInfoPageState extends State<AccountSchoolInfoPage> {
  AccountCampusProfile _profile;

  Future _getAccountProfileTask;

  String _unSetText = "未设置";

  @override
  void dispose() {
    _getAccountProfileTask = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getAccountProfileTask = _getAccountCampusProfile();
  }

  Future<AccountCampusProfile> _getAccountCampusProfile() async {
    AccountCampusProfile profile = await MemberApi.getAccountCampusProfile(Application.getAccountId);
    return profile;
  }

  @override
  Widget build(BuildContext context) {
    // Utils.showDefaultLoading(context);
    return Scaffold(
        appBar: MyAppBar(
            centerTitle: "学校信息",
            actionName: "说明",
            onPressed: () {
              Utils.displayDialog(
                  context,
                  SimpleConfirmDialog(
                      '学校信息说明', '您可以对所在学校信息进行编辑，我们会确保这些信息不被泄。\n或者您可以在隐私设置中选择哪些信息公开在个人资料页面。'));
            }),
        body: _profileFutureContainer());
  }

  Widget _profileFutureContainer() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: FutureBuilder<AccountCampusProfile>(
          builder: (context, AsyncSnapshot<AccountCampusProfile> async) {
            if (async.connectionState == ConnectionState.active ||
                async.connectionState == ConnectionState.waiting) {
              return new Container(
                child: SpinKitThreeBounce(
                  color: Colors.lightBlue,
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
                AccountCampusProfile campusProfile = async.data;
                this._profile = campusProfile;
                return _renderProfileContainer();
              }
            }
            return Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.only(top: 50.0),
                child: Text("暂无可设置的资料", style: const TextStyle(fontSize: Dimens.font_sp16)));
          },
          future: _getAccountProfileTask),
    );
    // list.addAll(_getReplyList());
  }

  Widget _renderProfileContainer() {
    return Column(
      children: <Widget>[
        ClickItem(
            title: "学院",
            content: _profile.institute != null ? _getDisplayText(_profile.institute.name) : _unSetText,
            onTap: () {
              NavigatorUtils.pushResult(context, SettingRouter.accountSchoolInstitutePage, (res) {
                if (res != null) {
                  _updateSomething(
                      AccountEditParam(AccountEditKey.INSTITUTE, (res as Institute).id.toString()),
                      (success) {
                    setState(() {
                      _profile.institute = res;
                    });
                  });
                }
              });
            }),
        ClickItem(
            title: "专业",
            content: _getDisplayText(_profile.major),
            onTap: () async {
              NavigatorUtils.pushResult(
                  context,
                  Routes.inputTextPage +
                      Utils.packConvertArgs({
                        'title': '修改专业信息',
                        'hintText': _getHintText(_profile.major, '如：网络工程'),
                        'limit': 16,
                        'showLimit': true,
                        'url': Api.API_BLUR_QUERY_MAJOR,
                        'key': 'majorName',
                      }), (res) {
                if (!StringUtil.isEmpty(res.toString())) {
                  String content = res.toString().trim();
                  if (content.length <= 16) {
                    _updateSomething(AccountEditParam(AccountEditKey.MAJOR, content), (success) {
                      setState(() {
                        _profile.major = content;
                      });
                    });
                  } else {
                    ToastUtil.showToast(context, '专业信息格式错误');
                  }
                } else {
                  ToastUtil.showToast(context, '专业信息格式错误');
                }
              });
            }),
        ClickItem(
            title: "年级",
            content: _getDisplayText(_profile.grade),
            onTap: () async {
              NavigatorUtils.pushResult(
                  context,
                  Routes.inputTextPage +
                      Utils.packConvertArgs({
                        'title': '修改年级信息',
                        'hintText': _getHintText(_profile.grade, '如：2016'),
                        'limit': 4,
                        'showLimit': true,
                        'kt': 1
                      }), (res) {
                if (!StringUtil.isEmpty(res.toString())) {
                  String content = res.toString().trim();
                  if (content.length <= 4) {
                    _updateSomething(AccountEditParam(AccountEditKey.GRADE, content), (success) {
                      setState(() {
                        _profile.grade = content;
                      });
                    });
                  } else {
                    ToastUtil.showToast(context, '年级信息格式错误');
                  }
                } else {
                  ToastUtil.showToast(context, '年级信息格式错误');
                }
              });
            }),
        ClickItem(
            title: "班级",
            content: _getDisplayText(_profile.cla),
            onTap: () async {
              NavigatorUtils.pushResult(
                  context,
                  Routes.inputTextPage +
                      Utils.packConvertArgs({
                        'title': '修改班级信息',
                        'hintText': _getHintText(_profile.cla, '如：计算机嵌入161'),
                        'limit': 32,
                        'showLimit': true
                      }), (res) {
                if (!StringUtil.isEmpty(res.toString())) {
                  String content = res.toString().trim();
                  if (content.length <= 32) {
                    _updateSomething(AccountEditParam(AccountEditKey.CLA, content), (success) {
                      setState(() {
                        _profile.cla = content;
                      });
                    });
                  } else {
                    ToastUtil.showToast(context, '班级信息格式错误');
                  }
                } else {
                  ToastUtil.showToast(context, '班级信息格式错误');
                }
              });
            }),
        ClickItem(
            title: "学号",
            content: _getDisplayText(_profile.stuId),
            onTap: () async {
              NavigatorUtils.pushResult(
                  context,
                  Routes.inputTextPage +
                      Utils.packConvertArgs({
                        'title': '修改学号信息',
                        'hintText': _getHintText(_profile.stuId, '如：202160826'),
                        'limit': 16,
                        'showLimit': false,
                        'kt': 1
                      }), (res) {
                if (!StringUtil.isEmpty(res.toString())) {
                  String content = res.toString().trim();
                  if (content.length <= 16) {
                    _updateSomething(AccountEditParam(AccountEditKey.STU_ID, content), (success) {
                      setState(() {
                        _profile.stuId = content;
                      });
                    });
                  } else {
                    ToastUtil.showToast(context, '班级信息格式错误');
                  }
                } else {
                  ToastUtil.showToast(context, '班级信息格式错误');
                }
              });
            }),
      ],
    );
  }

  String _getDisplayText(val) {
    if (StringUtil.isEmpty(val)) {
      return _unSetText;
    }
    return val;
  }

  String _getHintText(val, hint) {
    if (StringUtil.isEmpty(val)) {
      return hint;
    }
    return val;
  }

  Future<void> _updateSomething(AccountEditParam param, final callback, {bool showLoading = true}) async {
    if (showLoading) {
      Utils.showDefaultLoadingWithBounds(context, text: "正在更新");
    }
    prefix1.Result r = await MemberApi.modAccount(param);
    if (r != null && r.isSuccess) {
      callback(true);
    } else {
      ToastUtil.showToast(context, '修改失败，请稍候重试');
    }
    if (showLoading) {
      Navigator.pop(context);
    }
  }
}
