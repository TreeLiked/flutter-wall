import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/base_dialog.dart';
import 'package:iap_app/common-widget/radio_item.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/resources.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/widget_util.dart';

class RadioSelectDialog extends StatefulWidget {
  final String title;
  final List<RadioItem> items;
  final String initRadioItemKey;
  RadioSelectDialog({
    Key key,
    @required this.title,
    @required this.initRadioItemKey,
    @required this.items,
    this.onPressed,
  }) : super(key: key);

  final Function(String, String) onPressed;

  @override
  _RadioSelectDialog createState() => _RadioSelectDialog();
}

class _RadioSelectDialog extends State<RadioSelectDialog> {
  String _selectKey;

  Widget getItem(RadioItem item) {
    _selectKey = _selectKey ?? widget.initRadioItemKey;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        child: SizedBox(
          height: 42.0,
          child: Row(
            children: <Widget>[
              Gaps.hGap16,
              Expanded(
                child: Text(
                  item.value,
                  style: item.key == _selectKey
                      ? TextStyle(
                          fontSize: Dimens.font_sp14,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                ),
              ),
              Offstage(
                  offstage: item.key != _selectKey,
                  child: const LoadAssetIcon("ic_check",
                      width: 16.0, height: 16.0)),
              Gaps.hGap16,
            ],
          ),
        ),
        onTap: () {
          if (mounted) {
            setState(() {
              _selectKey = item.key;
            });
          }
        },
      ),
    );
  }

  List<Widget> _buildList() {
    List<Widget> items = List();
    widget.items.forEach((f) => items.add(getItem(f)));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: widget.title,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: _buildList()),
      onPressed: () {
        NavigatorUtils.goBack(context);
        widget.onPressed(_selectKey,
            widget.items.where((f) => f.key == _selectKey).first.value);
      },
    );
  }
}
