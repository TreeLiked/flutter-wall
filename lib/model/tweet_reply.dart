import 'package:json_annotation/json_annotation.dart';

import 'account.dart';
part 'tweet_reply.g.dart';

@JsonSerializable()
class TweetReply {
  int id;

  int parentId;

  int type;

  String body;

  Account account;
  Account tarAccount;

  List<TweetReply> children;

  int hot;
  int praise;
  int replyCount;

  DateTime gmtModified;
  DateTime gmtCreated;

  TweetReply();

  Map<String, dynamic> toJson() => _$TweetReplyToJson(this);

  factory TweetReply.fromJson(Map<String, dynamic> json) =>
      _$TweetReplyFromJson(json);
}
