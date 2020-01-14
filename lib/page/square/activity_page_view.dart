import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/style/text_style.dart';

class ActivityPageView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ActivityPageView();
  }
}

class _ActivityPageView extends State<ActivityPageView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<ActivityPageView> {
  List<String> imageList = [
    "https://tva1.sinaimg.cn/large/006tNbRwgy1ga6e73jdtbj30u011i41q.jpg",
    "https://tva1.sinaimg.cn/large/006tNbRwgy1ga6e785n9mj30u011iad5.jpg",
    "https://tva1.sinaimg.cn/large/006tNbRwgy1ga6e7c9chjj30u011i41i.jpg",
    "https://tva1.sinaimg.cn/large/006tNbRwgy1ga6e7gl1wwj30u011iagt.jpg",
    "https://tva1.sinaimg.cn/large/006tNbRwgy1ga6e7kafy4j30u00u0acu.jpg"
  ];

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildBanner(),
            Gaps.vGap10,
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: const Text('最新活动', style: TextStyles.commonTextStyle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
//      padding: const EdgeInsets.fromLTRB(0, 50, 0, 5),
      width: Application.screenWidth,
      height: ScreenUtil().setHeight(315),
      child: Swiper(
        itemCount: imageList.length,
        itemBuilder: _swiperBuilder,
        duration: 310,
        pagination: SwiperPagination(
            alignment: Alignment.bottomRight,
            builder: DotSwiperPaginationBuilder(
                size: 6.0, activeSize: 6.5, activeColor: Colors.white, color: Colors.black38)),
        controller: SwiperController(),
        scrollDirection: Axis.horizontal,
        autoplay: true,
        onTap: (index) => print('点击了第$index'),
      ),
    );
  }

  Widget _swiperBuilder(BuildContext context, int index) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ClipRRect(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(10))),
          child: Container(
              child: Stack(
            children: <Widget>[
              CachedNetworkImage(
                width: double.infinity,
                imageUrl: imageList[index],
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.high,
              ),
//              BackdropFilter(
//                filter: ImageFilter.blur(
//                  sigmaY: 5,
//                  sigmaX: 5,
//                ),
//                child: Container(
//                  color: Colors.black26,
//                  width: double.infinity,
//                  height: double.infinity,
//                ),
//              ),
              Positioned(
                left: 0,
                top: 0,
                child: Text('hello'),
              )
            ],
          )),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
