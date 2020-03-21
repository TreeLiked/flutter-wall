// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tweet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseTweet _$BaseTweetFromJson(Map<String, dynamic> json) {
  return BaseTweet()
    ..id = json['id'] as int
    ..orgId = json['orgId'] as int
    ..body = json['body'] as String
    ..type = json['type'] as String
    ..anonymous = json['anonymous'] as bool
    ..account = json['account'] == null ? null : Account.fromJson(json['account'] as Map<String, dynamic>)
    ..enableReply = json['enableReply'] as bool
    ..medias = (json['medias'] as List)
        ?.map((e) => e == null ? null : Media.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..hot = json['hot'] as int
    ..praise = json['praise'] as int
    ..views = json['views'] as int
    ..replyCount = json['replyCount'] as int
    ..upTrend = json['upTrend'] as bool
    ..dirReplies = (json['dirReplies'] as List)
        ?.map((e) => e == null ? null : TweetReply.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..latestPraise = (json['latestPraise'] as List)
        ?.map((e) => e == null ? null : Account.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..gmtModified = json['gmtModified'] == null ? null : DateTime.parse(json['gmtModified'] as String)
    ..gmtCreated = json['gmtCreated'] == null ? null : DateTime.parse(json['gmtCreated'] as String)
    ..sentTime = json['sentTime'] == null ? null : DateTime.parse(json['sentTime'] as String)
    ..loved = json['loved'] as bool;
}

Map<String, dynamic> _$BaseTweetToJson(BaseTweet instance) => <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'body': instance.body,
      'type': instance.type,
      'anonymous': instance.anonymous,
      'account': instance.account,
      'enableReply': instance.enableReply,
      'medias': instance.medias,
      'hot': instance.hot,
      'praise': instance.praise,
      'views': instance.views,
      'replyCount': instance.replyCount,
      'upTrend': instance.upTrend,
      'dirReplies': instance.dirReplies,
      'latestPraise': instance.latestPraise,
      'gmtModified': instance.gmtModified?.toIso8601String(),
      'gmtCreated': instance.gmtCreated?.toIso8601String(),
      'sentTime': DateUtil.formatDate(instance.sentTime, format: 'yyyy-MM-dd HH:mm:ss'),
      'loved': instance.loved
    };
