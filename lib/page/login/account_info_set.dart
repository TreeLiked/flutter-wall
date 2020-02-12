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
      if (nick.isEmpty || nick.length > 16) {
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
      var image = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        final cropKey = GlobalKey<CropState>();
        File file = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => ImageCropContainer(cropKey: cropKey, file: image)));
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
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Gaps.vGap16,
          Gaps.vGap16,
          Container(
            alignment: Alignment.center,
            child: _avatarFile == null
                ? Container(
                    padding: const EdgeInsets.all(25.0),
                    decoration: BoxDecoration(
                        color: Color(0xfff1f2f3),
//                  borderRadius: BorderRadius.all((Radius.circular(100))),
                        shape: BoxShape.circle),
                    child: GestureDetector(
                        onTap: _goChoiceAvatar,
                        child: LoadAssetImage(
                          "profile_sel",
                          format: 'png',
                          width: SizeConstant.TWEET_PROFILE_SIZE,
                          fit: BoxFit.cover,
                          color: Colors.grey,
                        )),
                  )
                : GestureDetector(
                    onTap: _goChoiceAvatar,
                    child: ClipOval(
                        child: Image.file(
                      _avatarFile,
                      width: SizeConstant.TWEET_PROFILE_SIZE * 1.5,
                      height: SizeConstant.TWEET_PROFILE_SIZE * 1.5,
                      fit: BoxFit.cover,
                      repeat: ImageRepeat.noRepeat,
                    ))),
          ),
          Container(
            decoration: BoxDecoration(color: Color(0xfff7f8f8), borderRadius: BorderRadius.circular(10.0)),
            padding: const EdgeInsets.only(left: 20),
            margin: const EdgeInsets.only(top: 25),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: MyTextField(
                    focusNode: _nodeText1,
                    config: Utils.getKeyboardActionsConfig(context, [
                      _nodeText1,
                    ]),
                    controller: _nickController,
                    maxLength: 16,
                    keyboardType: TextInputType.text,
                    hintText: "请输入昵称(16个字符以内)",
                  ),
                )
              ],
            ),
          ),
          Gaps.vGap12,
          Container(
            width: double.infinity,
            color: _canGoNext ? Colors.lightBlue : Color(0xffD7D6D9),
            margin: const EdgeInsets.only(top: 15),
            child: FlatButton(
                child: Text('下一步', style: TextStyle(color: Colors.white)),
                onPressed: _canGoNext ? _chooseOrg : null),
          ),
          Gaps.vGap15,
          Gaps.line,
          Gaps.vGap16,
          Text('请选择一张图片作为您的头像并且起一个响亮的昵称吧～', maxLines: 5, softWrap: true, style: TextStyles.textGray14)
        ],
      ),
    );
  }

  _chooseOrg() async {
    String nick = _nickController.text;
    if (nick == null || nick == "") {
      ToastUtil.showToast(context, '请输入昵称');
      return;
    }
    if (nick.trim().length == 0) {
      ToastUtil.showToast(context, '昵称不能全部为空');
      return;
    }
    // checkNick
    Utils.showDefaultLoadingWithBounds(context);
    MemberApi.checkNickRepeat(nick.trim()).then((res) async {
      if (!res.isSuccess) {
        NavigatorUtils.goBack(context);
        ToastUtil.showToast(context, '昵称重复了，换一个试试吧');
      } else {
        RegTemp.regTemp.nick = nick;
        String url =
            await OssUtil.uploadImage(_avatarFile.path, _avatarFile.readAsBytesSync(), OssUtil.DEST_AVATAR);
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
