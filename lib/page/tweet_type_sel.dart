import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as prefix0;
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:provider/provider.dart';

class TweetTypeSelect extends StatefulWidget {
  String title;

  String finishText;
  String backText;

  // 是否多选
  bool multi;
  final callback;
  List<String> initNames;

  bool editState = false;
  bool needVisible;

  TweetTypeSelect(
      {this.title,
      this.multi = false,
      this.finishText,
      this.backText = "返回",
      this.callback,
      this.initNames,
      this.needVisible = true})
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

  TweetTypesFilterProvider filterProvider;

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
    filterProvider = Provider.of<TweetTypesFilterProvider>(context);
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
          icon: Text(
            widget.backText,
            style: TextStyle(color: Theme.of(context).textTheme.title.color),
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              List<String> list = new List();
              selects.forEach((k, v) {
                if (v != null && v == true) {
                  list.add(k);
                }
              });
              if (widget.multi) {
                await SpUtil.putStringList(
                    SharedConstant.LOCAL_FILTER_TYPES, list);
                filterProvider.updateTypeNames();
              }

              Navigator.pop(context);
              widget.callback(list);
            },
            icon: Text(widget.finishText,
                style:
                    TextStyle(color: Theme.of(context).textTheme.title.color)),
          )
        ],
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 5),
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
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color: sel && !widget.multi
                  ? (!ThemeUtils.isDark(context)
                      ? Color(0xff87CEEB)
                      : Theme.of(context).backgroundColor)
                  : Theme.of(context).appBarTheme.color,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ListTile(
              leading: Icon(tweetTypeMap[typeKeysList[index]].iconData,
                  size: 35, color: tweetTypeMap[typeKeysList[index]].iconColor),
              contentPadding: EdgeInsets.all(0),
              title: Text(
                tweetTypeMap[typeKeysList[index]].zhTag,
                style: TextStyle(
                  color: sel && !widget.multi
                      ? Colors.white
                      : Theme.of(context).textTheme.title.color,
                ),
              ),
              subtitle: Text(
                tweetTypeMap[typeKeysList[index]].intro,
                style: TextStyle(
                  fontSize: 13,
                  color: sel && !widget.multi
                      ? Colors.white
                      : Theme.of(context).textTheme.title.color,
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
      width: prefix0.ScreenUtil().setWidth(40),
    );
  }
}
