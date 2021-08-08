import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iap_app/common-widget/gallery_photo_view_wrapper.dart';
import 'package:iap_app/common-widget/gallery_photo_view_wrapper_circle.dart';
import 'package:iap_app/common-widget/simple_confirm.dart';
import 'package:iap_app/common-widget/text_clickable_iitem.dart';
import 'package:iap_app/model/photo_wrap_item.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/fluro_convert_utils.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
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
          return SpinKitThreeBounce(color: Colors.white, size: size);
          // return CupertinoActivityIndicator();
//        const CupertinoActivityIndicator()
//          );
//          return SpinKitChasingDots(color: Color(0xff3489ff), size: size);
        });
    if (call != null) {
      call();
      NavigatorUtils.goBack(context);
    }
  }

  static void closeLoading(BuildContext context) {
    NavigatorUtils.goBack(context);
  }

  static void showDefaultLoadingWithAsyncCall(
    BuildContext context,
    Function call, {
    double size = 30,
  }) async {
    showDefaultLoadingWithBounds(context, size: size);
    if (call != null) {
      await call();
    }
    NavigatorUtils.goBack(context);
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
              width: ScreenUtil().setWidth(300),
              height: ScreenUtil().setWidth(300),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: ThemeUtils.isDark(context) ? Colors.black54 : Colors.white30,
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
    list.add(SpinKitChasingDots(color: Colors.lightBlueAccent, size: size)
        // SpinKitChasingDots(color: Colors.amber, size: size),
        //  const CupertinoActivityIndicator()
        );
    if (!StringUtil.isEmpty(text)) {
      list.add(Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
          child: Text(text,
              softWrap: true,
              textAlign: TextAlign.center,
              style: pfStyle.copyWith(
                  color: ThemeUtils.isDark(context) ? Colors.white : Colors.white, fontSize: 14))));
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

  static Widget showFadeInImage(String url, BorderRadius radius, {bool cache = false, String preImgUrl}) {
    return ClipRRect(
        borderRadius: radius,
        child: cache
            ? CachedNetworkImage(
                width: double.infinity,
                height: double.infinity,
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => StringUtil.isEmpty(preImgUrl)
                    ? const CupertinoActivityIndicator()
                    : ClipRRect(
                        borderRadius: radius,
                        child: CachedNetworkImage(
                            width: double.infinity,
                            height: double.infinity,
                            imageUrl: url,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const CupertinoActivityIndicator())))
            : FadeInImage.memoryNetwork(
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
      var result = await ImageGallerySaver.saveImage(Uint8List.fromList(response.data), quality: 100);
      print("save result --> " + result.toString());
      if (Platform.isAndroid) {
        return !StringUtil.isEmpty(result) && result.toString().startsWith("file");
      } else if (Platform.isIOS) {
        return true == result['isSuccess'];
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      // ToastUtil.showToast(Application.context, e.toString());
    }
    return false;
  }

  static KeyboardActionsConfig getKeyboardActionsConfig(BuildContext context, List<FocusNode> list) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: ThemeUtils.getKeyboardActionsColor(context),
      nextFocus: true,
      actions: List.generate(
          list.length,
          (i) => KeyboardActionsItem(
              focusNode: list[i],
              footerBuilder: (_) => PreferredSize(
                  child: const Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: const Text("关闭"),
                  ),
                  preferredSize: Size.fromHeight(40)))),
    );
  }

  static void copyTextToClipBoard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  static String getBadgeText(int count, {int maxCount = 99}) {
    if (count <= 0) {
      return "";
    }
    if (count > maxCount) {
      return '$maxCount+';
    }
    return '$count';
  }

  static Text getRpWidget(int cnt, {int maxCount = 99, Color textColor = Colors.white, double fontSize = 12.0}) {
    return Text('${getBadgeText(cnt, maxCount: maxCount)}', style: pfStyle.copyWith(color: textColor, fontSize: fontSize));
  }

  static bool badgeHasData(int data) {
    return data > 0;
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

  static void openPhotoViewForCircle(
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
            builder: (context) => CirclePhotoViewWrapper(
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

  static String getEnumValue(a) {
    return a.toString().substring(a.toString().indexOf('.') + 1);
  }
}

Future<T> showElasticDialog<T>({
  @required BuildContext context,
  bool barrierDismissible = true,
  WidgetBuilder builder,
}) {
  final ThemeData theme = Theme.of(context);
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
