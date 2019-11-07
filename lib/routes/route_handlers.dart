/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2019 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'package:flutter/painting.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/gallery_photo_view_wrapper.dart';
import 'package:iap_app/index/index.dart';
import 'package:iap_app/model/photo_wrap_item.dart';
import 'package:iap_app/page/create_page.dart';
import 'package:iap_app/page/home_page.dart';
import 'package:iap_app/page/input_text_page.dart';
import 'package:iap_app/page/tweet_detail.dart';
import 'package:iap_app/util/fluro_convert_utils.dart';

var indexHander = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return Index();
});

var homeHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return HomePage();
});

var tweetDetailHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return TweetDetail(null);
});

var createHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return CreatePage();
});

var inputPageHander = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String title = params['title'] == null
      ? ""
      : FluroConvertUtils.fluroCnParamsDecode(params['title'].first);
  String hintText = params['hintText'] == null
      ? ""
      : FluroConvertUtils.fluroCnParamsDecode(params['hintText'].first);
  return InputTextPage(
    title: title,
    hintText: hintText,
  );
});

var galleryViewHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  List<String> picUrls = params['urls'];
  int index = int.parse(params['index'].first);
  List<PhotoWrapItem> items = picUrls
      .map((f) => PhotoWrapItem(index: index, url: Uri.decodeComponent(f)))
      .toList();
  return GalleryPhotoViewWrapper(
    usePageViewWrapper: true,
    galleryItems: items,
    backgroundDecoration: const BoxDecoration(
      color: Colors.black,
    ),
    initialIndex: index,
  );
});

// var demoRouteHandler = Handler(
//     handlerFunc: (BuildContext context, Map<String, List<String>> params) {
//   String message = params["message"]?.first;
//   String colorHex = params["color_hex"]?.first;
//   String result = params["result"]?.first;
//   Color color = Color(0xFFFFFFFF);
//   if (colorHex != null && colorHex.length > 0) {
//     color = Color(ColorHelpers.fromHexString(colorHex));
//   }
//   return DemoSimpleComponent(message: message, color: color, result: result);
// });

// var demoFunctionHandler = Handler(
//     type: HandlerType.function,
//     handlerFunc: (BuildContext context, Map<String, List<String>> params) {
//       String message = params["message"]?.first;
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text(
//               "Hey Hey!",
//               style: TextStyle(
//                 color: const Color(0xFF00D6F7),
//                 fontFamily: "Lazer84",
//                 fontSize: 22.0,
//               ),
//             ),
//             content: Text("$message"),
//             actions: <Widget>[
//               Padding(
//                 padding: EdgeInsets.only(bottom: 8.0, right: 8.0),
//                 child: FlatButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(true);
//                   },
//                   child: Text("OK"),
//                 ),
//               ),
//             ],
//           );
//         },
//       );
//     });

// /// Handles deep links into the app
// /// To test on Android:
// ///
// /// `adb shell am start -W -a android.intent.action.VIEW -d "fluro://deeplink?path=/message&mesage=fluro%20rocks%21%21" com.theyakka.fluro`
// var deepLinkHandler = Handler(
//     handlerFunc: (BuildContext context, Map<String, List<String>> params) {
//   String colorHex = params["color_hex"]?.first;
//   String result = params["result"]?.first;
//   Color color = Color(0xFFFFFFFF);
//   if (colorHex != null && colorHex.length > 0) {
//     color = Color(ColorHelpers.fromHexString(colorHex));
//   }
//   return DemoSimpleComponent(
//       message: "DEEEEEP LINK!!!", color: color, result: result);
// });