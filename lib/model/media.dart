import 'package:json_annotation/json_annotation.dart';

part 'media.g.dart';

@JsonSerializable()
class Media {
  static const String MODULE_TOPIC = "TOPIC";
  static const String MODULE_TWEET = "TWEET";
  static const String MODULE_AVATAR = "AVATAR";

  static const String TYPE_IMAGE = "IMAGE";
  static const String TYPE_VIDEO = "VIDEO";

  int index;
  String module;
  String mediaType = "PICTURE";
  String url;
  String name;

  Map<String, dynamic> toJson() => _$MediaToJson(this);

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);

  Media();
}