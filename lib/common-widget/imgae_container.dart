import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/util/widget_util.dart';

class ImageCoatainer extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final callback;

  ImageCoatainer(
      {@required this.url,
      this.width,
      this.height,
      this.callback,
      this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
        // %2 因为索引从0开始，3的倍数右边距设为0
        padding: padding,
        width: width,
        height: height,
        child: GestureDetector(
            onTap: callback,
            child: CachedNetworkImage(
                filterQuality: FilterQuality.medium,
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                    margin: EdgeInsets.all(Application.screenWidth * 0.1),
                    width: Application.screenWidth * 0.25,
                    height: Application.screenWidth * 0.25,
                    child: LoadAssetImage(
                      PathConstant.IAMGE_HOLDER,
                      width: 50,
                      height: 50,
                    )),
                errorWidget: (context, url, error) => SizedBox(
                      width: Application.screenWidth * 0.25,
                      height: Application.screenWidth * 0.25,
                      child: LoadAssetImage(PathConstant.IAMGE_FAILED),
                    ))));
  }
}
