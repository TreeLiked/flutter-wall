import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/model/photo_wrap_item.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
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

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    super.initState();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;

    return Scaffold(
        body: GestureDetector(
      onLongPress: () {
        BottomSheetUtil.showBottmSheetView(context, [
          BottomSheetItem(
              Icon(
                Icons.file_download,
                color: Colors.lightBlue,
              ),
              '保存到本地', () async {
            var response = await Dio().get(
                widget.galleryItems[currentIndex].url,
                options: Options(responseType: ResponseType.bytes));
            ImagePickerSaver.saveFile(
                fileData: Uint8List.fromList(response.data));
            ToastUtil.showToast('已保存到手机相册');
            Navigator.pop(context);
          }),
          BottomSheetItem(
              Icon(
                Icons.warning,
                color: Colors.grey,
              ),
              '举报', () {
            ToastUtil.showToast('举报成功');
            Navigator.pop(context);
          }),
        ]);
      },
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
                  right: 20,
                  bottom: sw / 5,
                  child: Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            // width: 300,
                            // height: 100,
                            decoration: BoxDecoration(
                              color: GlobalConfig.DEFAULT_BAR_BACK_COLOR,
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            child: Text(
                                '${currentIndex + 1} / ${widget.galleryItems.length}',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ]),
                  )),
              // widget.usePageViewWrapper
              //     ? Container(
              //         child: Text("das;dasda"),
              //       )
              //     : Container(
              //         padding: const EdgeInsets.all(20.0),
              //         child: Text(
              //           "Image ${currentIndex + 1}",
              //           style: const TextStyle(
              //               color: Colors.white,
              //               fontSize: 17.0,
              //               decoration: null),
              //         ),
              //       )
            ],
          )),
    ));
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final PhotoWrapItem item = widget.galleryItems[index];
    return PhotoViewGalleryPageOptions(
      imageProvider: CachedNetworkImageProvider(item.url),
      initialScale: PhotoViewComputedScale.contained,
      // minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 1.1,
      heroAttributes: PhotoViewHeroAttributes(tag: index),
    );
  }
}
