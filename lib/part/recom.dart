import 'dart:math';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iap_app/component/tweet_card.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/path_constant.dart';
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
  List<BaseTweet> children;

  /*
   * 中转回调
   */
  void showReplyContainer(TweetReply tr, String destAccountNick,
      String destAccountId, sendCallback) {
    // print('键盘弹出啦。。。------------------------------------------');
    // _focusNode.requestFocus();
    widget.callback(tr, destAccountNick, destAccountId, sendCallback);
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
        if (children != null) {
          children.clear();
        }
        setState(() {
          this.children = tweets;
        });
      }
    } else {
      if (children != null) {
        children.clear();
      }
      setState(() {
        this.children = List();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('recom buildd');
    List<Widget> widgets = [];
    if (!CollectionUtil.isListEmpty(children)) {
      widgets = children
          .map((f) => TweetCard(
                f,
                callback: (TweetReply tr, String destAccountNick,
                        String destAccountId, callback) =>
                    showReplyContainer(
                        tr, destAccountNick, destAccountId, callback),
              ))
          .toList();
    }

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
            child: children == null
                ? (Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          height: 46,
                          width: 46,
                          margin:
                              EdgeInsets.only(top: ScreenUtil().setHeight(60)),
                          child: FlareActor(
                            PathConstant.FLARE_LOADING_ROUND,
                            fit: BoxFit.cover,
                            animation: 'anime',
                          ))
                    ],
                  ))
                : (children.length != 0
                    ? Column(
                        // children: children,
                        children: widgets)
                    : Container(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              color: Colors.transparent,
                              child: Image.network(
                                'https://tva1.sinaimg.cn/large/006y8mN6ly1g884iiahnjj30e80e8wf1.jpg',
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width * 0.25,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text(
                                '没有更多数据了',
                                style: TextStyle(
                                    color:
                                        ColorConstant.TWEET_REPLY_FONT_COLOR),
                              ),
                            )
                          ],
                        ),
                      ))),
      ),
    ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
