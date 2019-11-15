import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/click_item.dart';
import 'package:iap_app/common-widget/simple_confirm.dart';
import 'package:iap_app/common-widget/text_clickable_iitem.dart';
import 'package:iap_app/component/bottom_sheet_choic_item.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account/account_edit_param.dart';
import 'package:iap_app/model/gender.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/page/common/image_crop.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/fluro_convert_utils.dart';
import 'package:iap_app/util/image_utils.dart';
import 'package:iap_app/util/oss_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class AccountInfoPage extends StatefulWidget {
  @override
  _AccountInfoPageState createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  @override
  void dispose() {
    super.dispose();
  }

  String filePath = "";
  @override
  Widget build(BuildContext context) {
    return Consumer<AccountLocalProvider>(builder: (_, provider, __) {
      return Scaffold(
        appBar: const MyAppBar(
          centerTitle: "我的信息",
        ),
        body: Column(
          children: <Widget>[
            ClickItemCommon(
              title: '头像',
              widget: AccountAvatar(
                avatarUrl: provider.account.avatarUrl,
                size: SizeConstant.TWEET_PROFILE_SIZE * 0.9,
              ),
              onTap: () async {
                Map<PermissionGroup, PermissionStatus> permissions =
                    await PermissionHandler()
                        .requestPermissions([PermissionGroup.camera]);
                //校验权限
                if (permissions[PermissionGroup.camera] !=
                    PermissionStatus.granted) {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => SimpleConfirmDialog(
                            '无法访问照片',
                            '你未开启"允许甜甜圈访问照片"选项',
                            leftItem: ClickableText('知道了', () {
                              NavigatorUtils.goBack(context);
                            }),
                            rightItem: ClickableText('去设置', () async {
                              await PermissionHandler().openAppSettings();
                            }),
                          ));

                  return;
                }
                _cropAndUpload(provider);
              },
            ),

            ClickItem(
                title: "昵称",
                content: provider.account.nick,
                onTap: () {
                  NavigatorUtils.pushResult(
                      context,
                      Routes.inputTextPage +
                          Utils.packConvertArgs({
                            'title': '修改昵称',
                            'hintText': provider.account.nick,
                            'limit': 16
                          }), (res) {
                    provider.account.nick = res.toString();
                  });
                }),
            ClickItem(
              title: '签名',
              maxLines: 2,
              content: provider.account.signature,
              onTap: () {
                NavigatorUtils.pushResult(
                    context,
                    Routes.inputTextPage +
                        Utils.packConvertArgs({
                          'title': '修改签名',
                          'hintText': provider.account.signature,
                          'limit': 32
                        }), (res) {
                  provider.account.signature = res.toString();
                });
              },
            ),
            ClickItem(
              title: '性别',
              content: provider.account.gender == null
                  ? Gender.UNKNOWN.zhTag
                  : genderMap[provider.account.gender].zhTag,
              onTap: () {
                _showAgeChooise();
              },
            ),
            ClickItem(
              title: '生日',
              maxLines: 1,
              content: provider.account.birthDay == null ? "未知" : "",
              onTap: () {
                _showCupertinoDatePicker(context, provider);

                // NavigatorUtils.pushResult(
                //     context,
                //     Routes.inputTextPage +
                //         Utils.packConvertArgs({
                //           'title': '修改签名',
                //           'hintText': provider.account.signature,
                //           'limit': 32
                //         }), (res) {
                //   provider.account.signature = res.toString();
                // });
              },
            ),
            ClickItem(
              title: '年龄',
              maxLines: 1,
              content: provider.account.birthDay == null ? "未知" : "",
              // content: _g,
            ),
            ClickItem(
              title: '地区',
              maxLines: 1,
              content: provider.account.birthDay == null ? "未知" : "",
              // content: _g,
            ),
            // ClickItem(
            //   title: 'QQ',
            //   maxLines: 1,
            //   content: provider.account.birthDay == null ? "未绑定" : "",
            //   // content: _g,
            // ),
          ],
        ),
      );
    });
  }
  // });

  // Widget _getSettingItem(ListTile lst) {
  //   return Container(
  //     child: Material(
  //       child: InkWell(
  //         child: Column(
  //           children: <Widget>[
  //             lst,
  //             Container(
  //               margin: EdgeInsets.only(left: 15),
  //               child: Divider(),
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _cropAndUpload(AccountLocalProvider provider) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final cropKey = GlobalKey<CropState>();
      File file = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              ImageCropContainer(cropKey: cropKey, file: image)));
      if (file == null) {
        return;
      } else {
        this.filePath = file.path;
        String resultUrl =
            await OssUtil.uploadImage(file.path, file, toTweet: false);
        if (resultUrl != "-1") {
          Result r = await MemberApi.modAccount(
              AccountEditParam(AccountEditParam.AVATAR, resultUrl));
          if (r != null && r.isSuccess) {
            setState(() {
              provider.account.avatarUrl = resultUrl;
            });
            file?.delete();
            return;
          }
        }
        file?.delete();
        ToastUtil.showToast(context, '上传失败，请稍候重试');
      }
    }
  }

  void _showCupertinoDatePicker(
      BuildContext cxt, AccountLocalProvider provider) {
    final picker = CupertinoDatePicker(
      mode: CupertinoDatePickerMode.date,
      onDateTimeChanged: (date) {
        print(date.toString() + "=======");
        setState(() {
          provider.account.signature = date.toString();
        });
      },
      initialDateTime: DateTime(1995),
    );

    showCupertinoModalPopup(
        context: cxt,
        builder: (cxt) {
          return Container(
            height: ScreenUtil.screenHeightDp * 0.35,
            child: picker,
          );
        });
  }

  void _showAgeChooise() {
    List<BSChoiceItem> items = genderMap.keys
        .map((k) => BSChoiceItem(name: k, text: genderMap[k].zhTag))
        .toList();
    BottomSheetUtil.shwoBottomChoise(context, items, (index) {
      print(items[index].text + "-----" + items[index].name);
    });
  }
}
