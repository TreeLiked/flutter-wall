import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:iap_app/part/hot_today.dart';
import 'package:iap_app/util/common_util.dart';

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
  final LinkHeaderNotifier headerNotifier;

  HotAppBarWidget({
    @required this.expandedHeight,
    @required this.content,
    @required this.title,
    @required this.backgroundImg,
    @required this.headerNotifier,
    this.sigma = 3,
    this.playOnTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      actions: <Widget>[
        CircleHeader(
          headerNotifier,
        ),
      ],
      centerTitle: true,
      expandedHeight: expandedHeight,
      pinned: true,
      elevation: 0,
      brightness: Brightness.dark,
      iconTheme: IconThemeData(color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      // bottom: MusicListHeader(
      //   onTap: playOnTap,
      //   count: count,
      // ),

      flexibleSpace: FlexibleDetailBar(
          content: content,
          background: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                child: Stack(
                  children: <Widget>[
                    backgroundImg.startsWith('http')
                        ? Utils.showNetImage(
                            backgroundImg,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
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
                        color: Colors.black38,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ],
                ),
              ))),
    );
  }
}
