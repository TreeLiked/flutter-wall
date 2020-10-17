import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iap_app/api/v_c.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/update_dialog.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/version/pub_v.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:install_plugin/install_plugin.dart';

class VersionUtils {
  static const MethodChannel _channel = const MethodChannel('version');

  /// 应用安装
  static void install(String path) {
    InstallPlugin.installApk(path, "com.iutr.iap_app");
  }

  /// AppStore跳转
  static void jumpAppStore() {
//    _channel.invokeMethod("jumpAppStore");
    InstallPlugin.gotoAppStore("https://itunes.apple.com/cn/app/id1497247380");
  }

  static void showUpdateDialog(BuildContext context, PubVersion version, bool forceUpdate) {
    showDialog(
        context: context,
        barrierDismissible: !forceUpdate,
        builder: (BuildContext context) {
          return UpdateDialog(version, forceUpdate);
        });
  }

  static Future<Result<PubVersion>> checkUpdate({BuildContext context}) async {
    return await VCAPI.fetchLatestVersion();
  }

  static void displayUpdateDialog(Result<PubVersion> result, {BuildContext context, bool slient = false}) {
    if (result != null) {
      if (!result.isSuccess) {
        // 当前版本不可用，必须更新
        if (result.data != null) {
          VersionUtils.showUpdateDialog(context ?? Application.context, result.data, true);
        } else {
          if (!slient) {
            ToastUtil.showToast(context, "测试版本");
          }
        }
      } else {
        // 当前版本可以继续使用
        if (result.data != null) {
          // 有新的版本可以升级
          VersionUtils.showUpdateDialog(context ?? Application.context, result.data, false);
        } else {
          if (!slient) {
            ToastUtil.showToast(context, '恭喜您已经是最新版本');
          }
          return;
        }
        // 最新版本
      }
    }
  }
}
