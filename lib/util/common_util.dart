import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
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
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/model/photo_wrap_item.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/fluro_convert_utils.dart';
import 'package:iap_app/util/image_utils.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:transparent_image/transparent_image.dart';

class Utils {
  static String packConvertArgs(Map<String, Object> args) {
    if (CollectionUtil.isMapEmpty(args)) {
      return "";
    }
    StringBuffer buffer = new StringBuffer("?");
    args.forEach((k, v) => buffer.write(k + "=" + FluroConvertUtils.fluroCnParamsEncode(v.toString()) + "&"));
    String str = buffer.toString();
    str = str.substring(0, str.length - 1);

    return str;
  }

  static void displayDialog(
    BuildContext context,
    Widget dialog, {
    bool barrierDismissible = false,
  }) {
    showDialog(context: context, barrierDismissible: barrierDismissible, builder: (_) => dialog);
  }

  static void showSimpleConfirmDialog(
      BuildContext context, String title, String content, ClickableText left, ClickableText right,
      {bool barrierDismissible = false}) {
    displayDialog(
      context,
      SimpleConfirmDialog('$title', '$content', leftItem: left, rightItem: right),
      barrierDismissible: barrierDismissible,
    );
  }

  static void showDefaultLoading(BuildContext context, {double size = 30, Function call}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SpinKitChasingDots(color: Colors.amber, size: size);
//        const CupertinoActivityIndicator()
//          );
//          return SpinKitChasingDots(color: Color(0xff3489ff), size: size);
        });
    if (call != null) {
      call();
      NavigatorUtils.goBack(context);
    }
  }

  static void showDefaultLoadingWithAsyncCall(
    BuildContext context,
    Function call, {
    double size = 30,
  }) async {
    showDefaultLoading(context, size: size);
    if (call != null) {
      await call();
      NavigatorUtils.goBack(context);
    }
  }

  static void showDefaultLoadingWithBounds(BuildContext context, {double size = 25, String text = ""}) {
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
                    borderRadius: BorderRadius.circular(8),
                    color: ThemeUtils.isDark(context) ? Colors.black54 : Colors.black26,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  alignment: Alignment.center,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _renderLoadingList(context, size, text))),
            )),
          );
        });
  }

  static List<Widget> _renderLoadingList(BuildContext context, double size, String text) {
    List<Widget> list = new List();
    list.add(
      SpinKitChasingDots(color: Colors.amber, size: size),
//        const CupertinoActivityIndicator()
    );
    if (!StringUtil.isEmpty(text)) {
      list.add(Padding(
          padding: EdgeInsets.only(top: 0),
          child: Text(text,
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: ThemeUtils.isDark(context) ? Colors.white : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold))));
    }
    return list;
  }

  static void showFavoriteAnimation(BuildContext context, {double size = 30, Key key}) {
//    "assets/flrs/firework1.flr",// Play

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Material(
            key: key,
            type: MaterialType.transparency,
            child: Center(
                child: SizedBox(
                    child: Container(
              alignment: Alignment.center,
              child: FlareActor(
                "assets/flrs/firework1.flr",
                alignment: Alignment.center,
                animation: "Play",
                fit: BoxFit.fitWidth,
              ),
//                       child: FlareActor(
//                         "assets/flrs/favorite2.flr",
//                         alignment: Alignment.center,
//                         animation: "Animations",
//                         fit: BoxFit.cover,
//                       ),
            ))),
          );
        });
  }

  static Widget showFadeInImage(String url) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: FadeInImage.memoryNetwork(
          width: double.infinity,
          height: double.infinity,
          placeholder: kTransparentImage,
          placeholderCacheHeight: 5,
          placeholderCacheWidth: 5,
//          placeholderScale: 20,
          image: url,
          fit: BoxFit.cover,
        ));
  }

  static Widget showNetImage(String url, {double width, double height, BoxFit fit}) {
    return ExtendedImage.network(
      url,
      fit: fit,
      width: width,
      height: height,
      cache: false,
      clearMemoryCacheIfFailed: true,
      enableLoadState: true,
      shape: BoxShape.rectangle,
      // borderRadius: BorderRadius.all(Radius.circular(15.0)),
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return Container(
              width: width,
              height: height,
              child: const CupertinoActivityIndicator(),
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

  static Future<bool> downloadAndSaveImageFromUrl(String url) async {
    var response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));
    List<int> bytes = response.data;
    if (bytes == null) {
      return false;
    }
    try {
      ImagePickerSaver.saveFile(fileData: Uint8List.fromList(bytes));
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }

  static KeyboardActionsConfig getKeyboardActionsConfig(BuildContext context, List<FocusNode> list) {
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

  static void copyTextToClipBoard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

//  static void vibrateOnceOrNotSupport() async {
//    Vibrate.feedback(FeedbackType.medium);
//  }

  static void openPhotoView(
    BuildContext context,
    List<String> urls,
    int initialIndex,
    int refId,
  ) {
    if (CollectionUtil.isListEmpty(urls)) {
      return;
    }

    List<PhotoWrapItem> items =
        urls.map((f) => PhotoWrapItem(index: initialIndex, url: Uri.decodeComponent(f))).toList();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GalleryPhotoViewWrapper(
                  usePageViewWrapper: true,
                  galleryItems: items,
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  loadingChild: new SpinKitRing(
                    color: Colors.grey,
                    size: 18.0,
                    lineWidth: 3.0,
                  ),
                  initialIndex: initialIndex,
                  refId: refId.toString(),
                ),
            maintainState: false));
  }

  static Widget loadingIconStatic =
      SizedBox(width: 25.0, height: 25.0, child: const CupertinoActivityIndicator(animating: false));

  static ClassicHeader getDefaultRefreshHeader() {
    return ClassicHeader(
      idleText: '',
      releaseText: '',
      refreshingText: '',
      completeText: '',
      refreshStyle: RefreshStyle.Follow,
      idleIcon: loadingIconStatic,
      releaseIcon: loadingIconStatic,
      completeDuration: Duration(milliseconds: 0),
      completeIcon: null,
    );
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
    pageBuilder:
        (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
      final Widget pageChild = Builder(builder: builder);
      return SafeArea(
        child: Builder(builder: (BuildContext context) {
          return theme != null ? Theme(data: theme, child: pageChild) : pageChild;
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
    BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ),
    child: SlideTransition(
      position: Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(CurvedAnimation(
        parent: animation,
        curve: animation.status != AnimationStatus.forward ? Curves.easeOutBack : ElasticOutCurve(0.85),
      )),
      child: child,
    ),
  );
}
