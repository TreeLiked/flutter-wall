import 'package:flutter/material.dart';
import 'package:iap_app/style/text_style.dart';

class ClickableText extends StatefulWidget {
  final String text;
  final GestureTapCallback onTap;

  const ClickableText(this.text, this.onTap, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ClickableText();
  }
}

class _ClickableText extends State<ClickableText> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Text(widget.text ?? "", style: pfStyle.copyWith(color: Colors.blueAccent)),
    );
  }
}
