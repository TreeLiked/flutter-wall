import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tweet_reply_message.g.dart';

@JsonSerializable()
class TweetReplyMessage extends AbstractMessage {
  int tweetId;
  int mainReplyId;

  String tweetBody;
  String coverUrl;

  String replyContent;
  Account replier;

  // 回复是否匿名
  bool anonymous;

  Map<String, dynamic> toJson() => _$TweetReplyMessageToJson(this);

  factory TweetReplyMessage.fromJson(Map<String, dynamic> json) => _$TweetReplyMessageFromJson(json);

  TweetReplyMessage();
}
