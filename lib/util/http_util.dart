import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/widgets.dart';
import 'package:html/dom.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/web_link.dart';
import 'package:iap_app/util/html_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:uuid/uuid.dart';

var httpUtil = HttpUtil(baseUrl: Api.API_BASE_INF_URL, header: headersJson);
var httpUtil2 = HttpUtil(baseUrl: Api.API_BASE_MEMBER_URL, header: headersJson);

//普通格式header

Map<String, dynamic> headers = {
  "Accept": "application/json",
  "Content-Type": "application/x-www-form-urlencoded",
};
//json格式
Map<String, dynamic> headersJson = {
  "Accept": "application/json",
  "Content-Type": "application/json; charset=UTF-8",
  "identify-id": Application.getAccountId ?? "",
  "user-agent":
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36",
  "version": Platform.isAndroid
      ? "${SharedConstant.VERSION_ID_ANDROID}_${SharedConstant.VERSION_REMARK_ANDROID}"
      : "${SharedConstant.VERSION_ID_IOS}_${SharedConstant.VERSION_REMARK_IOS}",
};

class HttpUtil {
  static final String _TAG = "HttpUtil";
  static final String authKey = SharedConstant.AUTH_HEADER_VALUE;

  Dio dio;
  BaseOptions options;
  Map<String, dynamic> headers;

//
//  void resetToken(String token) {
//    BaseOptions options = BaseOptions(
//      // 请求基地址，一般为域名，可以包含路径
//      // baseUrl: baseUrl,
//      //连接服务器超时时间，单位是毫秒.
//      connectTimeout: 10000,
//
//      //[如果返回数据是json(content-type)，dio默认会自动将数据转为json，无需再手动转](https://github.com/flutterchina/dio/issues/30)
//      // responseType: ResponseType.plain,
//
//      ///  响应流上前后两次接受到数据的间隔，单位为毫秒。如果两次间隔超过[receiveTimeout]，
//      ///  [Dio] 将会抛出一个[DioErrorType.RECEIVE_TIMEOUT]的异常.
//      ///  注意: 这并不是接收数据的总时限.
//      receiveTimeout: 30000,
//      headers: this.headers,
//    );
//
//    dio = new Dio(options);
//
//    String myToken = Application.getLocalAccountToken;
//    if (myToken == null) {
//      myToken = SpUtil.getString(SharedConstant.LOCAL_ACCOUNT_TOKEN);
//      Application.setLocalAccountToken(myToken);
//    }
//    if (myToken == null) {
//      ToastUtil.showToast(Application.context, '用户身份过期，请重新登录');
//    }
//    header.putIfAbsent("Authorization", () => myToken);
//  }

  HttpUtil({String baseUrl = Api.API_BASE_INF_URL, Map<String, dynamic> header}) {
    this.headers = header;
    options = BaseOptions(
      // 请求基地址，一般为域名，可以包含路径
      // baseUrl: baseUrl,
      //连接服务器超时时间，单位是毫秒.
      connectTimeout: 10000,

      //[如果返回数据是json(content-type)，dio默认会自动将数据转为json，无需再手动转](https://github.com/flutterchina/dio/issues/30)
      // responseType: ResponseType.plain,

      ///  响应流上前后两次接受到数据的间隔，单位为毫秒。如果两次间隔超过[receiveTimeout]，
      ///  [Dio] 将会抛出一个[DioErrorType.RECEIVE_TIMEOUT]的异常.
      ///  注意: 这并不是接收数据的总时限.
      receiveTimeout: 30000,
      headers: header,
      followRedirects: true
    );

    dio = new Dio(options)..interceptors.add(getMyInterceptor());
    // dio = new Dio(options)..interceptors.add(getMyInterceptor());

    String myToken = Application.getLocalAccountToken;
    if (myToken == null) {
      myToken = SpUtil.getString(SharedConstant.LOCAL_ACCOUNT_TOKEN);
      Application.setLocalAccountToken(myToken);
    }
    if (myToken == null) {
      ToastUtil.showToast(Application.context, '用户身份过期，请重新登录');
    }
    header.putIfAbsent(authKey, () => myToken);

    // dio.interceptors.add(CookieManager(CookieJar()));
  }

