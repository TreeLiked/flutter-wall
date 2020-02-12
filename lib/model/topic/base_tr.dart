import 'package:iap_app/model/account/simple_account.dart';
import 'package:iap_app/model/media.dart';
import 'package:json_annotation/json_annotation.dart';

part 'base_tr.g.dart';

@JsonSerializable()
class MainTopicReply extends BaseTopicReply {
  int topicId;
  List<SubTopicReply> subReplies;

  MainTopicReply();

  Map<String, dynamic> toJson() => _$MainTopicReplyToJson(this);

  factory MainTopicReply.fromJson(Map<String, dynamic> json) => _$MainTopicReplyFromJson(json);
}

@JsonSerializable()
class SubTopicReply extends BaseTopicReply {
  bool child = true;
  int refId;

  SubTopicReply();

  Map<String, dynamic> toJson() => _$SubTopicReplyToJson(this);

  factory SubTopicReply.fromJson(Map<String, dynamic> json) => _$SubTopicReplyFromJson(json);
}

@JsonSerializable()
class BaseTopicReply {

  static const  String QUERY_ORDER_HOT = "PRAISE";
  static const  String QUERY_ORDER_TIME = "TIME";
  int id;
  int topicId;

  bool child;
  String body;
  SimpleAccount author;
  SimpleAccount tarAccount;
  int praiseCount;
  bool praised;
  int replyCount;
  int hot;
  DateTime sentTime;

  Map<String, dynamic> toJson() => _$BaseTopicReplyToJson(this);

  factory BaseTopicReply.fromJson(Map<String, dynamic> json) => _$BaseTopicReplyFromJson(json);

  BaseTopicReply();
}
