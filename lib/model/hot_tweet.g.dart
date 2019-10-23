// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hot_tweet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HotTweet _$HotTweetFromJson(Map<String, dynamic> json) {
  return HotTweet()
    ..orgId = json['orgId'] as int
    ..tweets = (json['tweets'] as List)
        ?.map((e) =>
            e == null ? null : BaseTweet.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..lastFetched = json['lastFetched'] == null
        ? null
        : DateTime.parse(json['lastFetched'] as String)
    ..gmtCreated = json['gmtCreated'] == null
        ? null
        : DateTime.parse(json['gmtCreated'] as String);
}

Map<String, dynamic> _$HotTweetToJson(HotTweet instance) => <String, dynamic>{
      'orgId': instance.orgId,
      'tweets': instance.tweets,
      'lastFetched': instance.lastFetched?.toIso8601String(),
      'gmtCreated': instance.gmtCreated?.toIso8601String()
    };
