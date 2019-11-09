import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_bar.dart';

class WidgetNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          centerTitle: "页面不存在",
        ),
        body: SingleChildScrollView(
          child: Container(
              margin: EdgeInsets.only(top: ScreenUtil().setHeight(200)),
              child: Text('页面走丢了')),
        ));
  }
}
