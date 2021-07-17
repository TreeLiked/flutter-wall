import 'package:json_annotation/json_annotation.dart';


class CircleQueryParam {

  // 当前页
  int currentPage;

  // 查询数量
  int pageSize;

  // 是否限定查询的组织
  int orgId;

  List<int> circleIds;

  /**
   * 是否需要推荐查询圈子呢
   */
  bool needRecommend = true;

  /**
   * 需要推荐的数量
   */
  int recommendSize = 5;

  /**
   * 排除在外的circleId
   */
  List<int> excludeCircleIds;

  /**
   * 圈子类型
   */
  List<String> circleTypes;

  CircleQueryParam(this.currentPage, {this.pageSize = 10, this.orgId});

  Map<String, dynamic> toJson() => <String, dynamic>{
    'pageParam': {
      'currentPage': currentPage,
      'pageSize': pageSize,
    },
    'orgId': orgId,
    'circleTypes': circleTypes,
    'excludeCircleIds': excludeCircleIds,
    'recommendSize': recommendSize,
    'needRecommend': needRecommend,
  };
}
