import 'package:json_annotation/json_annotation.dart';

part 'university.g.dart';

@JsonSerializable()
class University {
  int id;
  String name;
  String enAbbr;

  University();

  Map<String, dynamic> toJson() => _$UniversityToJson(this);

  factory University.fromJson(Map<String, dynamic> json) =>
      _$UniversityFromJson(json);
}
