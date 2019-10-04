import 'dart:io';

import 'package:flutter/widgets.dart';

abstract class BasePlatformWidget<A extends Widget, I extends Widget>
    extends StatelessWidget {
  A createAndroidWidget(BuildContext context);

  I createIosWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    /**如果是IOS平台，返回ios风格的控件
     * Android和其他平台都返回materil风格的控件
     */
    if (Platform.isIOS) {
      return createIosWidget(context);
    }
    return createAndroidWidget(context);
  }
}
