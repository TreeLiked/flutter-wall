import 'package:json_annotation/json_annotation.dart';

part 'pub_v.g.dart';

@JsonSerializable()
class PubVersion {
  int versionId;
  String name;
  String mark;
  String platform;
  String apkUrl;
  DateTime pubTime;
  String description;
  String updateDesc;

  PubVersion();

  Map<String, dynamic> toJson() => _$PubVersionToJson(this);

  factory PubVersion.fromJson(Map<String, dynamic> json) => _$PubVersionFromJson(json);
}
