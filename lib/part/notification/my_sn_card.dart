import 'package:flutter/material.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/util/theme_utils.dart';

class MyShadowCard extends StatelessWidget {
  const MyShadowCard(
      {Key key,
      @required this.child,
      this.color,
      this.dotColor,
      this.shadowColor,
      this.margin = const EdgeInsets.only(top: 6.0),
      this.radius = 11.0,
      this.onClick})
      : super(key: key);

  final Widget child;
  final Color color;
  final Color dotColor;
  final Color shadowColor;
  final EdgeInsetsGeometry margin;
  final Function onClick;
  final double radius;

  @override
  Widget build(BuildContext context) {
    Color _backgroundColor;
    Color _shadowColor;
    bool isDark = ThemeUtils.isDark(context);
    if (color == null) {
      _backgroundColor = isDark ? Colours.dark_bg_gray_ : Colors.white;
    } else {
      _backgroundColor = color;
    }

    if (shadowColor == null) {
      _shadowColor = isDark ? Colors.transparent : const Color(0x80DCE7FA);
    } else {
      _shadowColor = isDark ? shadowColor : shadowColor;
    }

    return onClick != null
        ? GestureDetector(
            onTap: onClick,
            child: Container(
                margin: margin,
                decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(radius),
                    boxShadow: [
                      BoxShadow(
                          color: _shadowColor, offset: Offset(0.0, 1.0), blurRadius: 8.0, spreadRadius: 0.0),
                    ]),
                child: child),
          )
        : Container(
            margin: margin,
            decoration:
                BoxDecoration(color: _backgroundColor, borderRadius: BorderRadius.circular(radius), boxShadow: [
              BoxShadow(color: _shadowColor, offset: Offset(0.0, 1.0), blurRadius: 8.0, spreadRadius: 0.0),
            ]),
            child: child);
  }
}
