import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iap_app/component/tweet_card.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/image_utils.dart';
import 'package:iap_app/util/widget_util.dart';

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
    super.build(context);
    print('recom build');
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

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
          child: children == null
              ? (Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[WidgetUtil.getLoadingAnimiation()],
                ))
              : (widgets.length != 0
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
                            child: Image.asset(
                              ImageUtils.getImgPath("no_data", format: "png"),
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ),
                          // Container(
                          //   margin: EdgeInsets.only(top: 10),
                          //   child: Text(
                          //     '没有更多数据了',
                          //     style: TextStyle(
                          //         color: ColorConstant.TWEET_REPLY_FONT_COLOR),
                          //   ),
                          // )
                        ],
                      ),
                    ))),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
