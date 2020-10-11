import 'package:flutter/material.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/util/theme_utils.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    Key key,
    this.text: "",
    @required this.onPressed,
  }) : super(key: key);

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeUtils.isDark(context);
    return FlatButton(
      onPressed: onPressed,
      textColor: Colors.white,
      color: Colors.amber,
      disabledTextColor: isDark ? Colours.dark_text_disabled : Colours.text_disabled,
      disabledColor: isDark ? Colours.dark_button_disabled : Colours.button_disabled,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Column(
        children: <Widget>[
          Container(
            height: 48,
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(fontSize: Dimens.font_sp18),
            ),
          ),
        ],
      ),
    );
  }
}
