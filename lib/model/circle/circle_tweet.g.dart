// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circle_tweet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CircleTweet _$CircleTweetFromJson(Map<String, dynamic> json) {
  return CircleTweet()
    ..id = json['id'] as int
    ..circleId = json['circleId'] as int
    ..orgId = json['orgId'] as int
    ..account = json['account'] == null
        ? null
        : CircleAccount.fromJson(json['account'] as Map<String, dynamic>)
    ..body = json['body'] as String
    ..views = json['views'] as int
    ..replyCount = json['replyCount'] as int
    ..displayOnlyCircle = json['displayOnlyCircle'] as bool
    ..medias = (json['medias'] as List)
        ?.map(
            (e) => e == null ? null : Media.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..tags = (json['tags'] as List)?.map((e) => e as String)?.toList()
    ..deleted = json['deleted'] as bool
    ..sentTime = json['sentTime'] == null
        ? null
        : DateTime.parse(json['sentTime'] as String)
    ..gmtCreated = json['gmtCreated'] == null
        ? null
        : DateTime.parse(json['gmtCreated'] as String)
    ..gmtModified = json['gmtModified'] == null
        ? null
        : DateTime.parse(json['gmtModified'] as String);
}

Map<String, dynamic> _$CircleTweetToJson(CircleTweet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'circleId': instance.circleId,
      'orgId': instance.orgId,
      'account': instance.account,
      'body': instance.body,
      'views': instance.views,
      'replyCount': instance.replyCount,
      'displayOnlyCircle': instance.displayOnlyCircle,
      'medias': instance.medias,
      'tags': instance.tags,
      'deleted': instance.deleted,
      'sentTime': DateUtil.formatDate(instance.sentTime, format: DateFormats.full),
      'gmtCreated': instance.gmtCreated?.toIso8601String(),
      'gmtModified': instance.gmtModified?.toIso8601String(),
    };
