
import 'package:json_annotation/json_annotation.dart';

part 'circle_approval.g.dart';


@JsonSerializable()
class CircleApproval {
  int id;
  int circleId;
  String circleName;
  String applyAccountId;
  int status;
  String optAccountId;
  DateTime gmtCreated;
  DateTime gmtModified;

  CircleApproval();

  Map<String, dynamic> toJson() => _$CircleApprovalToJson(this);

  factory CircleApproval.fromJson(Map<String, dynamic> json) => _$CircleApprovalFromJson(json);

}
