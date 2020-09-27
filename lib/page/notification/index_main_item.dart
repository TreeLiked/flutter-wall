import 'dart:async';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/component/simgple_tag.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/image_utils.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/widget_util.dart';

class MainMessageItem extends StatefulWidget {
  final String iconPath;
  final String title;
  final String tagName;
  final String body;
  final Color color;
  final DateTime time;
  final Function onTap;
  final bool pointType;
  final StreamController<int> controller;

  MainMessageItem(
      {this.iconPath,
      this.color = Colours.app_main,
      this.title,
      this.tagName,
      this.body,
      this.time,
      this.controller,
      this.pointType = false,
      this.onTap});

  @override
  State<StatefulWidget> createState() {
    return _MainMessageItemState();
  }
}

class _MainMessageItemState extends State<MainMessageItem> {
  final double iconSize = 45.0;
  double lineHeight = 47.5;

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeUtils.isDark(context);
    return widget.controller == null
        ? _buildBody(isDark)
        : StreamBuilder(
            initialData: 0,
            stream: widget.controller.stream,
            builder: (_, snapshot) => InkWell(
                  onTap: widget.onTap,
                  child: Container(
                    padding: const EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
                    color: isDark ? Colours.dark_bg_color : Colors.white,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                            height: lineHeight,
                            width: lineHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular((50)),
                              color: widget.color,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(7.0),
                              child: LoadAssetSvg(
                                widget.iconPath,
                                color: Colors.white,
                                height: iconSize,
                                width: iconSize,
                              ),
                            )),
                        Gaps.hGap15,
                        Expanded(
                            child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  child: Text(widget.title,
                                      style: pfStyle.copyWith(
                                          fontSize: Dimens.font_sp16,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 1.2),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1),
                                ),
                                widget.tagName != null
                                    ? SimpleTag(
                                        widget.tagName,
                                        leftMargin: 5.0,
                                        radius: 20.0,
                                      )
                                    : Container(width: 0),
                                Expanded(
                                    child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                      '${widget.time == null ? '' : TimeUtil.getShortTime(widget.time)}',
                                      style: MyDefaultTextStyle.getTweetTimeStyle(context)),
                                ))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                    child: Text(widget.body ?? "暂无消息",
                                        style: pfStyle.copyWith(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 1.1,
                                            color: MyDefaultTextStyle.getTweetTimeStyle(context, fontSize: 14)
                                                .color),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1)),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Badge(
                                      elevation: 0,
                                      shape: BadgeShape.circle,
                                      showBadge: snapshot.data != -1 && snapshot.data != 0,
                                      padding: const EdgeInsets.all(5),
                                      badgeContent: widget.pointType
                                          ? const SizedBox(
                                              height: 0.1,
                                              width: 0.1,
                                            )
                                          : Text(
                                              '${snapshot.data}',
                                              style: pfStyle.copyWith(color: Colors.white),
                                            ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ))
                      ],
                    ),
                  ),
                ));
  }

  _buildBody(bool isDark) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
//        width: double.infinity,
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
        color: isDark ? Colours.dark_bg_color : Colors.white,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
                height: lineHeight,
                width: lineHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular((50.0)),
                  color: widget.color,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.5),
                  child: LoadAssetSvg(
                    widget.iconPath,
                    color: Colors.white,
                    height: iconSize,
                    width: iconSize,
                  ),
                )),
            Gaps.hGap15,
            Expanded(
                child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Text(widget.title,
                          style: const TextStyle(
                              fontSize: Dimens.font_sp16, fontWeight: FontWeight.w400, letterSpacing: 1.1),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                    ),
                    widget.tagName != null
                        ? SimpleTag(
                            widget.tagName,
                            leftMargin: 5.0,
                            radius: 20.0,
                          )
                        : Gaps.empty,
                    Expanded(
                        child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(widget.time ?? "", style: MyDefaultTextStyle.getTweetTimeStyle(context)),
                    ))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                        child: Text(widget.body,
                            style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                                color: MyDefaultTextStyle.getTweetTimeStyle(context, fontSize: 14).color),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1)),
                  ],
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
