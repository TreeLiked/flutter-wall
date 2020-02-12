import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/click_item.dart';
import 'package:iap_app/common-widget/exit_dialog.dart';
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
import 'package:iap_app/routes/setting_router.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/oss_util.dart';
import 'package:iap_app/util/string.dart';
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
                            '你未开启"允许Wall访问照片"选项',
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
                    if (!StringUtil.isEmpty(res.toString())) {
                      String content = res.toString();
                      if (content.trim().isNotEmpty) {
                        _updateSomething(
                            AccountEditParam(AccountEditKey.NICK, content),
                            (success) {
                          setState(() {
                            provider.account.nick = content;
                          });
                        });
                      } else {
                        ToastUtil.showToast(context, '昵称不能为全部为空字符');
                      }
                    } else {
                      ToastUtil.showToast(context, '昵称不能为空，修改失败');
                    }
                  });
                }),
            ClickItem(
              title: '签名',
              maxLines: 2,
              content: provider.account.signature ?? '',
              onTap: () {
                NavigatorUtils.pushResult(
                    context,
                    Routes.inputTextPage +
                        Utils.packConvertArgs({
                          'title': '修改签名',
                          'hintText': provider.account.signature ?? '',
                          'limit': 64
                        }), (res) {
                  if (!StringUtil.isEmpty(res.toString())) {
                    _updateSomething(
                        AccountEditParam(
                            AccountEditKey.SIGNATURE, res.toString()),
                        (success) {
                      setState(() {
                        provider.account.signature = res.toString();
                      });
                    });
                  }
                });
              },
            ),
            ClickItem(
                title: "公开信息",
                onTap: () {
                  NavigatorUtils.push(
                      context, SettingRouter.accountPrivateInfoPage);
                }),
            ClickItem(
                title: "绑定信息",
                onTap: () {
                  NavigatorUtils.push(
                      context, SettingRouter.accountBindInfoPage);
                }),
            ClickItem(
                title: "实名认证",
                content: "未认证",

                onTap: () {
                  NavigatorUtils.push(
                      context, SettingRouter.accountBindInfoPage);
                }),
            InkWell(
              onTap: () {
                showElasticDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => ExitDialog());
              },
              child: Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      "退出登录",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  )),
            ),
          ],
        ),
      );
    });
  }

  void _cropAndUpload(AccountLocalProvider provider) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final cropKey = GlobalKey<CropState>();
      File file = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              ImageCropContainer(cropKey: cropKey, file: image)));
      if (file != null) {
        Utils.showDefaultLoadingWithBounds(context, text: '正在更新');
        String resultUrl =
            await OssUtil.uploadImage(file.path, file.readAsBytesSync(), OssUtil.DEST_AVATAR);
        if (resultUrl != "-1") {
          Result r = await MemberApi.modAccount(
              AccountEditParam(AccountEditKey.AVATAR, resultUrl));
          if (r != null && r.isSuccess) {
            setState(() {
              provider.account.avatarUrl = resultUrl;
            });
          } else {
            ToastUtil.showToast(context, '上传失败，请稍候重试');
          }
        } else {
          ToastUtil.showToast(context, '上传失败，请稍候重试');
        }
        Navigator.pop(context);
      }
      file?.delete();
    }
  }

  Future<void> _updateSomething(AccountEditParam param, final callback) async {
    Utils.showDefaultLoadingWithBounds(context, text: "正在更新");
    Result r = await MemberApi.modAccount(param);
    if (r != null && r.isSuccess) {
      callback(true);
    } else {
      ToastUtil.showToast(context, '修改失败，请稍候重试');
    }
    Navigator.pop(context);
  }
}
