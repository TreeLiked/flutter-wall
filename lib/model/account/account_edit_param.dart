import 'package:json_annotation/json_annotation.dart';

part 'account_edit_param.g.dart';

@JsonSerializable()
class AccountEditParam {
  final String key;
  final String value;

  const AccountEditParam(this.key, this.value);

  Map<String, dynamic> toJson() => _$AccountEditParamToJson(this);

  static const String SIGNATURE = "SIGNATURE";
  static const String NICK = "NICK";
  static const String AVATAR = "AVATAR";
  static const String NAME = "NAME";
  static const String MOBILE = "MOBILE";
  static const String EMAIL = "EMAIL";
}
