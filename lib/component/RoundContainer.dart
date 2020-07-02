import 'package:flutter/material.dart';

class RoundContainer extends StatelessWidget {
  final double radius;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color backgroundColor;

  RoundContainer({this.radius = 5.0, this.child, this.padding, this.margin, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius), color: backgroundColor),
      child: child,
    );
  }
}
