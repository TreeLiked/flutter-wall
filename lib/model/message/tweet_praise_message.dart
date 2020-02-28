import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tweet_praise_message.g.dart';

@JsonSerializable()
class TweetPraiseMessage extends AbstractMessage {
  int tweetId;

  Account praiser;

  String tweetBody;

  /// 如果没有文字内容，则给出封面图片
  String coverUrl;

  Map<String, dynamic> toJson() => _$TweetPraiseMessageToJson(this);

  factory TweetPraiseMessage.fromJson(Map<String, dynamic> json) => _$TweetPraiseMessageFromJson(json);

  TweetPraiseMessage();
}
