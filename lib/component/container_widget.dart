import 'package:flutter/material.dart';

class ContainerWidget extends StatelessWidget {
  final Widget widget;
  final double topMargin;
  final TextStyle style;

  ContainerWidget({@required this.widget, this.topMargin = 10.0, this.style});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      alignment: Alignment.topCenter,
      child: widget
    );
  }
}
