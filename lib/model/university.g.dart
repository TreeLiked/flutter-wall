// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'university.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

University _$UniversityFromJson(Map<String, dynamic> json) {
  return University()
    ..id = json['id'] as int
    ..name = json['name'] as String
    ..enAbbr = json['enAbbr'] as String;
}

Map<String, dynamic> _$UniversityToJson(University instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'enAbbr': instance.enAbbr
    };
