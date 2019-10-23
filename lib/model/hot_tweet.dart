import 'package:iap_app/model/tweet.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hot_tweet.g.dart';

@JsonSerializable()
class HotTweet {
  int orgId;
  List<BaseTweet> tweets;
  DateTime lastFetched;
  DateTime gmtCreated;

  HotTweet();

  Map<String, dynamic> toJson() => _$HotTweetToJson(this);

  factory HotTweet.fromJson(Map<String, dynamic> json) =>
      _$HotTweetFromJson(json);
}
