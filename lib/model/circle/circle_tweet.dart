import 'package:common_utils/common_utils.dart';
import 'package:iap_app/model/account/circle_account.dart';
import 'package:iap_app/model/media.dart';
import 'package:json_annotation/json_annotation.dart';

part 'circle_tweet.g.dart';

@JsonSerializable()
class CircleTweet {
  int id;

  // 圈子ID
  int circleId;

  // 归属的组织ID
  int orgId;

  CircleAccount account;

  String body;

  // 浏览量
  int views;

  // 回复人数
  int replyCount;

  // 是只有圈子内的用户可以查看
  bool displayOnlyCircle;

  // 媒体，图片或者视频
  List<Media> medias;

  // 标签
  List<String> tags;

  // 是否被删除
  bool deleted;

  // 时间等
  DateTime sentTime;
  DateTime gmtCreated;
  DateTime gmtModified;

  CircleTweet();

  Map<String, dynamic> toJson() => _$CircleTweetToJson(this);

  factory CircleTweet.fromJson(Map<String, dynamic> json) => _$CircleTweetFromJson(json);
}
