import 'package:iap_app/model/account/account_profile.dart';
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

  DateTime birthDay;

  String gender;

  String province;
  String city;
  String districtl;

  String qq;
  String weixin;

  AccountProfile profile;

  Account();

  Account.fromId(String id) {
    this.id = id;
  }

  Map<String, dynamic> toJson() => _$AccountToJson(this);

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
