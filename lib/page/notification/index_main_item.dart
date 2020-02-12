import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/image_utils.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/widget_util.dart';

class MainMessageItem extends StatefulWidget {
  final String iconPath;
  final String title;
  final String tagName;
  final String body;
  final Color color;
  final String time;
  final int count;
  final Function onTap;

  MainMessageItem(
      {this.iconPath,
      this.color = Colours.app_main,
      this.title,
      this.tagName,
      this.body,
      this.time,
      this.count = 0,
      this.onTap});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MainMessageItemState();
  }
}

class _MainMessageItemState extends State<MainMessageItem> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    bool isDark = ThemeUtils.isDark(context);
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
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular((50)),
                  color: widget.color,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: LoadAssetIcon(widget.iconPath),
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
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                    ),
                    widget.tagName != null
                        ? Container(
                            margin: const EdgeInsets.only(left: 5),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                                color: isDark ? Colours.dark_bg_color_darker : Color(0xfff1f0f1),
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20), bottom: Radius.circular(20))),
                            child: Text(
                              widget.tagName ?? "",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.grey),
                            ))
                        : Container(width: 0),
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
                    SizedBox(
                      width: widget.count > 0 ? 40 : 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Badge(
                            elevation: 0,
                            shape: BadgeShape.circle,
                            padding: const EdgeInsets.all(7),
                            badgeContent: Text(
                              '${widget.count}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
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
