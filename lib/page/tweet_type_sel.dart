import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/util/collection.dart';

class TweetTypeSelect extends StatefulWidget {
  String title;

  String finishText;
  String backText;

  // 是否多选
  bool multi;
  final callback;
  List<String> initNames;

  bool editState = false;

  TweetTypeSelect(
      {this.title,
      this.multi = false,
      this.finishText,
      this.backText = "返回",
      this.callback,
      this.initNames})
      : super();

  @override
  State<StatefulWidget> createState() {
    return _TweetTypeSelectState();
  }
}

class _TweetTypeSelectState extends State<TweetTypeSelect> {
  List<String> selTypes = new List();

  List<String> typeKeysList = tweetTypeMap.keys.toList();

  Map<String, bool> selects = Map();

  @override
  void initState() {
    if (!CollectionUtil.isListEmpty(widget.initNames)) {
      for (int i = 0; i < widget.initNames.length; i++) {
        selects[widget.initNames[i]] = true;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          onPressed: () {
            if (!widget.multi) {
              Navigator.pop(context);
            } else {
              setState(() {
                widget.editState = !widget.editState;
              });
            }
          },
          icon: Text(widget.backText),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              List<String> list = new List();
              selects.forEach((k, v) {
                if (v) {
                  list.add(k);
                }
              });
              widget.callback(list);
              Navigator.pop(context);
            },
            icon: Padding(
              padding: EdgeInsets.only(right: 0),
              child: Text(widget.finishText),
            ),
          )
        ],
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(10),
        separatorBuilder: (BuildContext context, int index) {
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 0.5,
              width: MediaQuery.of(context).size.width / 1.3,
              child: Divider(),
            ),
          );
        },
        itemCount: tweetTypeMap.length,
        itemBuilder: (BuildContext context, int index) {
          bool sel = selects[typeKeysList[index]] != null &&
              selects[typeKeysList[index]];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              color: sel && !widget.multi ? Color(0xff87CEEB) : Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListTile(
              leading: Icon(tweetTypeMap[typeKeysList[index]].iconData,
                  size: 35, color: tweetTypeMap[typeKeysList[index]].iconColor),
              contentPadding: EdgeInsets.all(0),
              title: Text(
                tweetTypeMap[typeKeysList[index]].zhTag,
                style: TextStyle(
                  color: sel && !widget.multi ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                tweetTypeMap[typeKeysList[index]].intro,
                style: TextStyle(
                  fontSize: 13,
                  color: sel && !widget.multi ? Colors.white : Colors.black,
                ),
              ),
              trailing: sel && widget.multi
                  ? (widget.editState
                      ? getIcon(PathConstant.ICON_CHECKBOX_SEL)
                      : getIcon(PathConstant.ICON_TICK))
                  : (widget.editState
                      ? getIcon(PathConstant.ICON_CHECKBOX_UNSEL)
                      : null),
              onTap: () {
                if (widget.editState || !widget.multi) {
                  setState(() {
                    if (widget.multi) {
                      if (selects.containsKey(typeKeysList[index])) {
                        if (selects[typeKeysList[index]] == true) {
                          selects[typeKeysList[index]] = false;
                        } else {
                          selects[typeKeysList[index]] = true;
                        }
                      } else {
                        selects[typeKeysList[index]] = true;
                      }
                    } else {
                      for (int i = 0; i < typeKeysList.length; i++) {
                        selects[typeKeysList[i]] = false;
                      }
                      selects[typeKeysList[index]] = true;
                    }
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  static Image getIcon(String path) {
    return Image.asset(
      path,
      fit: BoxFit.scaleDown,
      width: ScreenUtil().setWidth(40),
    );
  }
}
