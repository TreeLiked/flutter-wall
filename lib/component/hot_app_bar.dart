import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/theme_utils.dart';

import 'circle_header.dart';
import 'flexible_detail_bar.dart';

class HotAppBarWidget extends StatelessWidget {
  final double expandedHeight;
  final Widget content;
  final String backgroundImg;
  final List<String> backgroundImgs;
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

  // 上一张图片路径用作placeholder
  final String preBackgroundImg;

  final bool cache;

  // 是否模糊图片
  final bool blurImage;

  // 是否显示返回的箭头
  final bool displayLeading;

  HotAppBarWidget(
      {@required this.expandedHeight,
      @required this.content,
      @required this.title,
      @required this.backgroundImg,
      @required this.headerNotifier,
      this.backgroundImgs,
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
      this.cache = false,
      this.blurImage = true,
      this.displayLeading = true,
      this.preBackgroundImg});

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeUtils.isDark(context);
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
        leading: displayLeading
            ? GestureDetector(
                child: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white70 : Colors.white60,
                ),
                onTap: () => NavigatorUtils.goBack(context),
              )
            : Gaps.empty,
        elevation: 0,
        // brightness: Brightness.dark,
        // iconTheme: backgroundImg == null ? null : IconThemeData(color: Colors.white),
        title: Text(
          '$title',
          style: pfStyle.copyWith(
              fontWeight: FontWeight.w500, letterSpacing: 1.1, color: isDark ? Colors.white70 : Colors.white),
        ),
        flexibleSpace: Container(
          // color: ThemeUtils.isDark(context) ? ColorConstant.MAIN_BG_DARK : ColorConstant.MAIN_BG,
          margin: outerMargin,
          child: ClipRRect(
            borderRadius: outerRadius,
            child: FlexibleDetailBar(
              content: content,
              background: Stack(
                children: <Widget>[
                  backgroundImg == null
                      ? Gaps.empty
                      : backgroundImg.startsWith('http')
                          ? (CollectionUtil.isListEmpty(backgroundImgs)
                              ? Utils.showFadeInImage(backgroundImg, imageRadius,
                                  cache: cache, preImgUrl: preBackgroundImg)
                              : Swiper(
                                  itemBuilder: (BuildContext context, int index) {
                                    return Utils.showFadeInImage(backgroundImgs[index], imageRadius,
                                        cache: cache);
                                  },
                                  autoplay: true,
                                  loop: false,
                                  layout: SwiperLayout.DEFAULT,
                                  duration: 250,
                                  autoplayDelay: 1500,
                                  scrollDirection: Axis.vertical,
                                  // pagination: new SwiperPagination(builder: SwiperPagination.fraction),
                                  itemCount: backgroundImgs.length))
                          : Image.asset(
                              backgroundImg,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                  blurImage && backgroundImg != null
                      ? BackdropFilter(
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
                        )
                      : Gaps.empty,
                ],
              ),
            ),
          ),
        ));
  }
}
