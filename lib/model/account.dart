import 'package:json_annotation/json_annotation.dart';
part 'account.g.dart';

@JsonSerializable()
class Account {
  String id;
  String nick;
  String signature;
  // User user;
  String avatarUrl;
  // AccountStatus status;
  // AccountRole role;
  String mobile;
  int regType;
  String openId;

  Account();

  Account.fromId(String id) {
    this.id = id;
  }

  Map<String, dynamic> toJson() => _$AccountToJson(this);

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
