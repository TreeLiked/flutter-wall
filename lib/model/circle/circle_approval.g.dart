// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circle_approval.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CircleApproval _$CircleApprovalFromJson(Map<String, dynamic> json) {
  return CircleApproval()
    ..id = json['id'] as int
    ..circleId = json['circleId'] as int
    ..circleName = json['circleName'] as String
    ..applyAccountId = json['applyAccountId'] as String
    ..status = json['status'] as int
    ..optAccountId = json['optAccountId'] as String
    ..gmtCreated = json['gmtCreated'] == null
        ? null
        : DateTime.parse(json['gmtCreated'] as String)
    ..gmtModified = json['gmtModified'] == null
        ? null
        : DateTime.parse(json['gmtModified'] as String);
}

Map<String, dynamic> _$CircleApprovalToJson(CircleApproval instance) =>
    <String, dynamic>{
      'id': instance.id,
      'circleId': instance.circleId,
      'circleName': instance.circleName,
      'applyAccountId': instance.applyAccountId,
      'status': instance.status,
      'optAccountId': instance.optAccountId,
      'gmtCreated': instance.gmtCreated?.toIso8601String(),
      'gmtModified': instance.gmtModified?.toIso8601String(),
    };
