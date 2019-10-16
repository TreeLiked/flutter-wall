// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User()
    ..nick = json['nick'] as String
    ..signature = json['signature'] as String
    ..avatarUrl = json['avatarUrl'] as String
    ..mobile = json['mobile'] as String
    ..regType = json['regType'] as int
    ..openId = json['openId'] as String;
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'nick': instance.nick,
      'signature': instance.signature,
      'avatarUrl': instance.avatarUrl,
      'mobile': instance.mobile,
      'regType': instance.regType,
      'openId': instance.openId
    };
