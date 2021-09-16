import 'package:flutter/material.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/util/collection.dart';

class StickyEmptyDelegate extends SliverPersistentHeaderDelegate {
  const StickyEmptyDelegate();

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Gaps.empty;
  }

  @override
  double get maxExtent => 0;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
