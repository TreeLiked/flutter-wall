class Api {
  // static const String API_BASE_URL = "http://127.0.0.1:8088/iap/api";
  // static const String API_BASE_URL = "http://192.168.10.63:8088/iap/api";
  // static const String API_BASE_URL = "http://192.168.1.101:8088/iap/api";

  static const String API_BASE_URL = "http://192.168.0.106:8088/iap/api";

  // test
  static const String API_TEST = API_BASE_URL + "/test/t";
  // tweet
  static const String API_TWEET_CREATE = "/tweet/add.do";
  static const String API_TWEET_QUERYY = "/tweet/list.json";

  // tweet operation
  static const String API_TWEET_OPERATION = "/tweet/opt/opt.do";
  static const String API_TWEET_QUERY_SINGLE = "/tweet/opt/querySingle.json";

  // tweet praise query
  static const String API_TWEET_PRAISE_QUERY = "/tweet/praise/list.json";
  static const String API_TWEET_HOT_QUERYY = "/tweet/listHot.json";

  // tweet reply
  static const String API_TWEET_REPLY_CREATE = "/tweet/reply/add.do";
  static const String API_TWEET_REPLY_QUERY = "/tweet/reply/list.json";
}
