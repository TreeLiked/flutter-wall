import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iap_app/common-widget/gallery_photo_view_wrapper.dart';
import 'package:iap_app/common-widget/simple_confirm.dart';
import 'package:iap_app/common-widget/text_clickable_iitem.dart';
import 'package:iap_app/common-widget/v_empty_view.dart';
import 'package:iap_app/model/photo_wrap_item.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/fluro_convert_utils.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils {
  static String packConvertArgs(Map<String, Object> args) {
    if (CollectionUtil.isMapEmpty(args)) {
      return "";
    }
    StringBuffer buffer = new StringBuffer("?");
    args.forEach((k, v) => buffer.write(
        k + "=" + FluroConvertUtils.fluroCnParamsEncode(v.toString()) + "&"));
    String str = buffer.toString();
    str = str.substring(0, str.length - 1);

    return str;
  }

  static void displayDialog(
    BuildContext context,
    Widget dialog, {
    bool barrierDismissible = false,
  }) {
    showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (_) => dialog);
  }

  static void showDefaultLoading(BuildContext context, {double size = 30}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SpinKitChasingDots(color: Color(0xff3489ff), size: size);
        });
  }

  static void showDefaultLoadingWithBonuds(BuildContext context,
      {double size = 30, String text = ""}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Material(
            type: MaterialType.transparency,
            child: Center(
                child: SizedBox(
              width: ScreenUtil().setWidth(200),
              height: ScreenUtil().setWidth(200),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    color: ThemeUtils.isDark(context)
                        ? Colors.black87
                        : Colors.white70,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _renderLoadingList(size, text))),
            )),
          );
        });
  }

  static List<Widget> _renderLoadingList(double size, String text) {
    List<Widget> list = new List();
    list.add(
      SpinKitChasingDots(color: Color(0xff00BFFF), size: size),
    );
    if (!StringUtil.isEmpty(text)) {
      list.add(Padding(
          padding: EdgeInsets.only(top: 0),
          child: Text(
            text,
            style: TextStyles.textBold14,
          )));
    }
    return list;
  }

  static void showFavoriteAnimation(BuildContext context, {double size = 30}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Material(
            type: MaterialType.transparency,
            child: Center(
                child: SizedBox(
                    width: ScreenUtil().setWidth(200),
                    height: ScreenUtil().setWidth(200),
                    child: Container(
                      alignment: Alignment.center,
                      child: FlareActor(
                        "assets/flrs/favorite.flr",
                        alignment: Alignment.center,
                        animation: "favorite",
                        fit: BoxFit.cover,
                      ),
                    ))),
          );
        });
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

  static KeyboardActionsConfig getKeyboardActionsConfig(
      BuildContext context, List<FocusNode> list) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: ThemeUtils.getKeyboardActionsColor(context),
      nextFocus: true,
      actions: List.generate(
          list.length,
          (i) => KeyboardAction(
                focusNode: list[i],
                closeWidget: const Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: const Text("关闭"),
                ),
              )),
    );
  }

  static Future<void> checkPhotoPermission(BuildContext context) async {
    Map<PermissionGroup, PermissionStatus> permissions;
    if (Platform.isAndroid) {
      permissions = await PermissionHandler()
          .requestPermissions([PermissionGroup.camera]);
    } else {
      permissions = await PermissionHandler()
          .requestPermissions([PermissionGroup.photos]);
    }
    //校验权限
    if ((Platform.isAndroid &&
            permissions[PermissionGroup.camera] != PermissionStatus.granted) ||
        (Platform.isIOS &&
            permissions[PermissionGroup.photos] != PermissionStatus.granted)) {
      await showDialog(
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
    }
  }

  static void copyTextToClipBoard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  static void openPhotoView(
    BuildContext context,
    List<String> urls,
    int initialIndex,
  ) {
    if (CollectionUtil.isListEmpty(urls)) {
      return;
    }

    List<PhotoWrapItem> items = urls
        .map((f) =>
            PhotoWrapItem(index: initialIndex, url: Uri.decodeComponent(f)))
        .toList();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GalleryPhotoViewWrapper(
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

Future<T> showElasticDialog<T>({
  @required BuildContext context,
  bool barrierDismissible = true,
  WidgetBuilder builder,
}) {
  final ThemeData theme = Theme.of(context, shadowThemeOnly: true);
  return showGeneralDialog(
    context: context,
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      final Widget pageChild = Builder(builder: builder);
      return SafeArea(
        child: Builder(builder: (BuildContext context) {
          return theme != null
              ? Theme(data: theme, child: pageChild)
              : pageChild;
        }),
      );
    },
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 550),
    transitionBuilder: _buildDialogTransitions,
  );
}

Widget _buildDialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ),
    child: SlideTransition(
      position: Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: animation,
        curve: animation.status != AnimationStatus.forward
            ? Curves.easeOutBack
            : ElasticOutCurve(0.85),
      )),
      child: child,
    ),
  );
}
