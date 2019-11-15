import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/util/image_utils.dart';

class WidgetUtil {
  static Widget getAsset(String path,
      {double size = 20, bool click = false, final callback}) {
    if (!click) {
      return Image.asset(
        path,
        width: size,
        height: size,
      );
    } else {
      return GestureDetector(
          onTap: () => callback(),
          child: Image.asset(
            path,
            width: size,
            height: size,
          ));
    }
  }

  static Widget getIcon(IconData iconData, Color color,
      {double size = 20, bool click = false, final callback}) {
    if (!click) {
      return Icon(
        iconData,
        color: color,
        size: size,
      );
    } else {
      return GestureDetector(
          onTap: () => callback(),
          child: Icon(
            iconData,
            color: color,
            size: size,
          ));
    }
  }

  static Widget getLoadingAnimiation({double size = 140}) {
    return Container(
        height: size,
        width: size,
        margin: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
        child: FlareActor(
          PathConstant.FLARE_LOADING_ROUND,
          fit: BoxFit.cover,
          animation: 'idle',
        ));
  }

  static Widget getLoadingGif({double size = 60}) {
    return Container(
        padding: EdgeInsets.all(20),
        child: Image.asset(PathConstant.LOADING_GIF));
  }

  static Widget getEmptyContainer({double height = 0}) {
    return Container(height: height);
  }
}

/// 加载本地资源图片
class LoadAssetImage extends StatelessWidget {
  const LoadAssetImage(this.image,
      {Key key,
      this.width,
      this.height,
      this.fit,
      this.format: 'png',
      this.color})
      : super(key: key);

  final String image;
  final double width;
  final double height;
  final BoxFit fit;
  final String format;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      ImageUtils.getImgPath(image, format: format),
      height: height,
      width: width,
      fit: fit,
      color: color,
    );
  }
}
