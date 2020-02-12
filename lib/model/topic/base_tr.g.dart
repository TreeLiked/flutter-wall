// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_tr.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MainTopicReply _$MainTopicReplyFromJson(Map<String, dynamic> json) {
  return MainTopicReply()
    ..id = json['id'] as int
    ..child = json['child'] as bool
    ..body = json['body'] as String
    ..author = json['author'] == null
        ? null
        : SimpleAccount.fromJson(json['author'] as Map<String, dynamic>)
    ..tarAccount = json['tarAccount'] == null
        ? null
        : SimpleAccount.fromJson(json['tarAccount'] as Map<String, dynamic>)
    ..praiseCount = json['praiseCount'] as int
    ..praised = json['praised'] as bool
    ..replyCount = json['replyCount'] as int
    ..hot = json['hot'] as int
    ..sentTime = json['sentTime'] == null
        ? null
        : DateTime.parse(json['sentTime'] as String)
    ..topicId = json['topicId'] as int
    ..subReplies = (json['subReplies'] as List)
        ?.map((e) => e == null
            ? null
            : SubTopicReply.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$MainTopicReplyToJson(MainTopicReply instance) =>
    <String, dynamic>{
      'id': instance.id,
      'child': instance.child,
      'body': instance.body,
      'author': instance.author,
      'tarAccount': instance.tarAccount,
      'praiseCount': instance.praiseCount,
      'praised': instance.praised,
      'replyCount': instance.replyCount,
      'hot': instance.hot,
      'sentTime': instance.sentTime?.toIso8601String(),
      'topicId': instance.topicId,
      'subReplies': instance.subReplies
    };

SubTopicReply _$SubTopicReplyFromJson(Map<String, dynamic> json) {
  return SubTopicReply()
    ..id = json['id'] as int
    ..topicId = json['topicId'] as int
    ..body = json['body'] as String
    ..author = json['author'] == null
        ? null
        : SimpleAccount.fromJson(json['author'] as Map<String, dynamic>)
    ..tarAccount = json['tarAccount'] == null
        ? null
        : SimpleAccount.fromJson(json['tarAccount'] as Map<String, dynamic>)
    ..praiseCount = json['praiseCount'] as int
    ..praised = json['praised'] as bool
    ..replyCount = json['replyCount'] as int
    ..hot = json['hot'] as int
    ..sentTime = json['sentTime'] == null
        ? null
        : DateTime.parse(json['sentTime'] as String)
    ..child = json['child'] as bool
    ..refId = json['refId'] as int;
}

Map<String, dynamic> _$SubTopicReplyToJson(SubTopicReply instance) =>
    <String, dynamic>{
      'id': instance.id,
      'topicId': instance.topicId,
      'body': instance.body,
      'author': instance.author,
      'tarAccount': instance.tarAccount,
      'praiseCount': instance.praiseCount,
      'praised': instance.praised,
      'replyCount': instance.replyCount,
      'hot': instance.hot,
      'sentTime': instance.sentTime?.toIso8601String(),
      'child': instance.child,
      'refId': instance.refId
    };

BaseTopicReply _$BaseTopicReplyFromJson(Map<String, dynamic> json) {
  return BaseTopicReply()
    ..id = json['id'] as int
    ..topicId = json['topicId'] as int
    ..child = json['child'] as bool
    ..body = json['body'] as String
    ..author = json['author'] == null
        ? null
        : SimpleAccount.fromJson(json['author'] as Map<String, dynamic>)
    ..tarAccount = json['tarAccount'] == null
        ? null
        : SimpleAccount.fromJson(json['tarAccount'] as Map<String, dynamic>)
    ..praiseCount = json['praiseCount'] as int
    ..praised = json['praised'] as bool
    ..replyCount = json['replyCount'] as int
    ..hot = json['hot'] as int
    ..sentTime = json['sentTime'] == null
        ? null
        : DateTime.parse(json['sentTime'] as String);
}

Map<String, dynamic> _$BaseTopicReplyToJson(BaseTopicReply instance) =>
    <String, dynamic>{
      'id': instance.id,
      'topicId': instance.topicId,
      'child': instance.child,
      'body': instance.body,
      'author': instance.author,
      'tarAccount': instance.tarAccount,
      'praiseCount': instance.praiseCount,
      'praised': instance.praised,
      'replyCount': instance.replyCount,
      'hot': instance.hot,
      'sentTime': instance.sentTime?.toIso8601String()
    };
