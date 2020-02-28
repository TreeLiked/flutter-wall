import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/message.dart';
import 'package:iap_app/component/tweet/tweet_card.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/util/image_utils.dart';
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
      return Stack(
        children: <Widget>[
          Container(
              child: provider.displayTweets == null
                  ? (Center(
                      child: WidgetUtil.getLoadingAnimation(),
                    ))
                  : (provider.displayTweets.length != 0
                      ? Column(
                          // children: children,
                          children: provider.displayTweets
                              .map((f) => TweetCard2(
                                    f,
                                    displayReplyContainerCallback: (TweetReply tr, String destAccountNick,
                                            String destAccountId, callback) =>
                                        showReplyContainer(tr, destAccountNick, destAccountId, callback),
                                  ))
                              .toList())
                      : Center(
                          child: Container(
                          padding: EdgeInsets.only(top: ScreenUtil().setHeight(200)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
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
                              Gaps.vGap15,
                              Text('暂无数据', style: TextStyle(letterSpacing: 2)),
                              Gaps.vGap10,
                              GestureDetector(
                                onTap: () {
                                  if (widget.refreshController != null) {
                                    widget.refreshController.resetNoData();
                                    widget.refreshController.requestRefresh();
                                  }
                                },
                                child: Text(
                                  '点击重新加载',
                                  style: TextStyle(color: Colors.blueAccent),
                                ),
                              )
                            ],
                          ),
                        )))),
        ],
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
