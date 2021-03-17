import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/media.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class CircleTweet {
  int id;

  // 圈子ID
  int circleId;

  // 归属的组织ID
  int orgId;

  Account account;

  String body;

  // 浏览量
  int view;

  // 回复人数
  int replyCount;

  // 是只有圈子内的用户可以查看
  bool displayOnlyCircle;

  // 媒体，图片或者视频
  List<Media> medias;


  // 时间等
  DateTime sentTime;
  DateTime gmtCreated;
  DateTime gmtModified;
}
