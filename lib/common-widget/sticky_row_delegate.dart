import 'package:flutter/material.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/util/collection.dart';

class StickyRowDelegate extends SliverPersistentHeaderDelegate {
  final List<Widget> children;

  final double height;
  final EdgeInsets padding;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final Color bgColor;

  StickyRowDelegate(
      {@required this.children,
      @required this.height,
      this.padding,
      this.bgColor,
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.crossAxisAlignment = CrossAxisAlignment.end});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    if (children == null || children.isEmpty) {
      return Gaps.empty;
    }
    return Container(
        color: bgColor,
        padding: padding,
        height: height,
        child: Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children));
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => CollectionUtil.isListEmpty(children) ? 0 : height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
