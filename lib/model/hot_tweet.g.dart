// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hot_tweet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UniHotTweet _$UniHotTweetFromJson(Map<String, dynamic> json) {
  return UniHotTweet()
    ..orgId = json['orgId'] as int
    ..tweets = (json['tweets'] as List)
        ?.map((e) =>
            e == null ? null : HotTweet.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..lastFetched = json['lastFetched'] == null
        ? null
        : DateTime.parse(json['lastFetched'] as String)
    ..gmtCreated = json['gmtCreated'] == null
        ? null
        : DateTime.parse(json['gmtCreated'] as String);
}

Map<String, dynamic> _$UniHotTweetToJson(UniHotTweet instance) =>
    <String, dynamic>{
      'orgId': instance.orgId,
      'tweets': instance.tweets,
      'lastFetched': instance.lastFetched?.toIso8601String(),
      'gmtCreated': instance.gmtCreated?.toIso8601String()
    };

HotTweet _$HotTweetFromJson(Map<String, dynamic> json) {
  return HotTweet()
    ..id = json['id'] as int
    ..orgId = json['orgId'] as int
    ..anonymous = json['anonymous'] as bool
    ..account = json['account'] == null
        ? null
        : SimpleAccount.fromJson(json['account'] as Map<String, dynamic>)
    ..body = json['body'] as String
    ..cover = json['cover'] == null
        ? null
        : Media.fromJson(json['cover'] as Map<String, dynamic>)
    ..type = json['type'] as String
    ..sentTime = json['sentTime'] == null
        ? null
        : DateTime.parse(json['sentTime'] as String)
    ..hot = json['hot'] as int
    ..upTrend = json['upTrend'] as bool;
}

Map<String, dynamic> _$HotTweetToJson(HotTweet instance) => <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'anonymous': instance.anonymous,
      'account': instance.account,
      'body': instance.body,
      'cover': instance.cover,
      'type': instance.type,
      'sentTime': instance.sentTime?.toIso8601String(),
      'hot': instance.hot,
      'upTrend': instance.upTrend
    };
