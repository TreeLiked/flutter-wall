import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class UpDownItem extends StatelessWidget {
  final Widget upWidget;
  final Widget downWidget;
  final callback;

  UpDownItem(this.upWidget, this.downWidget, this.callback);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => callback(),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              upWidget,
              Container(
                margin: EdgeInsets.only(top: 5),
                child: downWidget,
              )
            ],
          ),
        ));
  }
}
