import 'package:dio/dio.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/model/result.dart';

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
  "INDENTIFY-ID": "",
};

class HttpUtil {
  Dio dio;
  BaseOptions options;

  HttpUtil({String baseUrl = Api.API_BASE_INF_URL, Map<String, dynamic> header}) {
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
    );

    dio = new Dio(options);
    header.putIfAbsent("Authorization", () => Application.getLocalAccountToken);

    // dio.interceptors.add(CookieManager(CookieJar()));
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
      response = await dio.post(
        url,
        data: data,
      );
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
}
