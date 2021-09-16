import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/model/account/account_edit_param.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/page/common/image_crop.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/util/PermissionUtil.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/oss_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';

class AccountProfileUtil {
  static void cropAndUpdateProfile(
      AccountLocalProvider provider, BuildContext context, Function callback) async {
    bool hasP = await PermissionUtil.checkAndRequestPhotos(context);
    if (!hasP) {
      return;
    }
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    if (image != null) {
      final File imageFile = File(image.path);
      final cropKey = GlobalKey<CropState>();
      File file = await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ImageCropContainer(cropKey: cropKey, file: imageFile)));
      if (file != null) {
        Utils.showDefaultLoadingWithBounds(context, text: '正在更新');
        String resultUrl = await OssUtil.uploadImage(file.path, file.readAsBytesSync(), OssUtil.DEST_AVATAR);
        if (resultUrl != "-1") {
          Result r = await MemberApi.modAccount(AccountEditParam(AccountEditKey.AVATAR, resultUrl));
          if (r != null) {
            r.data = resultUrl;
            callback(r);
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
}
