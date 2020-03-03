import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:json_annotation/json_annotation.dart';


part 'popular_message.g.dart';

@JsonSerializable()
class PopularMessage extends AbstractMessage {
  String tweetBody;
  String coverUrl;
  int tweetId;

  PopularMessage();

  Map<String, dynamic> toJson() => _$PopularMessageToJson(this);

  factory PopularMessage.fromJson(Map<String, dynamic> json) => _$PopularMessageFromJson(json);

}
