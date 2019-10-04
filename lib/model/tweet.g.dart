// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tweet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseTweet _$BaseTweetFromJson(Map<String, dynamic> json) {
  return BaseTweet()
    ..id = json['id'] as int
    ..unId = json['unId'] as int
    ..body = json['body'] as String
    ..type = json['type'] as String
    ..anonymous = json['anonymous'] as bool
    ..account = json['account']
    ..enableReply = json['enableReply'] as bool
    ..pics = (json['pics'] as List)?.map((e) => e as String)?.toList()
    ..hot = json['hot'] as int
    ..praise = json['praise'] as int
    ..views = json['views'] as int
    ..replyCount = json['replyCount'] as int
    ..gmtModified = json['gmtModified'] == null
        ? null
        : DateTime.parse(json['gmtModified'] as String)
    ..gmtCreated = json['gmtCreated'] == null
        ? null
        : DateTime.parse(json['gmtCreated'] as String);
}

Map<String, dynamic> _$BaseTweetToJson(BaseTweet instance) => <String, dynamic>{
      'id': instance.id,
      'unId': instance.unId,
      'body': instance.body,
      'type': instance.type,
      'anonymous': instance.anonymous,
      'account': instance.account,
      'enableReply': instance.enableReply,
      'pics': instance.pics,
      'hot': instance.hot,
      'praise': instance.praise,
      'views': instance.views,
      'replyCount': instance.replyCount,
      'gmtModified': instance.gmtModified?.toIso8601String(),
      'gmtCreated': instance.gmtCreated?.toIso8601String()
    };
