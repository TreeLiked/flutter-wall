import 'dart:core';
import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/util/http_util.dart';

class DeviceApi {
  static void updateDeviceInfo(
      String accountId, String name, String platform, String model, String regId) async {
    String url = Api.API_UPDATE_DEVICE_INFO + "?name=$name&devicePlf=$platform&model=$model&deviceId=$regId";
    print(url);
    try {
      httpUtil.dio.get(url).then((res) {
        print('update device info finished');
      });
    } on DioError catch (e) {
      print('failed-------------------------------------update device info finished');
      Api.formatError(e);
    }
  }

  static void removeDeviceInfo(String accountId, String regId) async {
    String url = Api.API_REMOVE_DEVICE_INFO + "?deviceId=$regId";
    print(url);
    try {
      httpUtil.dio.get(url).then((res) {
        print('delete device info finished');
      });
    } on DioError catch (e) {
      Api.formatError(e);
    }
  }
}
