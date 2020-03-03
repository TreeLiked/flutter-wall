import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:json_annotation/json_annotation.dart';

part 'plain_system_message.g.dart';

@JsonSerializable()
class PlainSystemMessage extends AbstractMessage {
  String title;
  String content;
  bool hasCover;
  String coverUrl;
  bool hasLink;
  String linkUrl;


  PlainSystemMessage();
  Map<String, dynamic> toJson() => _$PlainSystemMessageToJson(this);

  factory PlainSystemMessage.fromJson(Map<String, dynamic> json) => _$PlainSystemMessageFromJson(json);

}
