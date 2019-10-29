import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WidgetUtil {
  static Widget getAsset(String path,
      {double size = 20, bool click = false, final callback}) {
    if (!click) {
      return Image.asset(
        path,
        width: size,
        height: size,
      );
    } else {
      return GestureDetector(
          onTap: () => callback(),
          child: Image.asset(
            path,
            width: size,
            height: size,
          ));
    }
  }

  static Widget getIcon(IconData iconData, Color color,
      {double size = 20, bool click = false, final callback}) {
    if (!click) {
      return Icon(
        iconData,
        color: color,
        size: size,
      );
    } else {
      return GestureDetector(
          onTap: () => callback(),
          child: Icon(
            iconData,
            color: color,
            size: size,
          ));
    }
  }
}
