import 'package:flutter/material.dart';
import 'package:iap_app/index/index.dart';

void main() {
  runApp(Iap());
}


class Iap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'iap',
      home: Index(),
    );
  }
}


