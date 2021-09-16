import 'package:iap_app/model/account/simple_account.dart';
import 'package:iap_app/model/media.dart';
import 'package:iap_app/model/university.dart';
import 'package:json_annotation/json_annotation.dart';

part 'topic.g.dart';

@JsonSerializable()
class Topic {

  static const STATUS_OPEN = "OPEN";
  static const STATUS_CLOSE = "CLOSE";
  int id;

  // 作者
  SimpleAccount author;

  // 大学（组织）
  University university;

  // 状态
  String status;
  String type;

  // 正文
  String title;

  // 附加
  String body;

  // 标签
  List<String> tags;

  // 封面
  String coverUrl;

  List<Media> medias;

  int clickCount;

  int participantsCount;
  int viewCount;
  int hot;
  int replyCount;

//  /*
//   * 直接回复
//   */
//  List<TweetReply> dirReplies;

  DateTime sentTime;
  DateTime gmtModified;
  DateTime gmtCreated;

  Topic();

  Map<String, dynamic> toJson() => _$TopicToJson(this);

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);
}
