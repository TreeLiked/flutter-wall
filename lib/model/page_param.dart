import 'package:json_annotation/json_annotation.dart';

part 'page_param.g.dart';

@JsonSerializable()
class PageParam {
  int currentPage;
  int pageSize;
  // 限制查询的推文类型
  List<String> types;

  PageParam(this.currentPage, {this.pageSize = 10, this.types});

  Map<String, dynamic> toJson() => _$PageParamToJson(this);
}
