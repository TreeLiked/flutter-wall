import 'package:iap_app/model/tweet_reply.dart';
import 'package:json_annotation/json_annotation.dart';

import 'account.dart';

part 'tweet.g.dart';

@JsonSerializable()
class BaseTweet {
  int id;
  int orgId;
  String body;
  String type;
  bool anonymous;

  Account account;

  bool enableReply;

  // Map<TweetReply, List<TweetReply>> replies;

  List<String> picUrls;

  int hot;
  int praise;
  int views;
  int replyCount;
  bool upTrend;

  /*
   * 直接回复
   */
  List<TweetReply> dirReplies;

  /*
   * 最近指定时间点赞的账户 
   */
  List<Account> latestPraise;

  DateTime gmtModified;
  DateTime gmtCreated;

  // 是否点赞
  bool loved;

  BaseTweet();

  Map<String, dynamic> toJson() => _$BaseTweetToJson(this);

  factory BaseTweet.fromJson(Map<String, dynamic> json) =>
      _$BaseTweetFromJson(json);
}
