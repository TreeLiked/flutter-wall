// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Topic _$TopicFromJson(Map<String, dynamic> json) {
  return Topic()
    ..id = json['id'] as int
    ..author = json['author'] == null
        ? null
        : SimpleAccount.fromJson(json['author'] as Map<String, dynamic>)
    ..university = json['university'] == null
        ? null
        : University.fromJson(json['university'] as Map<String, dynamic>)
    ..status = json['status'] as String
    ..type = json['type'] as String
    ..title = json['title'] as String
    ..body = json['body'] as String
    ..tags = (json['tags'] as List)?.map((e) => e as String)?.toList()
    ..coverUrl = json['coverUrl'] as String
    ..medias = (json['medias'] as List)
        ?.map(
            (e) => e == null ? null : Media.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..clickCount = json['clickCount'] as int
    ..participantsCount = json['participantsCount'] as int
    ..viewCount = json['viewCount'] as int
    ..hot = json['hot'] as int
    ..replyCount = json['replyCount'] as int
    ..sentTime = json['sentTime'] == null
        ? null
        : DateTime.parse(json['sentTime'] as String)
    ..gmtModified = json['gmtModified'] == null
        ? null
        : DateTime.parse(json['gmtModified'] as String)
    ..gmtCreated = json['gmtCreated'] == null
        ? null
        : DateTime.parse(json['gmtCreated'] as String);
}

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
      'id': instance.id,
      'author': instance.author,
      'university': instance.university,
      'status': instance.status,
      'type': instance.type,
      'title': instance.title,
      'body': instance.body,
      'tags': instance.tags,
      'coverUrl': instance.coverUrl,
      'medias': instance.medias,
      'clickCount': instance.clickCount,
      'participantsCount': instance.participantsCount,
      'viewCount': instance.viewCount,
      'hot': instance.hot,
      'replyCount': instance.replyCount,
      'sentTime': instance.sentTime?.toIso8601String(),
      'gmtModified': instance.gmtModified?.toIso8601String(),
      'gmtCreated': instance.gmtCreated?.toIso8601String()
    };
