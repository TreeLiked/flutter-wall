import 'package:flutter/material.dart';

class ContainerText extends StatelessWidget {
  final String text;
  final double topMargin;
  final TextStyle style;

  ContainerText({@required this.text, this.topMargin = 10.0, this.style});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      alignment: Alignment.topCenter,
      child: Text(
        '$text',
        style: style,
      ),
    );
  }
}
