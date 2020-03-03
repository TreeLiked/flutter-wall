import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/toast_util.dart';

class AvatarOriginPage extends StatelessWidget {
  final String avatarUrl;

  AvatarOriginPage(this.avatarUrl);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Hero(
            tag: 'avatar',
            child: GestureDetector(
              child: CachedNetworkImage(
                imageUrl: avatarUrl,
                fit: BoxFit.fitWidth,
              ),
              onTap: () {
                NavigatorUtils.goBack(context);
              },
              onLongPress: () {
                BottomSheetUtil.showBottomSheetView(context, [
                  BottomSheetItem(
                      Icon(
                        Icons.file_download,
                        color: Colors.lightBlue,
                      ),
                      '保存到本地', () async {
                    Utils.showDefaultLoadingWithBounds(context, text: "正在下载..");
                    bool success = await Utils.downloadAndSaveImageFromUrl(avatarUrl);
                    NavigatorUtils.goBack(context);
                    NavigatorUtils.goBack(context);
                    if (success) {
                      ToastUtil.showToast(context, '已保存到手机相册');
                    } else {
                      ToastUtil.showToast(context, '保存失败');
                    }
                  }),
                ]);
              },
            )));
  }
}
