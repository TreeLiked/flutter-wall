// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimpleAccount _$SimpleAccountFromJson(Map<String, dynamic> json) {
  return SimpleAccount()
    ..id = json['id'] as String
    ..nick = json['nick'] as String
    ..signature = json['signature'] as String
    ..avatarUrl = json['avatarUrl'] as String
    ..gender = json['gender'] as String;
}

Map<String, dynamic> _$SimpleAccountToJson(SimpleAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nick': instance.nick,
      'signature': instance.signature,
      'avatarUrl': instance.avatarUrl,
      'gender': instance.gender
    };
