import 'package:iap_app/model/Account.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tweet.g.dart';

@JsonSerializable()
class BaseTweet {
  int id;
  int unId;
  String body;
  String type;
  bool anonymous;
  Account account;
  bool enableReply;

  // Map<TweetReply, List<TweetReply>> replies;

  List<String> pics;

  BaseTweet(this.body, this.type, this.anonymous);

  Map<String, dynamic> toJson() => _$BaseTweetToJson(this);
}
