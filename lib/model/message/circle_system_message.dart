import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/circle/circle_approval.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:json_annotation/json_annotation.dart';

part 'circle_system_message.g.dart';

@JsonSerializable()
class CircleSystemMessage extends AbstractMessage {
  /// apply
  int circleId;
  String title;
  String content;
  CircleApproval approval;
  Account applyAccount;

  /// apply res 增加
  Account optAccount;

  /// simple notification

  CircleSystemMessage();

  Map<String, dynamic> toJson() => _$CircleSystemMessageToJson(this);

  factory CircleSystemMessage.fromJson(Map<String, dynamic> json) => _$CircleSystemMessageFromJson(json);
}
