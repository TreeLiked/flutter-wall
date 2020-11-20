import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as f1;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/model/version/pub_v.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/image_utils.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/version_utils.dart';

class UpdateDialog extends StatefulWidget {
  final PubVersion version;
  final bool forceUpdate;

  UpdateDialog(this.version, this.forceUpdate);

  @override
  _UpdateDialogState createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
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
    Color primaryColor = Theme.of(context).primaryColor;
    return WillPopScope(
      onWillPop: () async {
        /// 使用false禁止返回键返回，达到强制升级目的
        if (widget.forceUpdate) {
          return false;
        }
        return true;
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
                decoration: BoxDecoration(
                  color: ThemeUtils.getDialogBackgroundColor(context),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                width: 280.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                        height: 120.0,
                        width: 280.0,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: const Radius.circular(8.0), topRight: const Radius.circular(8.0)),
                          image: DecorationImage(
                            image: StringUtil.isEmpty(widget.version.cover)
                                ? ImageUtils.getAssetImage("update_head", format: 'jpg')
                                : CachedNetworkImageProvider(widget.version.cover),
                            fit: BoxFit.cover,
                          ),
                        )),
                    Container(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 16.0, bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Text("新版本更新", style: TextStyles.textSize16),
                            Text(widget.version.mark ?? "",
                                style: TextStyle(color: Colors.blue, fontSize: Dimens.font_sp15))
                          ],
                        )),
                    widget.forceUpdate
                        ? Container(
                            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0),
                            child: Text("您必须升级到此版本，否则服务将出现异常",
                                softWrap: true,
                                maxLines: 2,
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w400)),
                          )
                        : Gaps.empty,
                    Container(
                        constraints: BoxConstraints(
                          maxHeight: 200,
                        ),
//                      alignment: Alignment.centerLeft,
                        width: double.infinity,
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                              child: Text("${widget.version.updateDesc}"),
                            ),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0, left: 15.0, right: 15.0, top: 5.0),
                      child: _isDownload
                          ? Column(
                              children: <Widget>[
                                LinearProgressIndicator(
                                  backgroundColor: Colours.line,
                                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                                  value: _value,
                                ),
                                Gaps.vGap10,
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text('${(_value * 100).toStringAsFixed(2)}%',
                                      style: TextStyle(
                                          color: Colors.lightBlueAccent, fontSize: Dimens.font_sp14)),
                                )
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                !widget.forceUpdate
                                    ? Container(
                                        width: 110.0,
                                        height: 36.0,
                                        margin: const EdgeInsets.only(right: 10),
                                        child: FlatButton(
                                          onPressed: () {
                                            NavigatorUtils.goBack(context);
                                          },
                                          textColor: primaryColor,
                                          color: Colors.transparent,
                                          disabledTextColor: Colors.white,
                                          disabledColor: Colours.text_gray_c,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(18.0),
                                              side: BorderSide(
                                                color: primaryColor,
                                                width: 0.8,
                                              )),
                                          child: Text(
                                            "残忍拒绝",
                                            style: TextStyle(fontSize: Dimens.font_sp16),
                                          ),
                                        ),
                                      )
                                    : Gaps.empty,
                                Container(
                                  width: 110.0,
                                  height: 36.0,
                                  child: FlatButton(
                                    onPressed: () {
                                      if (defaultTargetPlatform == TargetPlatform.iOS) {
                                        NavigatorUtils.goBack(context);
                                        VersionUtils.jumpAppStore();
                                      } else {
                                        setState(() {
                                          _isDownload = true;
                                        });
                                        _download(widget.version.versionId);
                                      }
                                    },
                                    textColor: Colors.white,
                                    color: primaryColor,
                                    disabledTextColor: Colors.white,
                                    disabledColor: Colours.text_gray_c,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    child: Text(
                                      "立即更新",
                                      style: TextStyle(fontSize: Dimens.font_sp16),
                                    ),
                                  ),
                                )
                              ],
                            ),
                    )
                  ],
                )),
          )),
    );
  }

  ///下载apk
  _download(int versionId) async {
    try {
      await DirectoryUtil.getInstance();
      await DirectoryUtil.initStorageDir();
      DirectoryUtil.createStorageDirSync(category: 'apk');
      String path = DirectoryUtil.getStoragePath(fileName: 'wall', category: 'apk', format: 'apk');
      print("------------安装PATH--------, $path");

      // Directory storageDir = await getExternalStorageDirectory();
      // String storagePath = storageDir.path;
      // File file = new File('$storagePath/${Config.APP_NAME}v${_version}.apk');

      File file = File(path);

      /// 链接可能会失效
      await Dio().download(
        widget.version.apkUrl,
        file.path,
        cancelToken: _cancelToken,
        onReceiveProgress: (int count, int total) {
          if (total != -1) {
            if (count == total) {
              NavigatorUtils.goBack(context);
              VersionUtils.install(path);
            }
            _value = count / total;
            setState(() {});
          }
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "下载失败!");
      print(e);
      setState(() {
        _isDownload = false;
      });
    }
  }
}
