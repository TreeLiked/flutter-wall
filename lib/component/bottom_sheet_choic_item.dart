import 'package:flutter/widgets.dart';

class BSChoiceItem extends StatelessWidget {
  final String name;
  final String text;

  BSChoiceItem({Key key, this.name, this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Text(text),
    );
  }
}
