import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/res/gaps.dart';
import 'dart:math';

class StackAvatars extends StatelessWidget {
  List<String> avatarUrls;
  int max;
  double size;

  // 重叠的头像显示的百分比
  double showFactor;
  bool whitePadding;

  StackAvatars(this.avatarUrls, {this.max = 3, this.size = 20, this.showFactor = 0.5, this.whitePadding = false});

  @override
  Widget build(BuildContext context) {
    if (avatarUrls == null || avatarUrls.length == 0) {
      return Gaps.empty;
    }
    return Container(
        height: this.size,
        width: (min(this.avatarUrls.length, max) - 1) * (this.size * showFactor) + this.size,
        child: Stack(
          fit: StackFit.loose,
          children: _getStackedAvatarWidgets(),
        ));
  }

  _getStackedAvatarWidgets() {
    List<Widget> widgets = List();
    for (int i = 0; i < avatarUrls.length && i < max; i++) {
      widgets.add(_getSingleAvatar(i, avatarUrls[i]));
    }
    return widgets;
  }

  _getSingleAvatar(int index, String url) {
    return Positioned(
        child: AccountAvatar(avatarUrl: url, size: this.size, whitePadding: whitePadding),
        left: index * size * showFactor);
  }
}
