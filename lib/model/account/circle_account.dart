
import 'package:json_annotation/json_annotation.dart';

part 'circle_account.g.dart';
@JsonSerializable()
class CircleAccount {

  /// 主键
  String id;

  /// 昵称
  String nick;

  /// 个性签名
  String signature;

  /// 头像链接
  String avatarUrl;

  /// 学院
  String institute;

  /// 班级
  String cla;

  String gender;

  CircleAccount();


  Map<String, dynamic> toJson() => _$CircleAccountToJson(this);

  factory CircleAccount.fromJson(Map<String, dynamic> json) => _$CircleAccountFromJson(json);

}