  void updateAuthToken(String accountToken) {
    if (headers.containsKey(authKey)) {
      headers.update(authKey, (_) => accountToken);
    } else {
      headers.putIfAbsent(authKey, () => accountToken);
    }
    options = BaseOptions(
      connectTimeout: 10000,
      receiveTimeout: 30000,
      headers: this.headers,
    );
    dio = new Dio(options)..interceptors.add(getMyInterceptor());
  }

  void clearAuthToken() {
    if (headers.containsKey(authKey)) {
      headers.remove(authKey);
    }
    options = BaseOptions(
      connectTimeout: 10000,
      receiveTimeout: 30000,
      headers: this.headers,
    );
    dio = new Dio(options)..interceptors.add(getMyInterceptor());
  }

  Future<Result<T>> get<T>(url, {data, options, cancelToken}) async {
    print('get请求启动! url：$url ,body: $data');
    Response response;
    Result result = Result(isSuccess: false);
    try {
      response = await dio.get(
        url,
        cancelToken: cancelToken,
      );
      print('get请求成功!response.data：${response.data}');
      Map<String, dynamic> json = response.data;
      return Result.fromJson(json);
    } on DioError catch (e) {
      if (CancelToken.isCancel(e)) {
        print('get请求取消! ' + e.message);
        result.message = e.message;
      }
      print('get请求发生错误：$e');
    }
    return result;
  }

  Future<Result<T>> post<T>(url, {data, options, cancelToken}) async {
    print('post请求启动! url：$url ,body: $data');
    Result result = Result(isSuccess: false);
    Response response;
    try {
      response = await dio.post(url, data: data, options: options, cancelToken: cancelToken);
      print('post请求成功!response.data：${response.data}');
      Map<String, dynamic> json = response.data;
      return Result.fromJson(json);
    } on DioError catch (e) {
      if (CancelToken.isCancel(e)) {
        print('post请求取消! ' + e.message);
        result.message = e.message;
      }
      print('post请求发生错误：$e');
    }
    return result;
  }

  static Future<WebLinkModel> loadHtml(BuildContext context, String url) async {
    if (url.startsWith("www")) {
      url = "http://" + url;
    }
    Response<dynamic> resp = await httpUtil.dio.get(url);
    if (resp != null) {
      String html = resp.data;
      if (!StringUtil.isEmpty(html)) {
        Document doc = HtmlUtils.parseDocument(html);
        return WebLinkModel(url, HtmlUtils.getDocTitle(doc) ?? url, HtmlUtils.getDocFaviconPath(doc));
      }
    }
    return null;
  }

  static InterceptorsWrapper getMyInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) => requestInterceptor(options, handler),
      onResponse: (response, handler) => responseInterceptor(response, handler),
      // onError: (DioError dioError) => errorInterceptor(dioError)
    );
  }

  static dynamic requestInterceptor(RequestOptions options, RequestInterceptorHandler handler) async {
    String requestId = new Uuid().v1().substring(0, 8);
    LogUtil.e('--> Request  to [ $requestId ] -->  ${options.uri}', tag: _TAG);
    options.extra.addAll({"RequestId": requestId});
    return handler.next(options);
  }

  static dynamic responseInterceptor(Response resp, ResponseInterceptorHandler handler) async {
    String val = resp.data.toString();
    String requestPath = resp.requestOptions.path;
    String requestId = resp.requestOptions.extra['RequestId'];
    LogUtil.e(
        '<-- Response to [ $requestId ] <-- $requestPath: ${val.length > 100 ? val.substring(0, 100) : val}',
        tag: _TAG);
    return handler.next(resp);
  }

  static int get lineNumber {
    final re = RegExp(r'^#1[ \t]+.+:(?<line>[0-9]+):[0-9]+\)$', multiLine: true);
    final match = re.firstMatch(StackTrace.current.toString());
    return (match == null) ? -1 : int.parse(match.namedGroup('line'));
  }
}
