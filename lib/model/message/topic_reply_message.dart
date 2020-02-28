import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:json_annotation/json_annotation.dart';

part 'topic_reply_message.g.dart';

@JsonSerializable()
class TopicReplyMessage extends AbstractMessage {

  int topicId;
  int mainReplyId;

  Account replier;

  String topicBody;
  String replyContent;

  Map<String, dynamic> toJson() => _$TopicReplyMessageToJson(this);

  factory TopicReplyMessage.fromJson(Map<String, dynamic> json) => _$TopicReplyMessageFromJson(json);

  TopicReplyMessage();
}

