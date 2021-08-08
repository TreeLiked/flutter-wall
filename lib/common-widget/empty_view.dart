import 'package:flutter/material.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/image_utils.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';

class EmptyView extends StatelessWidget {
  String lightImg;
  String darkImg;
  String text;

  double topMargin;

  EmptyView({this.lightImg, this.darkImg, this.text, this.topMargin});

  @override
  Widget build(BuildContext context) {
    String lightPath = lightImg ?? "no_data";
    String darkPath = darkImg ?? "no_data_dark";
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: topMargin),
          color: Colors.transparent,
          child: Image.asset(
            ImageUtils.getImgPath(ThemeUtils.isDark(context) ? darkPath : lightPath, format: "png"),
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width * 0.4,
          ),
        ),
        Gaps.vGap10,
        StringUtil.isEmpty(text)
            ? Gaps.empty
            : Text('$text', style: pfStyle.copyWith(color: Colors.grey, fontSize: Dimens.font_sp13p5))

        // GestureDetector(
        //   onTap: () => onTapReload == null ? null : onTapReload(),
        //   child: Text(
        //     '点击重新加载',
        //     style: pfStyle.copyWith(color: Colors.blueAccent, fontSize: Dimens.font_sp16, letterSpacing: 1.2),
        //   ),
        // )
      ],
    );
  }
}
