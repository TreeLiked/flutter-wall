import 'package:iap_app/model/account/simple_account.dart';
import 'package:iap_app/model/media.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hot_tweet.g.dart';

@JsonSerializable()
class UniHotTweet {
  int orgId;
  List<HotTweet> tweets;
  DateTime lastFetched;
  DateTime gmtCreated;

  UniHotTweet();

  Map<String, dynamic> toJson() => _$UniHotTweetToJson(this);

  factory UniHotTweet.fromJson(Map<String, dynamic> json) => _$UniHotTweetFromJson(json);
}

@JsonSerializable()
class HotTweet {
  int id;
  int orgId;
  bool anonymous;
  SimpleAccount account;
  String body;
  Media cover;
  String type;
  DateTime sentTime;
  int hot;
  bool upTrend;

  HotTweet();
//  DateTime gmtCreated;
//  DateTime gmtModified;

  Map<String, dynamic> toJson() => _$HotTweetToJson(this);

  factory HotTweet.fromJson(Map<String, dynamic> json) => _$HotTweetFromJson(json);
}
