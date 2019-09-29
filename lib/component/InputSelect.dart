import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InputSelect extends StatelessWidget {
  const InputSelect(
      {@required this.index, @required this.parent, @required this.choice})
      : super();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ChoiceChip(
          label: Text(choice),
          //未选定的时候背景
          selectedColor: Color(0xff182740),
          //被禁用得时候背景
          disabledColor: Colors.grey[300],
          labelStyle: TextStyle(fontWeight: FontWeight.w200, fontSize: 15.0),
          labelPadding: EdgeInsets.only(left: 8.0, right: 8.0),
          materialTapTargetSize: MaterialTapTargetSize.padded,
          onSelected: (bool value) {
            parent.onSelectedChanged(index);
          },
          selected: parent.selected == index),
    );
  }

  final int index;
  final parent;
  final String choice;
}
