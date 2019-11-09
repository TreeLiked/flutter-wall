import 'package:extended_image/extended_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/common-widget/gallery_photo_view_wrapper.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/model/dialog_rertun.dart';
import 'package:iap_app/model/photo_wrap_item.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/fluro_convert_utils.dart';

class Utils {
  static void showToast(String msg) {
    Fluttertoast.showToast(msg: msg, gravity: ToastGravity.CENTER);
  }

  static String packConvertArgs(Map<String, String> args) {
    if (CollectionUtil.isMapEmpty(args)) {
      return "";
    }
    StringBuffer buffer = new StringBuffer("?");
    args.forEach((k, v) =>
        buffer.write(k + "=" + FluroConvertUtils.fluroCnParamsEncode(v) + "&"));
    String str = buffer.toString();
    str = str.substring(0, str.length - 1);

    return str;
  }

  static Widget showNetImage(String url,
      {double width, double height, BoxFit fit}) {
    return ExtendedImage.network(
      url,
      fit: fit,
      width: width,
      height: height,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return Container(
              width: width,
              height: height,
            );
          case LoadState.completed:
            return ExtendedRawImage(
              image: state.extendedImageInfo?.image,
              width: width,
              height: height,
              fit: fit,
            );
          case LoadState.failed:
            return GestureDetector(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Text(
                      "load image failed, click to reload",
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
              onTap: () {
                state.reLoadImage();
              },
            );
          default:
            return Container(
              width: width,
              height: height,
            );
        }
      },
    );
  }

  static void openPhotoView(
    BuildContext context,
    List<String> urls,
    int initialIndex,
  ) {
    if (CollectionUtil.isListEmpty(urls)) {
      return;
    }

    // StringBuffer buffer = StringBuffer();
    // urls.forEach((f) => buffer.write("&urls=${Uri.encodeComponent(f)}"));

    List<PhotoWrapItem> items = urls
        .map((f) =>
            PhotoWrapItem(index: initialIndex, url: Uri.decodeComponent(f)))
        .toList();
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new GalleryPhotoViewWrapper(
                  usePageViewWrapper: true,
                  galleryItems: items,
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  initialIndex: initialIndex,
                ),
            maintainState: true));
    // Application.router.navigateTo(
    //   context,
    //   Routes.cardToGallery + "?index=$initialIndex" + buffer.toString(),
    //   transition: TransitionType.fadeIn,
    // );
  }
}
