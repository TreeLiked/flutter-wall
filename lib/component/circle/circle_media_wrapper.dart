import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/imgae_container.dart';
import 'package:iap_app/global/oss_canstant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/model/media.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/widget_util.dart';

import '../../application.dart';

class CircleMediaWrapper extends StatelessWidget {
  double _sw;
  double _sh;

  final int circleId;

  final double _imgRightPadding = 2.0;

  final List<Media> medias;
  List<String> picUrls;

  CircleMediaWrapper(this.circleId, {this.medias}) {
    this._sw = (Application.screenWidth - 30.0) / 6 * 5;
    this._sh = Application.screenHeight;
    if (medias != null) {
      List<Media> temp = List.from(medias)..retainWhere((media) => media.mediaType == Media.TYPE_IMAGE);
      picUrls = temp.map((f) => f.url).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (medias == null || medias.length == 0) {
      return Gaps.empty;
    } else {
//      if (tweet != null) {
//        if (tweet.mediaWrapper != null) {
//          print("cache image");
//          return tweet.mediaWrapper;
//        } else {
//          tweet.mediaWrapper = Container(
//              padding: const EdgeInsets.only(top: 10),
//              child: Wrap(
//                  children: picUrls.length == 1
//                      ? <Widget>[_imgContainerSingle(context)]
//                      : _handleMultiPics(context)));
//          return tweet.mediaWrapper;
//        }
//      } else {
      return Container(
          padding: const EdgeInsets.only(bottom: 3.0),
          child: Wrap(
              children:
                  picUrls.length == 1 ? <Widget>[_imgContainerSingle(context)] : _handleMultiPics(context)));
    }
//    }
  }

  Widget _imgContainerSingle(BuildContext context) {
//    if (medias[0].mediaType != Media.TYPE_IMAGE) {
//      // TODO
//      return _handleVideo();
//    }
    String imageUrl = "${picUrls[0]}${OssConstant.THUMBNAIL_SUFFIX}";
    return GestureDetector(
        onTap: () => open(context, 0),
        child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _sw * 0.6, maxHeight: _sh * 0.3),
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
                        child: LoadAssetImage(PathConstant.IMAGE_FAILED))),
                borderRadius: const BorderRadius.all(Radius.circular(5.0)))));
  }

  Widget _handleVideo() {
    return Gaps.empty;
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
    double left = (_sw);
    double perW;
    if (totalSize == 2 || totalSize == 4) {
      if (totalSize == 2) {
        perW = (left - _imgRightPadding * totalSize) / 2.2;
      } else {
        perW = (left - _imgRightPadding * totalSize) / 2.2;
      }
    } else {
      perW = (left - _imgRightPadding * 2 - 1) / 3;
    }
    return ImageContainer(
      url: url,
      width: perW,
      height: perW,
      padding: EdgeInsets.only(right: _imgRightPadding, bottom: 2.0),
      callback: () => open(context, index),
    );
  }

  void open(BuildContext context, final int index) {
    Utils.openPhotoViewForCircle(context, picUrls, index, circleId);
  }
}
