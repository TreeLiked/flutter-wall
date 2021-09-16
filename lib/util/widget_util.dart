import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/image_utils.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';

class WidgetUtil {
  static Widget getAsset(String path, {double size = 20, bool click = false, final callback}) {
    if (!click) {
      return Image.asset(
        path,
        width: size,
        height: size,
      );
    } else {
      return Container(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            child: GestureDetector(
                onTap: () => callback(),
                child: Image.asset(
                  path,
                  width: size,
                  height: size,
                )),
          ),
        ),
      );
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

  static Widget getLoadingAnimation({double size = 140}) {
    return Container(
      height: size,
      width: size,
      margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(30)),
      child: const CupertinoActivityIndicator(),
//      child: SpinKitFadingCircle(color: Colors.amber, size: 25),
    );
  }

  static Widget getLoadingGif({double size = 60}) {
    return Container(padding: EdgeInsets.all(20), child: Image.asset(PathConstant.LOADING_GIF));
  }

  static Widget getEmptyContainer({double height = 0}) {
    return Container(height: height);
  }

  static Widget getEmptyView(String lightIconPath, {String dartIconPath, String text}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Gaps.vGap50,
        SizedBox(
            height: ScreenUtil().setHeight(500),
            child: LoadAssetImage(
              ThemeUtils.isDark(Application.context) ? (dartIconPath ?? lightIconPath) : lightIconPath,
              fit: BoxFit.cover,
            )),
        StringUtil.isEmpty(text)
            ? Gaps.empty
            : Container(
                margin: const EdgeInsets.only(top: 16.0),
                child: Text('快去加入或创建一个圈子吧 ～',
                    style:
                        pfStyle.copyWith(color: Colors.grey, fontSize: Dimens.font_sp15, letterSpacing: 1.1)))
      ],
    );
  }
}

/// 加载本地资源图片
class LoadAssetImage extends StatelessWidget {
  const LoadAssetImage(this.image,
      {Key key, this.width, this.height, this.fit = BoxFit.cover, this.format: 'png', this.color})
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
      image.startsWith("assets") ? image : ImageUtils.getImgPath(image, format: format),
      height: height,
      width: width,
      fit: fit,
      color: color,
    );
  }
}

class LoadAssetIcon extends StatelessWidget {
  const LoadAssetIcon(this.image,
      {Key key, this.width, this.height, this.fit, this.format: 'png', this.color})
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
      ImageUtils.getIconPath(image, format: format),
      height: height,
      width: width,
      fit: fit,
      color: color,
    );
  }
}

class LoadAssetSvg extends StatelessWidget {
  const LoadAssetSvg(this.svgName,
      {Key key, this.width, this.height, this.fit = BoxFit.cover, this.format: 'svg', this.color})
      : super(key: key);

  final String svgName;
  final double width;
  final double height;
  final BoxFit fit;
  final String format;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/svgs/$svgName.$format",
      width: width,
      height: height,
      fit: fit,
      color: color,
      alignment: Alignment.bottomRight,
    );
    return Image.asset(
      ImageUtils.getIconPath(svgName, format: format),
      height: height,
      width: width,
      fit: fit,
      color: color,
    );
  }
}
