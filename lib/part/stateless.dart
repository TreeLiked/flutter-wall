import 'package:flutter/material.dart';

class StatelessWdigetWrapper extends StatelessWidget {
  final Widget widget;
  StatelessWdigetWrapper(this.widget);

  @override
  Widget build(BuildContext context) {
    print('stateless widget wrapper---------build');
    return StatefulWidgetWrapper(widget);
  }
}

class StatefulWidgetWrapper extends StatefulWidget {
  final Widget widget;
  StatefulWidgetWrapper(this.widget);
  @override
  State<StatefulWidget> createState() {
    return _StatefulWidgetWrapper();
  }
}

class _StatefulWidgetWrapper extends State<StatefulWidgetWrapper> {
  @override
  Widget build(BuildContext context) {
    print(
        'stateful widget wrapper---------build---------------------------------==========================================');

    return Container(child: widget.widget);
  }
}
