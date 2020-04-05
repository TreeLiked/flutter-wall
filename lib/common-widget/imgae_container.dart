import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/util/widget_util.dart';

class ImageContainer extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final double maxWidth;
  final double maxHeight;
  final EdgeInsetsGeometry padding;
  final Widget errorWidget;
  final callback;

  const ImageContainer(
      {@required this.url,
      this.width,
      this.height,
      this.callback,
      this.padding,
      this.maxWidth,
      this.errorWidget,
      this.maxHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
        // %2 因为索引从0开始，3的倍数右边距设为0
        constraints: maxWidth != null || maxHeight != null
            ? BoxConstraints(maxHeight: maxHeight ?? double.infinity, maxWidth: maxWidth ?? double.infinity)
            : null,
        padding: padding,
        width: width,
        height: height,
        child: GestureDetector(
            onTap: callback,
            child: ClipRRect(
                child: CachedNetworkImage(
                    filterQuality: FilterQuality.medium,
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => CupertinoActivityIndicator(),
                    errorWidget: (context, url, error) =>
                        errorWidget ??
                        SizedBox(
                          width: Application.screenWidth * 0.25,
                          height: Application.screenWidth * 0.25,
                          child: LoadAssetImage(PathConstant.IMAGE_FAILED),
                        )),
                borderRadius: const BorderRadius.all(Radius.circular(5.0)))));
  }
}
