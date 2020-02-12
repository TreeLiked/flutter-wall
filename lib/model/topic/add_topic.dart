import 'package:iap_app/model/media.dart';
import 'package:json_annotation/json_annotation.dart';

part 'add_topic.g.dart';

@JsonSerializable()
class AddTopic {
  int orgId;
  String title;
  String body;
  List<Media> medias;
  List<String> tags;
  String sentTime;

  Map<String, dynamic> toJson() => _$AddTopicToJson(this);

  factory AddTopic.fromJson(Map<String, dynamic> json) => _$AddTopicFromJson(json);

  AddTopic();
}
