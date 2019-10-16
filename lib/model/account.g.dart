// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) {
  return Account()
    ..id = json['id'] as String
    ..nick = json['nick'] as String
    ..signature = json['signature'] as String
    ..avatarUrl = json['avatarUrl'] as String
    ..mobile = json['mobile'] as String
    ..regType = json['regType'] as int
    ..openId = json['openId'] as String;
}

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'id': instance.id,
      'nick': instance.nick,
      'signature': instance.signature,
      'avatarUrl': instance.avatarUrl,
      'mobile': instance.mobile,
      'regType': instance.regType,
      'openId': instance.openId
    };
