import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/global/oss_canstant.dart';
import 'package:iap_app/model/photo_wrap_item.dart';
import 'package:iap_app/page/common/report_page.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/PermissionUtil.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class CirclePhotoViewWrapper extends StatefulWidget {
  CirclePhotoViewWrapper(
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
    return _CirclePhotoViewWrapperState();
  }
}

class _CirclePhotoViewWrapperState extends State<CirclePhotoViewWrapper> {
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
                // loadingBuilder: LoadB,
                loadingBuilder: (context, _) => widget.loadingChild,
                // loadingChild: widget.loadingChild,
                backgroundDecoration: widget.backgroundDecoration,
                pageController: widget.pageController,
                onPageChanged: onPageChanged,
                enableRotation: false,
              ),
              Positioned(
                  // left: sw / 2,
                  top: ScreenUtil.statusBarHeight + ScreenUtil().setHeight(20),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                      Text(
                        "${currentIndex + 1}",
                        style: pfStyle.copyWith(
                            color: Colors.lightGreen,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            fontSize: 25),
                      ),
                      Text("  /  ", style: const TextStyle(color: Colors.white70, fontSize: 20)),
                      Text("${widget.galleryItems.length}",
                          style: pfStyle.copyWith(color: Colors.white70, fontSize: 16)),
                    ]),
                  )),
              Positioned(
                  bottom: 100,
                  left: 30,
                  child: GestureDetector(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        color: Colors.white12,
                        width: 35,
                        height: 35,
                        alignment: Alignment.center,
                        child: Icon(Icons.arrow_back, color: Colors.lightGreen, size: 20),
                      ),
                    ),
                    onTap: () => NavigatorUtils.goBack(context),
                  )),
              Positioned(
                  right: 30,
                  bottom: 100,
                  child: GestureDetector(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        color: Colors.white12,
                        width: 35,
                        height: 35,
                        alignment: Alignment.center,
                        child: Icon(Icons.menu, color: Colors.lightGreen, size: 20),
                      ),
                    ),
                    onTap: () => displayOptions(),
                  ))
            ],
          )),
    ));
  }

  List<Widget> _renderDots(int currentIndex) {
    int len = widget.galleryItems.length;
    if (len < 2) {
      return [];
    }
    List<Widget> dots = List();
    for (int i = 0; i < len; i++) {
      dots.add(
          _genDot(margin: 3.0, size: 8.0, realColor: currentIndex == i ? Colors.amber : Color(0xffCDCDCD)));
    }
    return dots;
  }

  Widget _genDot(
      {Color realColor = Colors.transparent,
      Color borderColor = Colors.transparent,
      double size = 5.0,
      double margin = 1.0}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: realColor, shape: BoxShape.circle, border: Border.all(color: borderColor, width: 0.5)),
      margin: EdgeInsets.all(margin),
    );
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
          Utils.showDefaultLoadingWithBounds(context, text: "正在保存");
          bool saveResult = false;
          try {
            bool hasPermission = await PermissionUtil.checkAndRequestStorage(context);
            if (hasPermission) {
              saveResult = await Utils.downloadAndSaveImageFromUrl(widget.galleryItems[currentIndex].url);
            }
          } catch (e, stack) {
            saveResult = false;
          } finally {
            Navigator.pop(context);
            if (saveResult) {
              ToastUtil.showToast(context, '已保存到手机相册');
            } else {
              ToastUtil.showToast(context, '保存失败');
            }
          }
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
