import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iap_app/component/tweet/tweet_card.dart';
import 'package:iap_app/component/tweet/tweet_no_data_view.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Recommendation extends StatefulWidget {
  Recommendation({Key key, this.callback, this.callback2, this.refreshController}) : super(key: key);

  // 传递推文点击的回复
  final callback;

  // 收起键盘回调
  final callback2;

  final RefreshController refreshController;

  @override
  State<StatefulWidget> createState() {
    print('reco create state');
    return RecommendationState();
  }
}

class RecommendationState extends State<Recommendation> with AutomaticKeepAliveClientMixin<Recommendation> {
  List<BaseTweet> children;

  List<Widget> widgets;

  /*
   * 中转回调
   */
  void showReplyContainer(TweetReply tr, String destAccountNick, String destAccountId, sendCallback) {
    widget.callback(tr, destAccountNick, destAccountId, sendCallback);
  }

  RecommendationState() {
    print('reco state construct');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('recom build');

    return Consumer<TweetProvider>(builder: (context, provider, _) {
      var tweets = provider.displayTweets;
      if (tweets == null) {
        return Center(
          child: WidgetUtil.getLoadingAnimation(),
        );
      }
      if (tweets.length == 0) {
        return TweetNoDataView(onTapReload: () {
          if (widget.refreshController != null) {
            widget.refreshController.resetNoData();
            widget.refreshController.requestRefresh();
          }
        });
      }
      return ListView.builder(
          itemCount: tweets.length,
          itemBuilder: (context, index) {
            return TweetCard2(
              tweets[index],
              onClickComment:
                  (TweetReply tr, String destAccountNick, String destAccountId, callback) =>
                      showReplyContainer(tr, destAccountNick, destAccountId, callback),
            );
          });
    });
  }

  @override
  bool get wantKeepAlive => true;
}
