import 'package:flutter/material.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:iap_app/res/gaps.dart';

class RedPoint extends StatefulWidget {
  final AbstractMessage message;

  final Color color;

  RedPoint(this.message, {this.color = Colors.red});

//  final RedPoint

  @override
  State<StatefulWidget> createState() {
    return _RedPoint();
  }
}

class _RedPoint extends State<RedPoint> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (widget.message != null) {
            widget.message.readStatus = ReadStatus.READ;
          }
        });
      },
      child: widget.message.readStatus == ReadStatus.UNREAD
          ? Container(
              margin: const EdgeInsets.only(right: 4.0),
              height: 8.0,
              width: 8.0,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(4.0),
              ),
            )
          : Gaps.empty,
    );
  }
}
