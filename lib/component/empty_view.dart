import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/widget_util.dart';

class EmptyView extends StatelessWidget {
  final String text;

  const EmptyView({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Gaps.vGap50,
        SizedBox(
            height: ScreenUtil().setHeight(500),
            child: LoadAssetImage(
              ThemeUtils.isDark(context) ? 'no_data_dark' : 'no_data',
              fit: BoxFit.cover,
            )),
        Gaps.vGap16,
        Text('$text', style: pfStyle.copyWith(color: Colors.grey, fontSize: Dimens.font_sp14, letterSpacing: 1.2)),
      ],
    );
  }
}
