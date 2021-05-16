
import 'package:json_annotation/json_annotation.dart';

part 'circle_account.g.dart';
@JsonSerializable()
class CircleAccount {
  String id;
  String nick;
  String signature;
  String gender;
  String avatarUrl;
  String institute;
  String cla;
  String circleId;
  CircleAccountRole role;
  List<String> tags;
  String levelName;

  CircleAccount();

  Map<String, dynamic> toJson() => _$CircleAccountToJson(this);

  factory CircleAccount.fromJson(Map<String, dynamic> json) => _$CircleAccountFromJson(json);
}

enum CircleAccountRole { CREATOR, ADMIN, USER, GUEST }