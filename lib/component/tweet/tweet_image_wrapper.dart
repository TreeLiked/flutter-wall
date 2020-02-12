import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/imgae_container.dart';
import 'package:iap_app/global/oss_canstant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/widget_util.dart';

import '../../application.dart';

class TweetImageWrapper extends StatelessWidget {
  double sw;
  double sh;
  final double _imgRightPadding = 1.5;

  final List<String> picUrls;

  TweetImageWrapper({this.picUrls}) {
    this.sw = Application.screenWidth;
    this.sh = Application.screenHeight;
  }

  @override
  Widget build(BuildContext context) {
    return CollectionUtil.isListEmpty(picUrls)
        ? Gaps.empty
        : Container(
            padding: const EdgeInsets.only(top: 10),
            child: Wrap(
                children: picUrls.length == 1
                    ? <Widget>[_imgContainerSingle(context)]
                    : _handleMultiPics(context)));
  }

  Widget _imgContainerSingle(BuildContext context) {
    String imageUrl = "${picUrls[0]}${OssConstant.THUMBNAIL_SUFFIX}";
    return GestureDetector(
        onTap: () => open(context, 0),
        child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: sw * 0.75, maxHeight: sh * 0.4),
            child: ClipRRect(
                child: CachedNetworkImage(
                    filterQuality: FilterQuality.high,
                    imageUrl: "$imageUrl",
                    placeholder: (context, url) => SizedBox(
                        width: Application.screenWidth * 0.25,
                        height: Application.screenWidth * 0.25,
                        child: LoadAssetImage(PathConstant.IAMGE_HOLDER)),
                    errorWidget: (context, url, error) => SizedBox(
                        width: Application.screenWidth * 0.25,
                        height: Application.screenWidth * 0.25,
                        child: LoadAssetImage(PathConstant.IAMGE_FAILED))),
                borderRadius: const BorderRadius.all(Radius.circular(5.0)))));
  }

  List<Widget> _handleMultiPics(BuildContext context) {
    List<String> picUrls2 = picUrls.map((f) => "$f${OssConstant.THUMBNAIL_SUFFIX}").toList();
    List<Widget> list = new List(picUrls2.length);
    for (int i = 0; i < picUrls2.length; i++) {
      list[i] = _imgContainer(picUrls2[i], i, picUrls2.length, context);
    }
    return list;
  }

  Widget _imgContainer(String url, int index, int totalSize, BuildContext context) {
    // 40 最外层container左右padding,
    double left = (sw - 20);
    double perW;
    double rp = 0.8;
    if (totalSize == 2 || totalSize == 4) {
      if (totalSize == 2) {
        perW = (left - _imgRightPadding - 1) / 2.2;
      } else {
        perW = (left - _imgRightPadding - 1) / 2.3;
      }
      if (index % 2 != 0) {
        rp = 0;
      }
    } else {
      perW = (left - _imgRightPadding * 2 - 1) / 3;
      if (index % 3 == 2) {
        rp = 0;
      }
    }
    return ImageContainer(
      url: url,
      width: perW,
      height: perW,
      padding: EdgeInsets.only(right: rp, bottom: 0.8),
      callback: () => open(context, index),
    );
  }

  void open(BuildContext context, final int index) {
    Utils.openPhotoView(context, picUrls, index);
  }
}
