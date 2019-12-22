
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

/// 链接器Header
class LinkHeader extends Header {
  final LinkHeaderNotifier linkNotifier;

  LinkHeader(
      this.linkNotifier, {
        extent = 60.0,
        triggerDistance = 70.0,
        completeDuration,
        enableHapticFeedback = false,
      }) : super(
    extent: extent,
    triggerDistance: triggerDistance,
    float: true,
    completeDuration: completeDuration,
    enableHapticFeedback: enableHapticFeedback,
  );

  @override
  Widget contentBuilder(
      BuildContext context,
      RefreshMode refreshState,
      double pulledExtent,
      double refreshTriggerPullDistance,
      double refreshIndicatorExtent,
      AxisDirection axisDirection,
      bool float,
      Duration completeDuration,
      bool enableInfiniteRefresh,
      bool success,
      bool noMore) {
    linkNotifier.contentBuilder(
        context,
        refreshState,
        pulledExtent,
        refreshTriggerPullDistance,
        refreshIndicatorExtent,
        axisDirection,
        float,
        completeDuration,
        enableInfiniteRefresh,
        success,
        noMore);
    return SizedBox(
      width: 0.0,
      height: 0.0,
    );
  }
}
