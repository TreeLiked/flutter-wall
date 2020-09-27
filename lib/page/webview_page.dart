import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    Key key,
    @required this.title,
    @required this.url,
  }) : super(key: key);

  final String title;
  final String url;

  @override
  _WebViewPageState createState() => _WebViewPageState();


}

class _WebViewPageState extends State<WebViewPage> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();


  WebView wv;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    wv = WebView(
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) async {
        _controller.complete(webViewController);
        print((await webViewController.getTitle()).toString());
      },
    );

    SystemUiOverlayStyle _overlayStyle =
        ThemeData.estimateBrightnessForColor(ThemeUtils.getBackgroundColor(context)) == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark;
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (context, snapshot) {
          return WillPopScope(
            onWillPop: () async {
              if (snapshot.hasData) {
                bool canGoBack = await snapshot.data.canGoBack();
                if (canGoBack) {
                  // 网页可以返回时，优先返回上一页
                  snapshot.data.goBack();
                  return Future.value(false);
                }
                return Future.value(true);
              }
              return Future.value(true);
            },
            child: Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text("${widget.title}", style: pfStyle),
                  leading: IconButton(
                    onPressed: () {
                      NavigatorUtils.goBack(context);
                    },
                    tooltip: 'Back',
                    padding: const EdgeInsets.all(12.0),
                    icon: Image.asset(
                      PathConstant.ICON_GO_BACK_ARROW,
                      color: _overlayStyle == SystemUiOverlayStyle.light ? Colours.dark_text : Colours.text,
                      width: 23.9,
                    ),
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () => {
                        BottomSheetUtil.showBottomSheetView(context, [
                          BottomSheetItem(Icon(Icons.content_copy), "复制链接", () {
                            ToastUtil.showToast(context, '已复制');
                            NavigatorUtils.goBack(context);
                            Utils.copyTextToClipBoard(widget.url);
                          }),
                        ])
                      },
                    )
                  ],
                ),
                body: wv),
          );
        });
  }
}
