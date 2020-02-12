// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddTopic _$AddTopicFromJson(Map<String, dynamic> json) {
  return AddTopic()
    ..orgId = json['orgId'] as int
    ..title = json['title'] as String
    ..body = json['body'] as String
    ..medias = (json['medias'] as List)
        ?.map(
            (e) => e == null ? null : Media.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..tags = (json['tags'] as List)?.map((e) => e as String)?.toList()
    ..sentTime = json['sentTime'] as String;
}

Map<String, dynamic> _$AddTopicToJson(AddTopic instance) => <String, dynamic>{
      'orgId': instance.orgId,
      'title': instance.title,
      'body': instance.body,
      'medias': instance.medias,
      'tags': instance.tags,
      'sentTime': instance.sentTime
    };
