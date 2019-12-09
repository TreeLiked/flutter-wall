import 'package:flutter/widgets.dart';
import 'package:iap_app/util/widget_util.dart';

export 'colors.dart';
export 'dimens.dart';
export 'gaps.dart';

class Images {
  static const Widget arrowRight = const LoadAssetImage(
    "ic_arrow_right",
    width: 16.0,
    height: 16.0,
  );

  static const Widget copy = const LoadAssetIcon(
    "/profile/copy",
    width: 17.0,
    height: 17.0,
  );
}
