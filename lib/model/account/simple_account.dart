import 'package:json_annotation/json_annotation.dart';

part 'simple_account.g.dart';

@JsonSerializable()
class SimpleAccount {
  String id;
  String nick;
  String signature;

  // User user;
  String avatarUrl;
  String gender;
  SimpleAccount();

  SimpleAccount.fromId(String id) {
    this.id = id;
  }

  Map<String, dynamic> toJson() => _$SimpleAccountToJson(this);

  factory SimpleAccount.fromJson(Map<String, dynamic> json) => _$SimpleAccountFromJson(json);
}
