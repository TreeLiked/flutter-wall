import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/part/hot_today.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/theme_utils.dart';

import 'circle_header.dart';
import 'flexible_detail_bar.dart';

class HotAppBarWidget extends StatelessWidget {
  final double expandedHeight;
  final Widget content;
  final String backgroundImg;
  final String title;
  final double sigma;
  final VoidCallback playOnTap;
  final int count;
  final bool pinned;
  final bool floating;
  final bool snap;
  final LinkHeaderNotifier headerNotifier;

  final BorderRadius outerRadius;
  final EdgeInsetsGeometry outerMargin;
  final BorderRadius imageRadius;
  final Color lightShadow;

  HotAppBarWidget({
    @required this.expandedHeight,
    @required this.content,
    @required this.title,
    @required this.backgroundImg,
    @required this.headerNotifier,
    this.sigma = 2.8,
    this.playOnTap,
    this.count,
    this.outerRadius,
    this.outerMargin,
    this.imageRadius,
    this.lightShadow = Colors.black12,
    this.pinned = false,
    this.floating = false,
    this.snap = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
        actions: headerNotifier != null
            ? <Widget>[
                CircleHeader(
                  headerNotifier,
                ),
              ]
            : [],
        centerTitle: true,
        expandedHeight: expandedHeight,
        pinned: pinned,
        snap: snap,
        floating: floating,
        elevation: 0,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          title ?? "",
          style: pfStyle.copyWith(color: ColorConstant.MAIN_BG, fontWeight: FontWeight.w500),
        ),
        flexibleSpace: Container(
          color: ThemeUtils.isDark(context) ? ColorConstant.MAIN_BG_DARK : ColorConstant.MAIN_BG,
          margin: outerMargin,
          child: ClipRRect(
            borderRadius: outerRadius,
            child: FlexibleDetailBar(
              content: content,
              background: Stack(
                children: <Widget>[
                  backgroundImg.startsWith('http')
                      ? Utils.showFadeInImage(backgroundImg, imageRadius)
                      : Image.asset(
                          backgroundImg,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaY: sigma,
                      sigmaX: sigma,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: ThemeUtils.isDark(context) ? Colors.black54 : lightShadow,
//                  borderRadius: BorderRadius.all(Radius.circular(85.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
