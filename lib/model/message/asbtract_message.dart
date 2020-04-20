import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/message/plain_system_message.dart';
import 'package:iap_app/model/message/popular_message.dart';
import 'package:iap_app/model/message/topic_reply_message.dart';
import 'package:iap_app/model/message/tweet_praise_message.dart';
import 'package:iap_app/model/message/tweet_reply_message.dart';
import 'package:json_annotation/json_annotation.dart';

part 'asbtract_message.g.dart';

@JsonSerializable()
class AbstractMessage {
  DateTime sentTime;
  Account receiver;
  ReadStatus readStatus;
  MessageType messageType;
  int id;
  DateTime gmtCreated;
  DateTime gmtModified;

  // 是否消息被删除了
  bool delete;


  Map<String, dynamic> toJson() => _$AbstractMessageToJson(this);

  factory AbstractMessage.fromJson(Map<String, dynamic> json) => _$AbstractMessageFromJson(json);

  AbstractMessage();
}

enum ReadStatus { READ, UNREAD, IGNORED }

enum MessageType {
  /// 推文点赞
  TWEET_PRAISE,

  /// 推文回复
  TWEET_REPLY,

  /// 话题回复
  TOPIC_REPLY,

  /// 上热门
  POPULAR,

  /// 普通系统消息
  PLAIN_SYSTEM,

  /// 举报消息
  REPORT
}
