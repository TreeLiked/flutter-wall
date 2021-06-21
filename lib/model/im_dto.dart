import 'package:event_bus/event_bus.dart';
import 'package:iap_app/model/account/account_profile.dart';
import 'package:json_annotation/json_annotation.dart';

part 'im_dto.g.dart';

@JsonSerializable()
// ws 命令消息总线
final EventBus wsCommandEventBus = EventBus();

class ImDTO<D> {
  static const int COMMAND_TWEET_CREATED = 200;
  static const int COMMAND_TWEET_PRAISED = 201;
  static const int COMMAND_TWEET_REPLIED = 202;
  static const int COMMAND_TWEET_DELETED = 203;

  static const int COMMAND_PULL_MSG = 900;

  int command;
  D data;

  ImDTO();

  Map<String, dynamic> toJson() => _$ImDTOToJson(this);

  factory ImDTO.fromJson(Map<String, dynamic> json) => _$ImDTOFromJson(json);
}
