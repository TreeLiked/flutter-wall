import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/global/oss_canstant.dart';
import 'package:iap_app/model/photo_wrap_item.dart';
import 'package:iap_app/page/common/report_page.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper(
      {this.loadingChild,
      this.usePageViewWrapper = false,
      this.backgroundDecoration,
      this.minScale,
      this.maxScale,
      this.initialIndex,
      this.fromNetwork = true,
      this.refId,
      @required this.galleryItems})
      : pageController = PageController(initialPage: initialIndex);

  final Widget loadingChild;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<PhotoWrapItem> galleryItems;
  final bool usePageViewWrapper;

  final bool fromNetwork;
  final String refId;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      onLongPress: () => displayOptions(),
      child: Container(
          decoration: widget.backgroundDecoration,
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
          ),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: _buildItem,
                itemCount: widget.galleryItems.length,
                loadingChild: widget.loadingChild,
                backgroundDecoration: widget.backgroundDecoration,
                pageController: widget.pageController,
                onPageChanged: onPageChanged,
                enableRotation: false,

                // usePageViewWrapper: false,
              ),
              Positioned(
                  // left: sw / 2,
                  top: ScreenUtil.statusBarHeight + ScreenUtil().setHeight(0),
                  left: 10,
                  child: Container(
                    width: Application.screenWidth - 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
//                      color: Colors.white10,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: Row(children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: Container(),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.center,
//                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          child: Text(
                              widget.galleryItems.length != 1
                                  ? '${currentIndex + 1} / ${widget.galleryItems.length}'
                                  : '',
                              style: TextStyle(color: Colors.white70, fontSize: 16)),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                                child: Icon(
                                  Icons.more_horiz,
                                  color: Colors.grey,
                                ),
                                onTap: () => displayOptions())),
                      ),
                    ]),
                  )),
            ],
          )),
    ));
  }

  void displayOptions() {
    if (widget.fromNetwork) {
      BottomSheetUtil.showBottomSheetView(context, [
        BottomSheetItem(
            Icon(
              Icons.file_download,
              color: Colors.lightBlue,
            ),
            '保存到本地', () async {
          var response = await Dio()
              .get(widget.galleryItems[currentIndex].url, options: Options(responseType: ResponseType.bytes));
          ImagePickerSaver.saveFile(fileData: Uint8List.fromList(response.data));
          Navigator.pop(context);
//              Utils.vibrateOnceOrNotSupport();
          ToastUtil.showToast(context, '已保存到手机相册');
        }),
        BottomSheetItem(
            Icon(
              Icons.warning,
              color: Colors.grey,
            ),
            '举报', () {
          Navigator.pop(context);
          NavigatorUtils.goReportPage(
              context, ReportPage.REPORT_TWEET_IMAGE, widget.galleryItems[currentIndex].url, "图片举报");
        }),
      ]);
    } else {
      BottomSheetUtil.showBottomSheetView(context, [
        BottomSheetItem(
            Icon(
              Icons.delete,
              color: Colors.lightBlue,
            ),
            '删除', () async {
          setState(() {
            widget.galleryItems.removeAt(currentIndex);
          });
        }),
        BottomSheetItem(
            Icon(
              Icons.warning,
              color: Colors.grey,
            ),
            '举报', () {
          Navigator.pop(context);
          ToastUtil.showToast(context, '举报成功');
        }),
      ]);
    }
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final PhotoWrapItem item = widget.galleryItems[index];
    return PhotoViewGalleryPageOptions(
      imageProvider: widget.fromNetwork
          ? CachedNetworkImageProvider(
              item.url + OssConstant.PREVIEW_SUFFIX,
            )
          : Image.file(new File(item.url), fit: BoxFit.cover),
      initialScale: PhotoViewComputedScale.contained,
      // minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 1.1,
      heroAttributes: PhotoViewHeroAttributes(tag: index),
    );
  }
}
