import 'dart:async';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/component/simgple_tag.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/widget_util.dart';

class MainMessageItemNew extends StatefulWidget {
  final String iconPath;
  final String title;
  final String tagName;
  final String body;
  final Color color;
  final Color iconColor;
  final Color badgeBgColor;
  final DateTime time;
  final Function onTap;
  final bool pointType;
  final bool official;
  final double iconSize;
  final double iconPadding;
  final int msgCnt;

  MainMessageItemNew(
      {this.iconPath,
      this.color = Colours.app_main,
      this.iconColor,
      this.badgeBgColor = Colors.red,
      this.title,
      this.tagName,
      this.body,
      this.time,
      this.msgCnt = 0,
      this.pointType = false,
      this.official = false,
      this.iconSize = 45,
      this.iconPadding = 7.5,
      this.onTap});

  @override
  State<StatefulWidget> createState() {
    return _MainMessageItemNewState();
  }
}

class _MainMessageItemNewState extends State<MainMessageItemNew> {
  double lineHeight = 50;

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeUtils.isDark(context);
    return Material(
      color: isDark ? Colours.dark_bottom_sheet : Colors.white,
      child: Ink(
          child: InkWell(
              splashColor: widget.color,
              onTap: widget.onTap,
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 11.0),
                  child: Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                    Stack(children: [
                      Container(
                          height: lineHeight,
                          width: lineHeight,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: isDark ? null : widget.color,
                              border: Border.all(color: Colors.white12, width: isDark ? 1 : 0)),
                          child: Padding(
                            padding: EdgeInsets.all(widget.iconPadding),
                            child: LoadAssetSvg(
                              widget.iconPath,
                              color: widget.iconColor,
                              // color: isDark ? widget.color : Colors.black,
                              height: widget.iconSize,
                              width: widget.iconSize,
                            ),
                          )),
                      widget.official
                          ? Positioned(
                              right: 0,
                              bottom: 0,
                              child: Icon(Icons.double_arrow, size: 15, color: widget.iconColor),
                            )
                          : Gaps.empty
                    ]),
                    Gaps.hGap15,
                    Expanded(
                        child: Row(
                      children: [
                        Expanded(
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    child: Text(widget.title,
                                        style: pfStyle.copyWith(
                                            fontSize: Dimens.font_sp16, fontWeight: FontWeight.w400),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1),
                                  ),
                                  SimpleTag(
                                    widget.tagName,
                                    leftMargin: 5.0,
                                    radius: 5.0,
                                    // bgColor: Colors.black,
                                    // textColor: Colors.amberAccent,
                                    verticalPadding: 2,
                                  ),
                                  Expanded(
                                      child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        '${widget.time == null ? '' : TimeUtil.getShortTime(widget.time)}',
                                        style: MyDefaultTextStyle.getTweetTimeStyle(context)),
                                  ))
                                ],
                              ),
                              Gaps.vGap5,
                              Text(widget.body ?? "暂无消息",
                                  style: pfStyle.copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color:
                                          MyDefaultTextStyle.getTweetTimeStyle(context, fontSize: 14).color),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1),
                            ])),
                        Column(
                          children: [
                            Badge(
                                elevation: 0,
                                shape: BadgeShape.circle,
                                showBadge: widget.msgCnt > 0,
                                badgeColor: widget.badgeBgColor,
                                animationType: BadgeAnimationType.fade,
                                badgeContent: widget.pointType
                                    ? const SizedBox(
                                        height: 0.1,
                                        width: 0.1,
                                      )
                                    : Utils.getRpWidget(widget.msgCnt))
                          ],
                        )
                      ],
                    ))
                  ])))),
    );
    return InkWell(
        onTap: widget.onTap,
        child: Container(
            padding: const EdgeInsets.all(10.0),
            color: isDark ? Colours.dark_bottom_sheet : Colors.white,
            child: Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
              Stack(children: [
                Container(
                    height: lineHeight,
                    width: lineHeight,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isDark ? null : widget.color,
                        border: Border.all(color: Colors.white12, width: isDark ? 1 : 0)),
                    child: Padding(
                      padding: EdgeInsets.all(widget.iconPadding),
                      child: LoadAssetSvg(
                        widget.iconPath,
                        color: widget.iconColor,
                        // color: isDark ? widget.color : Colors.black,
                        height: widget.iconSize,
                        width: widget.iconSize,
                      ),
                    )),
                widget.official
                    ? Positioned(
                        right: 0,
                        bottom: 0,
                        child: Icon(Icons.double_arrow, size: 15, color: widget.iconColor),
                      )
                    : Gaps.empty
              ]),
              Gaps.hGap15,
              Expanded(
                  child: Row(
                children: [
                  Expanded(
                      child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              child: Text(widget.title,
                                  style: pfStyle.copyWith(
                                      fontSize: Dimens.font_sp16, fontWeight: FontWeight.w400),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1),
                            ),
                            SimpleTag(
                              widget.tagName,
                              leftMargin: 5.0,
                              radius: 5.0,
                              // bgColor: Colors.black,
                              // textColor: Colors.amberAccent,
                              verticalPadding: 2,
                            ),
                            Expanded(
                                child: Container(
                              alignment: Alignment.centerRight,
                              child: Text('${widget.time == null ? '' : TimeUtil.getShortTime(widget.time)}',
                                  style: MyDefaultTextStyle.getTweetTimeStyle(context)),
                            ))
                          ],
                        ),
                        Gaps.vGap5,
                        Text(widget.body ?? "暂无消息",
                            style: pfStyle.copyWith(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                                color: MyDefaultTextStyle.getTweetTimeStyle(context, fontSize: 14).color),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1),
                      ])),
                  Column(
                    children: [
                      Badge(
                          elevation: 0,
                          shape: BadgeShape.circle,
                          showBadge: widget.msgCnt > 0,
                          badgeColor: widget.badgeBgColor,
                          animationType: BadgeAnimationType.fade,
                          badgeContent: widget.pointType
                              ? const SizedBox(
                                  height: 0.1,
                                  width: 0.1,
                                )
                              : Utils.getRpWidget(widget.msgCnt))
                    ],
                  )
                ],
              ))
            ])));
  }
}
