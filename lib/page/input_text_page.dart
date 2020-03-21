import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/theme_utils.dart';

class InputTextPage extends StatefulWidget {
  InputTextPage({
    Key key,
    @required this.title,
    this.content,
    this.hintText,
    this.limit = 16,
    this.showLimit = true,
    this.keyboardType = 0,
  }) : super(key: key);

  final String title;
  final String content;
  final String hintText;
  final int limit;
  final bool showLimit;
  final int keyboardType;

  @override
  _InputTextPageState createState() => _InputTextPageState();
}

class _InputTextPageState extends State<InputTextPage> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          title: widget.title,
          actionName: "完成",
          onPressed: () {
            NavigatorUtils.goBackWithParams(context, _controller.text);
          },
        ),
        body: Container(
            margin: const EdgeInsets.only(top: 10.0, left: 5.0, right: 5.0),
            padding: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 10.0),
            decoration: BoxDecoration(
                color: ThemeUtils.isDark(context)
                    ? ColorConstant.DEFAULT_BAR_BACK_COLOR_DARK
                    : ColorConstant.DEFAULT_BAR_BACK_COLOR,
                borderRadius: BorderRadius.circular(8.0)),
            child: TextField(
                maxLength: widget.limit,
                maxLengthEnforced: widget.showLimit,
                maxLines: 5,
                autofocus: true,
                controller: _controller,
                keyboardType: widget.keyboardType == 0 ? TextInputType.text : TextInputType.phone,
                keyboardAppearance: Theme.of(context).brightness,

                //style: TextStyles.textDark14,

                style: TextStyle(height: 1.6, fontSize: Dimens.font_sp15, letterSpacing: 1.3),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  hintMaxLines: 3,
                  hintStyle: TextStyle(height: 1.6, fontSize: Dimens.font_sp15, letterSpacing: 1.3),
//                  hintStyle: MyDefaultTextStyle.getTweetBodyStyle(ThemeUtils.isDark(context)).copyWith(color:null),

                  //hintStyle: TextStyles.textGrayC14
                ))));
  }
}
