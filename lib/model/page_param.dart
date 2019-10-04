import 'package:json_annotation/json_annotation.dart';

part 'page_param.g.dart';

@JsonSerializable()
class PageParam {
  int currentPage;
  int pageSize;
  PageParam(this.currentPage, {this.pageSize = 10});

  Map<String, dynamic> toJson() => _$PageParamToJson(this);
}
