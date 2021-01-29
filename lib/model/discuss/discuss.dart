import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Discuss {
  String id;

  // 话题标题
  String title;

  // 话题封面
  String cover;
}
