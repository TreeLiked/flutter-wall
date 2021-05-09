import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/component/text_field.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/page/common/image_crop.dart';
import 'package:iap_app/page/login/reg_temp.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/login_router.dart';
import 'package:iap_app/util/PermissionUtil.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/oss_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

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
            ? KeyboardActions(
                child: _buildBody(),
              )
            : SingleChildScrollView(
                child: _buildBody(),
              ));
  }

  _goChoiceAvatar() async {
    bool has = await PermissionUtil.checkAndRequestPhotos(context);
    if (has) {
      var image = await ImagePicker().getImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        final cropKey = GlobalKey<CropState>();
        File file = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => ImageCropContainer(cropKey: cropKey, file: File(image.path))));
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
    bool isDark = ThemeUtils.isDark(context);
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
                ? GestureDetector(
                    onTap: _goChoiceAvatar,
                    child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                            color: Color(0xffD7D6D9),
                            shape: BoxShape.circle),
                        child: const LoadAssetImage(
                          "profile_sel",
                          format: 'png',
                          width: SizeConstant.TWEET_PROFILE_SIZE - 10,
                          fit: BoxFit.cover,
                          color: Colors.white,
                        )))
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
            decoration: BoxDecoration(color: Color(0xfff7f8f8), borderRadius: BorderRadius.circular(15.0)),
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
//            color: _canGoNext ? Colors.amber : Color(0xffD7D6D9),
            margin: const EdgeInsets.only(top: 15),
            child: FlatButton(
                disabledColor: !isDark ? Color(0xffD7D6D9) : Colours.dark_bg_color_darker,
                color:
                    _canGoNext ? Colors.amber : (!isDark ? Color(0xffD7D6D9) : Colours.dark_bg_color_darker),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                child: Text('下一步', style: TextStyle(color: Colors.white)),
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                onPressed: _canGoNext ? _chooseOrg : null),
          ),
          Gaps.vGap15,
          Gaps.line,
          Gaps.vGap16,
          Text('请选择头像并起一个独特的昵称叭～', maxLines: 5, softWrap: true, style: TextStyles.textGray14)
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
