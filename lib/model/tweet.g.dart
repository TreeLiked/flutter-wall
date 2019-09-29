// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tweet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseTweet _$BaseTweetFromJson(Map<String, dynamic> json) {
  return BaseTweet(
      json['body'] as String, json['type'] as String, json['anonymous'] as bool)
    ..id = json['id'] as int
    ..unId = json['unId'] as int
    ..account = json['account']
    ..enableReply = json['enableReply'] as bool
    ..pics = (json['pics'] as List)?.map((e) => e as String)?.toList();
}

Map<String, dynamic> _$BaseTweetToJson(BaseTweet instance) => <String, dynamic>{
      'id': instance.id,
      'unId': instance.unId,
      'body': instance.body,
      'type': instance.type,
      'anonymous': instance.anonymous,
      'account': instance.account,
      'enableReply': instance.enableReply,
      'pics': instance.pics
    };
