import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as f1;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/model/version/pub_v.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/image_utils.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/version_utils.dart';

class AbDialog extends StatefulWidget {
  final String title;
  final String content;

  // 是否展示左边的按钮
  final bool displayLeft;
  final String leftText;
  final String rightText;

  final Function onTapLeft;
  final Function onTapRight;

  final barryOnDismiss;

  AbDialog({
    this.title,
    this.content,
    this.leftText,
    this.rightText,
    this.onTapLeft,
    this.onTapRight,
    this.displayLeft = true,
    this.barryOnDismiss = false,
  });

  @override
  _AbDialogState createState() => _AbDialogState();
}

class _AbDialogState extends State<AbDialog> {
  CancelToken _cancelToken = CancelToken();
  bool _isDownload = false;
  double _value = 0;

  @override
  void dispose() {
    if (!_cancelToken.isCancelled && _value != 1) {
      _cancelToken.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    if(widget.version == null) {
//      return Gaps.empty;
//    }
    bool isDark = ThemeUtils.isDark(context);
    Color primaryColor = Theme.of(context).primaryColor;
    return WillPopScope(
        onWillPop: () async {
          /// 使用false禁止返回键返回，达到强制升级目的
          return widget.barryOnDismiss;
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Center(
                child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                decoration: BoxDecoration(
                  // color: ThemeUtils.getDialogBackgroundColor(context),
                  color: isDark ? Colors.black : Color(0xEEFFFFFF),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                width: Application.screenWidth * 0.6,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 16.0, bottom: 10),
                          child: Text("${widget.title}",
                              style: pfStyle.copyWith(fontSize: Dimens.font_sp16, letterSpacing: 1.2))),
                      Container(
                          constraints: BoxConstraints(
                            maxHeight: 200,
                          ),
                          width: double.infinity,
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                                child: Text("${widget.content}",
                                    style: pfStyle.copyWith(fontSize: Dimens.font_sp14, letterSpacing: 1.0)),
                              ),
                            ),
                          )),
                      Gaps.vGap10,
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                        widget.displayLeft
                            ? Expanded(
                                flex: 1,
                                // fit: FlexFit.loose,

                                child: Container(
                                  child: TextButton(
                                    onPressed: widget.onTapLeft ?? () => NavigatorUtils.goBack(context),
                                    child: Text("${widget.leftText ?? '关闭'}",
                                        style:
                                            pfStyle.copyWith(fontSize: Dimens.font_sp14, color: Colors.grey)),
                                  ),
                                ))
                            : Gaps.empty,
                        Gaps.hGap10,
                        Expanded(
                            flex: 1,
                            // fit: FlexFit.loose,
                            child: Container(
                                child: TextButton(
                                    onPressed: widget.onTapRight,
                                    child: Text("${widget.rightText ?? '确认'}",
                                        style: pfStyle.copyWith(
                                            fontSize: Dimens.font_sp14, color: Colors.blue)))))
                      ])
                    ]),
              ),
            ))));
  }
}
