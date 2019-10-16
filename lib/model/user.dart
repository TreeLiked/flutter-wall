import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  String nick;
  String signature;
  // User user;
  String avatarUrl;
  // AccountStatus status;
  // AccountRole role;
  String mobile;
  int regType;
  String openId;
}
