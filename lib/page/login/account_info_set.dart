import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/my_button.dart';
import 'package:iap_app/common-widget/simple_confirm.dart';
import 'package:iap_app/common-widget/text_clickable_iitem.dart';
import 'package:iap_app/component/text_field.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/page/common/image_crop.dart';
import 'package:iap_app/page/login/reg_temp.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/login_router.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/oss_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:permission_handler/permission_handler.dart';

class AccountInfoCPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AccountInfoCPageState();
  }
}

class _AccountInfoCPageState extends State<AccountInfoCPage> {
  TextEditingController _nickController = TextEditingController();
  final FocusNode _nodeText1 = FocusNode();

  File _avatarFile;

  bool _canGoNext = false;

  @override
  void initState() {
    super.initState();
    _nickController.addListener(() {
      String nick = _nickController.text;
      bool go = true;
      if (nick.isEmpty || nick.length >= 16) {
        go = false;
      }
      if (_avatarFile == null) {
        go = false;
      }
      setState(() {
        _canGoNext = go;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          isBack: true,
          centerTitle: "基本信息",
        ),
        body: defaultTargetPlatform == TargetPlatform.iOS
            ? FormKeyboardActions(
                child: _buildBody(),
              )
            : SingleChildScrollView(
                child: _buildBody(),
              ));
  }

  _goChoiceAvatar() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.camera]);
    //校验权限
    if (permissions[PermissionGroup.camera] != PermissionStatus.granted) {
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
    } else {
      var image = await ImagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        final cropKey = GlobalKey<CropState>();
        File file = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                ImageCropContainer(cropKey: cropKey, file: image)));
        if (file != null) {
          this._avatarFile?.delete();
          setState(() {
            this._avatarFile = file;
            if (!StringUtil.isEmpty(_nickController.text)) {
              this._canGoNext = true;
            }
          });
          // Utils.showDefaultLoading(context);
          // String resultUrl =
          //     await OssUtil.uploadImage(file.path, file, toTweet: false);
          // if (resultUrl != "-1") {
          //   Result r = await MemberApi.modAccount(
          //       AccountEditParam(AccountEditParam.AVATAR, resultUrl));
          //   if (r != null && r.isSuccess) {
          //     setState(() {
          //       provider.account.avatarUrl = resultUrl;
          //     });
          //   } else {
          //     ToastUtil.showToast(context, '上传失败，请稍候重试');
          //   }
          // } else {
          //   ToastUtil.showToast(context, '上传失败，请稍候重试');
          // }
          // Navigator.pop(context);
        }
        // file?.delete();
      }
    }
  }

  _buildBody() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Gaps.vGap16,
          Gaps.vGap16,

          Center(
              child: Container(
            decoration: BoxDecoration(
                // border: Border.all(width: 0, color: Color(0xff8a8a8a)),
                // borderRadius: BorderRadius.all((Radius.circular(10))),
                ),
            child: GestureDetector(
                onTap: _goChoiceAvatar,
                child: _avatarFile == null
                    ? LoadAssetImage(
                        "profile_sel",
                        format: 'png',
                        width: SizeConstant.TWEET_PROFILE_SIZE * 1.5,
                        fit: BoxFit.cover,
                        color: Colors.grey,
                      )
                    : ClipOval(
                        child: Image.file(
                        _avatarFile,
                        width: SizeConstant.TWEET_PROFILE_SIZE * 1.5,
                        height: SizeConstant.TWEET_PROFILE_SIZE * 1.5,
                        fit: BoxFit.cover,
                        repeat: ImageRepeat.noRepeat,
                      ))),
          )),
          Gaps.vGap30,
          MyTextField(
            focusNode: _nodeText1,
            config: Utils.getKeyboardActionsConfig(context, [
              _nodeText1,
            ]),

            controller: _nickController,
            maxLength: 15,
            keyboardType: TextInputType.text,
            hintText: "请输入昵称(16个字符以内)",
            // onChange: (String val) {},
          ),
          Gaps.vGap15,
          Gaps.vGap10,
          MyButton(
            onPressed: _canGoNext ? _chooseOrg : null,
            text: "下一步",
          ),
          Gaps.vGap15,
          Gaps.line,
          Gaps.vGap16,
          Text('请选择一张图片作为您的头像并且起一个响亮的昵称吧～',
              maxLines: 5, softWrap: true, style: TextStyles.textGray12)
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

  _chooseOrg() async {
    String nick = _nickController.text;
    if (StringUtil.isEmpty(nick)) {
      ToastUtil.showToast(context, '请输入昵称');
      return;
    }
    if (nick.trim().length == 0) {
      ToastUtil.showToast(context, '昵称不能全部为空');
      return;
    }
    // checkNikc
    Utils.showDefaultLoadingWithBounds(context);
    MemberApi.checkNickRepeat(nick.trim()).then((res) async {
      if (res.isSuccess) {
        NavigatorUtils.goBack(context);
        ToastUtil.showToast(context, '昵称重复了，换一个试试吧');
      } else {
        RegTemp.regTemp.nick = nick;
        String url = await OssUtil.uploadImage(_avatarFile.path, _avatarFile.readAsBytesSync(),
            toTweet: false);
        NavigatorUtils.goBack(context);
        if (url != "-1") {
          RegTemp.regTemp.avatarUrl = url;
          NavigatorUtils.push(context, LoginRouter.loginOrgPage);
        } else {
          ToastUtil.showToast(context, '服务错误，请稍后重试');
        }
      }
    });
  }
}
