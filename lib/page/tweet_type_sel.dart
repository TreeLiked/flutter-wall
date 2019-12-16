import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/theme_utils.dart';

class TweetTypeSelect extends StatefulWidget {
  String title;

  String finishText;
  String backText;

  final callback;
  List<String> initNames;

  bool editState = false;
  bool needVisible;

  TweetTypeSelect(
      {this.title,
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

  List<String> typeKeysList =
      TweetTypeUtil.getPushableTweetTypeMap().keys.map((nameKey) => nameKey.toString()).toList();

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
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            NavigatorUtils.goBack(context);
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
              Navigator.pop(context);
              widget.callback(list);
            },
            icon: Text(widget.finishText, style: TextStyle(color: Theme.of(context).textTheme.title.color)),
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
        itemCount: typeKeysList.length,
        itemBuilder: (BuildContext context, int index) {
          bool sel = selects[typeKeysList[index]] != null && selects[typeKeysList[index]];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color: sel
                  ? (!ThemeUtils.isDark(context) ? Color(0xff87CEEB) : Theme.of(context).backgroundColor)
                  : Theme.of(context).appBarTheme.color,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: ListTile(
              leading: Icon(tweetTypeMap[typeKeysList[index]].iconData,
                  size: 35, color: tweetTypeMap[typeKeysList[index]].iconColor),
              title: Text(
                tweetTypeMap[typeKeysList[index]].zhTag,
                style: TextStyle(
                  color: sel ? Colors.white : Theme.of(context).textTheme.title.color,
                ),
              ),
              subtitle: Text(
                tweetTypeMap[typeKeysList[index]].intro,
                style: TextStyle(
                  fontSize: 13,
                  color: sel ? Colors.white : Theme.of(context).textTheme.subtitle.color,
                ),
              ),
              onTap: () {
                setState(() {
                  for (int i = 0; i < typeKeysList.length; i++) {
                    selects[typeKeysList[i]] = false;
                  }
                  selects[typeKeysList[index]] = true;
                });
              },
            ),
          );
        },
      ),
    );
  }
}
