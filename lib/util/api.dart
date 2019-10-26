class Api {
  // static const String API_BASE_URL = "http://127.0.0.1:8088/iap/api";
  static const String API_BASE_URL = "http://192.168.10.63:8088/iap/api";
  // static const String API_BASE_URL = "http://192.168.1.108:8088/iap/api";

  // static const String API_BASE_URL = "http://192.168.0.104:8088/iap/api";

  // test
  static const String API_TEST = API_BASE_URL + "/test/t";
  // tweet
  static const String API_TWEET_CREATE = "/tweet/add.do";
  static const String API_TWEET_QUERYY = "/tweet/list.json";
  // tweet praise query
  static const String API_TWEET_PRAISE_QUERY = "/tweet/praise/list.json";

  static const String API_TWEET_HOT_QUERYY = "/tweet/listHot.json";

  // tweet reply
  static const String API_TWEET_REPLY_CREATE = "/reply/add.do";
}
