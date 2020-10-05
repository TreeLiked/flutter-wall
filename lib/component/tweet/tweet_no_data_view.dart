import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/image_utils.dart';

class TweetNoDataView extends StatelessWidget {
  final Function onTapReload;

  const TweetNoDataView({this.onTapReload});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 15.0,top: ScreenUtil().setHeight(200)),
          color: Colors.transparent,
          child: Image.asset(
            ImageUtils.getImgPath("no_data", format: "png"),
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width * 0.3,
          ),
        ),
        Text('暂无数据', style: pfStyle.copyWith(letterSpacing: 1.1)),
        Gaps.vGap10,
        GestureDetector(
          onTap: () => onTapReload == null ? null : onTapReload(),
          child: Text(
            '点击重新加载',
            style: pfStyle.copyWith(color: Colors.blueAccent, letterSpacing: 1.1),
          ),
        )
      ],
    );
  }
}
