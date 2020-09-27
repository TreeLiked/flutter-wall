import 'dart:async';

import 'package:city_pickers/city_pickers.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/click_item.dart';
import 'package:iap_app/common-widget/dialog/radio_sel_dialog.dart';
import 'package:iap_app/common-widget/radio_item.dart';
import 'package:iap_app/common-widget/simple_confirm.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/account_edit_param.dart';
import 'package:iap_app/model/account/account_profile.dart';
import 'package:iap_app/model/gender.dart';
import 'package:iap_app/model/result.dart' as prefix1;
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/routes/setting_router.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';

class AccountPrivateInfoPage extends StatefulWidget {
  @override
  _AccountPrivateInfoPageState createState() => _AccountPrivateInfoPageState();
}

class _AccountPrivateInfoPageState extends State<AccountPrivateInfoPage> {
  AccountProfile _profile;

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
    _getAccountProfileTask = _getAccountProfile();
    _getAccountProfile();
  }

  Future<Account> _getAccountProfile() async {
    Account acc = await MemberApi.getAccountProfile(Application.getAccountId);
    return acc;
  }

  @override
  Widget build(BuildContext context) {
    // Utils.showDefaultLoading(context);
    return Scaffold(
        appBar: MyAppBar(
            centerTitle: "公开信息",
            actionName: "说明",
            onPressed: () {
              Utils.displayDialog(
                  context,
                  SimpleConfirmDialog(
                      '公开信息说明', '您可以对所有的信息进行编辑，我们会确保这些信息不被泄漏。\n或者您可以在隐私设置中选择哪些信息公开在个人资料页面。'));
            }),
        body: _profileFutureContainer());
  }

  Widget _profileFutureContainer() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: FutureBuilder<Account>(
          builder: (context, AsyncSnapshot<Account> async) {
            if (async.connectionState == ConnectionState.active ||
                async.connectionState == ConnectionState.waiting) {
              return Container(
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
                Account accWithProfile = async.data;
                this._profile = accWithProfile.profile;
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
            title: "姓名",
            content: _profile.name ?? _unSetText,
            onTap: () {
              NavigatorUtils.pushResult(
                  context,
                  Routes.inputTextPage +
                      Utils.packConvertArgs({
                        'title': '修改姓名',
                        'hintText': _profile.name ?? _unSetText,
                        'limit': 10,
                        'showLimit': false
                      }), (res) {
                if (!StringUtil.isEmpty(res.toString())) {
                  String content = res.toString().trim();
                  if (content.length <= 10) {
                    _updateSomething(AccountEditParam(AccountEditKey.NAME, content), (success) {
                      setState(() {
                        // provider.account.nick = content;
                        _profile.name = content;
                      });
                    });
                  } else {
                    ToastUtil.showToast(context, '姓名格式错误');
                  }
                } else {
                  ToastUtil.showToast(context, '姓名格式错误');
                }
              });
            }),
        ClickItem(
            title: "地区",
            content: _getAccountPCD(_profile.province, _profile.city, _profile.district),
            onTap: () async {
              Result result = await CityPickers.showFullPageCityPicker(
                context: context,
                // height: Application.screenHeight * 0.25,
              );
              if (result == null) {
                return;
              }
              bool update = false;
              if (result.provinceName != _profile.province) {
                update = true;
                _updateSomething(AccountEditParam(AccountEditKey.PROVINCE, result.provinceName), (boolres1) {
                  if (boolres1) {
                    if (!boolres1) {
                      ToastUtil.showToast(context, '修改失败');
                      return;
                    } else {
                      setState(() {
                        _profile.province = result.provinceName;
                      });
                    }
                  }
                }, showLoading: false);
              }
              if (result.cityName != _profile.city) {
                update = true;

                _updateSomething(AccountEditParam(AccountEditKey.CITY, result.cityName), (boolres1) {
                  if (boolres1) {
                    if (!boolres1) {
                      ToastUtil.showToast(context, '修改失败');
                      return;
                    } else {
                      setState(() {
                        _profile.city = result.cityName;
                      });
                    }
                  }
                }, showLoading: false);
              }
              if (result.areaName != _profile.district) {
                update = true;
                _updateSomething(AccountEditParam(AccountEditKey.DISTRICT, result.areaName), (boolres1) {
                  if (boolres1) {
                    if (!boolres1) {
                      ToastUtil.showToast(context, '修改失败');
                      return;
                    } else {
                      setState(() {
                        _profile.district = result.areaName;
                      });
                    }
                  }
                }, showLoading: false);
              }
              if (update) {
                ToastUtil.showToast(context, '修改成功');
              }
            }),
        ClickItem(
          title: '性别',
          content: _profile.gender == null ? Gender.UNKNOWN.zhTag : genderMap[_profile.gender].zhTag,
          onTap: () {
            showElasticDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return RadioSelectDialog(
                    initRadioItemKey: _profile.gender,
                    items: genderMap.entries
                        .map((f) => RadioItem(key: f.value.name, value: f.value.zhTag))
                        .toList(),
                    title: '选择您的性别',
                    onPressed: (key, value) {
                      // _sendType = i;
                      if (_profile.gender != key) {
                        _updateSomething(AccountEditParam(AccountEditKey.GENDER, key), (boolres) {
                          if (boolres) {
                            setState(() {
                              _profile.gender = key;
                            });
                          }
                        });
                      }
                    },
                  );
                });
          },
        ),
        ClickItem(
          title: '生日',
          maxLines: 1,
          content: _profile.birthday == null
              ? _unSetText
              : DateUtil.formatDate(_profile.birthday, format: DateFormats.y_mo_d),
          onTap: () {
            DatePicker.showDatePicker(context,
                theme: DatePickerTheme(
                    cancelStyle: Theme.of(context).textTheme.title.copyWith(fontSize: Dimens.font_sp16),
                    backgroundColor: ThemeUtils.isDark(context)
                        ? ColorConstant.DEFAULT_BAR_BACK_COLOR_DARK
                        : ColorConstant.DEFAULT_BAR_BACK_COLOR,
                    itemStyle: Theme.of(context).textTheme.title.copyWith(fontSize: Dimens.font_sp16)),
                showTitleActions: true,
                currentTime: _profile.birthday == null ? DateTime.now() : _profile.birthday,
                locale: LocaleType.zh,
                minTime: DateTime(1900, 1, 1),
                maxTime: DateTime.now(), onConfirm: (date) {
              print(date);
              String dateFormat = DateUtil.formatDate(date, format: DateFormats.full);
              print(dateFormat);
              _updateSomething(AccountEditParam(AccountEditKey.BIRTHDAY, dateFormat), (boolres) {
                if (boolres) {
                  setState(() {
                    _profile.birthday = date;
                  });
                } else {
                  ToastUtil.showToast(context, '更新失败');
                }
              });
              setState(() {
                _profile.birthday = date;
              });
            });
          },
        ),
        ClickItem(
            title: "QQ",
            content: _profile.qq ?? _unSetText,
            onTap: () {
              NavigatorUtils.pushResult(
                  context,
                  Routes.inputTextPage +
                      Utils.packConvertArgs({
                        'title': '修改个人资料[QQ]',
                        'hintText': _profile.qq ?? _unSetText,
                        'limit': 15,
                        'showLimit': false,
                        'kt': 1
                      }), (res) {
                if (!StringUtil.isEmpty(res.toString())) {
                  String content = res.toString().trim();
                  if (content.length <= 15) {
                    _updateSomething(AccountEditParam(AccountEditKey.QQ, content), (success) {
                      setState(() {
                        _profile.qq = content;
                      });
                    });
                  } else {
                    ToastUtil.showToast(context, 'QQ格式错误');
                  }
                } else {
                  ToastUtil.showToast(context, 'QQ格式错误');
                }
              });
            }),
        ClickItem(
            title: "微信",
            content: _profile.wechat ?? _unSetText,
            onTap: () {
              NavigatorUtils.pushResult(
                  context,
                  Routes.inputTextPage +
                      Utils.packConvertArgs({
                        'title': '修改个人资料[微信]',
                        'hintText': _profile.wechat ?? _unSetText,
                        'limit': 64,
                        'showLimit': false
                      }), (res) {
                if (!StringUtil.isEmpty(res.toString())) {
                  String content = res.toString().trim();
                  if (content.length <= 64) {
                    _updateSomething(AccountEditParam(AccountEditKey.WECHAT, content), (success) {
                      setState(() {
                        _profile.wechat = content;
                      });
                    });
                  } else {
                    ToastUtil.showToast(context, '微信格式错误');
                  }
                } else {
                  ToastUtil.showToast(context, '微信格式错误');
                }
              });
            }),
        ClickItem(
            title: "学校信息",
            onTap: () {
              NavigatorUtils.push(context, SettingRouter.accountSchoolInfoPage);
            }),
      ],
    );
  }

  _getAccountPCD(String province, String city, String district) {
    if (StringUtil.isEmpty(province)) {
      return _unSetText;
    } else {
      if (StringUtil.isEmpty(city)) {
        return province;
      } else {
        if (StringUtil.isEmpty(district)) {
          return province + " - " + city;
        } else {
          return province + " - " + city + " - " + district;
        }
      }
    }
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
