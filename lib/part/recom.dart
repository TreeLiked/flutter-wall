import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iap_app/component/tweet_card.dart';
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
    with AutomaticKeepAliveClientMixin<Recommendation> {
  List<BaseTweet> children;

  List<Widget> widgets;
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
          _buildWidgets();
        });
      } else {
        if (children != null) {
          children.clear();
        }
        setState(() {
          this.children = tweets;
          _buildWidgets();
        });
      }
    } else {
      if (children != null) {
        children.clear();
      }
      setState(() {
        this.children = List();
        _buildWidgets();
      });
    }
  }

  _buildWidgets() {
    List<Widget> temp = List();
    if (!CollectionUtil.isListEmpty(children)) {
      temp = children
          .map((f) => TweetCard(
                f,
                callback: (TweetReply tr, String destAccountNick,
                        String destAccountId, callback) =>
                    showReplyContainer(
                        tr, destAccountNick, destAccountId, callback),
              ))
          .toList();
      widgets = temp;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('recom build');

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
          child: widgets == null
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
                          Container(
                              margin: EdgeInsets.only(top: 10),
                              child: GestureDetector(
                                onTap: () {},
                                child: Text(
                                  '点击重新加载',
                                  style: TextStyle(color: Colors.blueAccent),
                                ),
                              ))
                        ],
                      ),
                    ))),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
