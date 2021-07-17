// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Circle _$CircleFromJson(Map<String, dynamic> json) {
  return Circle()
    ..id = json['id'] as int
    ..orgId = json['orgId'] as int
    ..circleType = json['circleType'] as String
    ..brief = json['brief'] as String
    ..desc = json['desc'] as String
    ..cover = json['cover'] as String
    ..creator = json['creator'] == null
        ? null
        : CircleAccount.fromJson(json['creator'] as Map<String, dynamic>)
    ..view = json['view'] as int
    ..participants = json['participants'] as int
    ..limit = json['limit'] as int
    ..state = json['state'] as String
    ..joinType = json['joinType'] as String
    ..contentPrivate = json['contentPrivate'] as bool
    ..meJoined = json['meJoined'] as bool
    ..meRole = _$enumDecodeNullable(_$CircleAccountRoleEnumMap, json['meRole'])
    ..gmtCreated = json['gmtCreated'] == null
        ? null
        : DateTime.parse(json['gmtCreated'] as String)
    ..gmtModified = json['gmtModified'] == null
        ? null
        : DateTime.parse(json['gmtModified'] as String);
}

Map<String, dynamic> _$CircleToJson(Circle instance) => <String, dynamic>{
  'id': instance.id,
  'orgId': instance.orgId,
  'circleType': instance.circleType,
  'brief': instance.brief,
  'desc': instance.desc,
  'cover': instance.cover,
  'creator': instance.creator,
  'view': instance.view,
  'participants': instance.participants,
  'limit': instance.limit,
  'state': instance.state,
  'joinType': instance.joinType,
  'contentPrivate': instance.contentPrivate,
  'meJoined': instance.meJoined,
  'meRole': _$CircleAccountRoleEnumMap[instance.meRole],
  'gmtCreated': instance.gmtCreated?.toIso8601String(),
  'gmtModified': instance.gmtModified?.toIso8601String(),
};

T _$enumDecode<T>(
    Map<T, dynamic> enumValues,
    dynamic source, {
      T unknownValue,
    }) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
    Map<T, dynamic> enumValues,
    dynamic source, {
      T unknownValue,
    }) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$CircleAccountRoleEnumMap = {
  CircleAccountRole.CREATOR: 'CREATOR',
  CircleAccountRole.ADMIN: 'ADMIN',
  CircleAccountRole.USER: 'USER',
  CircleAccountRole.GUEST: 'GUEST',
};
