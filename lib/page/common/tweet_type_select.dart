import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:provider/provider.dart';

class TweetTypeSelectPage extends StatefulWidget {
  final String title;
  final String subTitle;
  final bool filter;
  final bool subScribe;

  final List<String> initFirst;

  final callback;

  TweetTypeSelectPage(
      {this.title, this.subTitle, this.filter, this.subScribe, this.initFirst, this.callback}) {
    if (filter && subScribe || !filter && !subScribe) {
      throw 'filter and subscribe cannot be the same boolean value';
    }
  }

  @override
  State<StatefulWidget> createState() {
    return _TweetTypeSelectPage();
  }
}

class _TweetTypeSelectPage extends State<TweetTypeSelectPage> {
  Widget delIcon = LoadAssetIcon('del', width: 23, height: 23);
  Widget addIcon = LoadAssetIcon('add_2', width: 21, height: 21);

  TweetTypesFilterProvider filterProvider;

  @override
  Widget build(BuildContext context) {
    // if (filterProvider == null) {
    //   filterProvider = Provider.of<TweetTypesFilterProvider>(context);
    // }

    // if (widget.filter) {
    //   firstEntites.addAll(filterProvider.selTypeNames);
    //   firstEntites.addAll(tweetTypeMap.values
    //       .where((test) => !test.filterable)
    //       .map((f) => f.name)
    //       .toList());
    // }
    return Scaffold(
        appBar: MyAppBar(
          centerTitle: widget.title,
          isBack: true,
          actionName: "完成",
          onPressed: () {
            NavigatorUtils.goBack(context);
            if (widget.callback != null) {
              widget.callback(widget.initFirst);
            }
          },
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Gaps.vGap15,
                _buildTitle(widget.subTitle),
                Gaps.vGap12,
                renderFirst(),
                Gaps.vGap12,
                _buildTitle('其他'),
                Gaps.vGap12,
                renderLeft()
                // renderBody()
                // Container(
                //     child: GridView(
                //   padding: EdgeInsets.symmetric(vertical: 0),
                //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                //     crossAxisCount: 3,
                //   ),
                //   children: tweetTypeMap.values
                //       .map((f) => Container(
                //             child: Text(f.zhTag),
                //           ))
                //       .toList(),
                // ))
              ],
            ),
          ),
        ));
  }

  Widget _buildTitle(String title) {
    return Container(child: Text(title, style: TextStyles.textBold16));
  }

  Widget renderFirst() {
    return GridView.builder(
        padding: EdgeInsets.symmetric(vertical: 10),
        shrinkWrap: true,
        itemCount: widget.initFirst.length,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 15,
          crossAxisSpacing: 10,
          childAspectRatio: 3,
        ),
        itemBuilder: (context, index) {
          TweetTypeEntity entity = tweetTypeMap[widget.initFirst[index]];
          return GestureDetector(
              onTap: () {
                if (entity.filterable) {
                  print("del ${entity.name}");
                  setState(() {
                    widget.initFirst.remove(entity.name);
                  });
                }
              },
              child: Container(
                  height: 10,
                  width: 10.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    // color: tweetTypeMap[tweetTypeMap.keys.toList()[index]]
                    //     .iconColor
                    //     .withAlpha(50),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    border: new Border.all(color: Color(0xffdcdcdc), width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        entity.iconData,
                        size: 14,
                        color: entity.iconColor,
                      ),
                      Gaps.hGap4,
                      Text(entity.zhTag, style: TextStyles.textSize14),
                      Gaps.hGap4,
                      entity.filterable ? delIcon : Container(height: 0)
                    ],
                  )));
        });
  }

  Widget renderLeft() {
    List<TweetTypeEntity> temp = TweetTypeUtil.getVisibleTweetTypeMap()
        .values
        .where((f) => (f.visible && !widget.initFirst.contains(f.name)))
        .toList();
    return GridView.builder(
        padding: EdgeInsets.symmetric(vertical: 10),
        shrinkWrap: true,
        itemCount: temp.length,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 15,
          crossAxisSpacing: 10,
          childAspectRatio: 3,
        ),
        itemBuilder: (context, index) {
          TweetTypeEntity entity = temp[index];
          return GestureDetector(
              onTap: () {
                if (entity.filterable) {
                  setState(() {
                    widget.initFirst.add(entity.name);
                  });
                }
              },
              child: Container(
                height: 10,
                width: 10.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  // color: tweetTypeMap[tweetTypeMap.keys.toList()[index]]
                  //     .iconColor
                  //     .withAlpha(50),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  border: new Border.all(color: Color(0xffdcdcdc), width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      entity.iconData,
                      size: 14,
                      color: entity.iconColor,
                    ),
                    Gaps.hGap4,
                    Text(entity.zhTag, style: TextStyles.textSize14),
                    Gaps.hGap4,
                    entity.filterable ? addIcon : Container(height: 0)
                  ],
                ),
              ));
        });
  }
}
