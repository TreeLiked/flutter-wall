import 'package:iap_app/model/page_tweet.dart';
import 'package:iap_app/model/tweet.dart';

class Page<T> {
  int currentPage;
  int pageSize;
  int totalItems;
  int totalPages;
  List<T> data;

  Page.fromJsonSelf(Map<String, dynamic> parsedJson)
      : currentPage = parsedJson['currentPage'],
        pageSize = parsedJson['pageSize'],
        totalItems = parsedJson['totalItems'],
        totalPages = parsedJson['totalPages'];

  factory Page.fromJson(Map<String, dynamic> json) {
    if (T == BaseTweet) {
      return PageTweet.fromJson(json) as Page<T>;
    }
    throw UnimplementedError();
  }
}
