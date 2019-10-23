import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iap_app/component/tweet_card.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/util/collection.dart';

class Recommendation extends StatefulWidget {
  Recommendation({Key key, this.callback, this.callback2}) : super(key: key);

  // 传递推文点击的回复
  final callback;
  // 收起键盘回调
  final callback2;

  @override
  State<StatefulWidget> createState() {
    print('reco create state');
    return RecommendationState();
  }
}

class RecommendationState extends State<Recommendation>
    with AutomaticKeepAliveClientMixin {
  List<BaseTweet> children = [];

  static String _hintText = "评论";

  void showReplyContainer(
      TweetReply tr, String destAccountNick, String destAccountId) {
    // print('键盘弹出啦。。。------------------------------------------');
    // _focusNode.requestFocus();
    widget.callback(tr, destAccountNick, destAccountId);
  }

  RecommendationState() {
    print('reco state construct');
  }
  @override
  void initState() {
    super.initState();
  }

  void updateTweetList(List<BaseTweet> tweets,
      {bool add = false, bool start = false}) {
    if (!CollectionUtil.isListEmpty(tweets)) {
      if (add) {
        setState(() {
          if (start) {
            children.insertAll(0, tweets);
          } else {
            children.addAll(tweets);
          }
        });
      } else {
        children.clear();
        setState(() {
          this.children = tweets;
        });
      }
    } else {
      children.clear();
      setState(() {
        this.children = List();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('recom buildd');
    List<Widget> widgets = children
        .map((f) => TweetCard(
              f,
              callback: (TweetReply tr, String destAccountNick,
                      String destAccountId) =>
                  showReplyContainer(tr, destAccountNick, destAccountId),
            ))
        .toList();

    return Scrollbar(
        child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (_) {
        // setState(() {
        //   if (!CollectionUtil.isListEmpty(widgets)) {
        //     widgets.forEach((f) => FocusScope.of(context).unfocus());
        //   }
        // });
        widget.callback2();
        // FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
            // color: Color(0xfff7f7f7),
            // padding: EdgeInsets.only(top: 5),
            child: !CollectionUtil.isListEmpty(children)
                ? Column(
                    // children: children,
                    children: widgets)
                : Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          color: Colors.transparent,
                          child: Image.network(
                            'https://iutr-image.oss-cn-hangzhou.aliyuncs.com/almond-donuts/default/no_data.png',
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.3,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            '没有更多数据了',
                            style: TextStyle(
                                color: ColorConstant.TWEET_REPLY_FONT_COLOR),
                          ),
                        )
                      ],
                    ),
                  )),
      ),
    ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
