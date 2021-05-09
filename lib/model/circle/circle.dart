import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/account_role.dart';
import 'package:iap_app/model/account/circle_account.dart';
import 'package:iap_app/util/string.dart';
import 'package:json_annotation/json_annotation.dart';

part 'circle.g.dart';

@JsonSerializable()
class Circle {
  static const String JOIN_TYPE_DIRECT = "DIRECT";
  static const String JOIN_TYPE_ADMIN_AGREE = "ADMIN_AGREE";
  static const String JOIN_TYPE_REFUSE_ALL = "REFUSE";

  static const int MAX_ACCOUNT_LIMIT_20 = 20;
  static const int MAX_ACCOUNT_LIMIT_50 = 50;
  static const int MAX_ACCOUNT_LIMIT_100 = 100;
  static const int MAX_ACCOUNT_LIMIT_200 = 200;
  static const int MAX_ACCOUNT_LIMIT_500 = 500;
  static const int MAX_ACCOUNT_LIMIT_1000 = 1000;

  int id;

  // 归属的组织ID
  int orgId;

  // 圈子的类型
  String circleType;

  // 圈子简介
  String brief;

  // 圈子描述
  String desc;

  // 圈子的图片封面
  String cover;

  // 圈子的创建用户
  CircleAccount creator;

  // 浏览量
  int view;

  // 参与人数
  int participants;

  // 限制可加入的最多人数
  int limit;

  // 当前圈子的状态
  String state;

  // 加入类型
  String joinType;

  // 是否圈子内容隐私
  bool contentPrivate;

  bool meJoined;

  CircleAccountRole meRole;

  // 瀑布流的展示效果，如果true则为长的那个
  @JsonKey(ignore: true, required: false, nullable: true, includeIfNull: false)
  bool higher;

  // 时间等
  DateTime gmtCreated;
  DateTime gmtModified;

  Circle();

  Map<String, dynamic> toJson() => _$CircleToJson(this);

  factory Circle.fromJson(Map<String, dynamic> json) => _$CircleFromJson(json);
}
