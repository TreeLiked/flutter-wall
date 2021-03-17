import 'package:dio/dio.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/util/http_util.dart';

class TtSubscribe {
  static Future<Result<dynamic>> subscribeType(String tweetTypeName) async {
    String url = Api.API_TWEET_TYPE_SUBSCRIBE + "?ttName=$tweetTypeName";
    ;
    Response response;
    String em;
    try {
      response = await httpUtil.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      if (json != null) {
        return Result.fromJson(json);
      }
    } on DioError catch (e) {
      em = Api.formatError(e, pop: false);
    }
    return Api.genErrorResult(em);
  }

  static Future<Result<dynamic>> unSubscribeType(String tweetTypeName) async {
    String url = Api.API_TWEET_TYPE_UN_SUBSCRIBE + "?ttName=$tweetTypeName";
    ;
    Response response;
    String em;
    try {
      response = await httpUtil.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      if (json != null) {
        return Result.fromJson(json);
      }
    } on DioError catch (e) {
      em = Api.formatError(e, pop: false);
    }
    return Api.genErrorResult(em);
  }

  static Future<Result<dynamic>> checkSubscribeStatus(String tweetTypeName) async {
    String url = Api.API_TWEET_TYPE_CHECK_SUBSCRIBE + "?ttName=$tweetTypeName";
    ;
    Response response;
    String em;
    try {
      response = await httpUtil.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      if (json != null) {
        return Result.fromJson(json);
      }
    } on DioError catch (e) {
      em = Api.formatError(e, pop: false);
    }
    return Api.genErrorResult(em, data: false);
  }

  static Future<Result<dynamic>> getMySubscribeTypes() async {
    String url = Api.API_TWEET_TYPE_GET_SUBSCRIBE;
    ;
    Response response;
    String em;
    try {
      response = await httpUtil.dio.get(url);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      if (json != null) {
        return Result.fromJson(json);
      }
    } on DioError catch (e) {
      em = Api.formatError(e, pop: false);
    }
    return Api.genErrorResult(em, data: false);
  }
}
