import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/bezier_bounce_footer.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/common-widget/my_future_builder.dart';
import 'package:iap_app/component/tweet/item/tweet_reply_item_detail.dart';
import 'package:iap_app/component/tweet/item/tweet_reply_item_simple.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TweetReplyWrapper extends StatelessWidget {
  final BaseTweet tweet;
  final List<TweetReply> replies;
  final Function showReplyInputCb;
  final Function refreshReply;

  TweetReplyWrapper(this.tweet, this.replies, this.showReplyInputCb, this.refreshReply);

  @override
  Widget build(BuildContext context) {
    if (!tweet.enableReply) {
      return Container(
          margin: const EdgeInsets.only(top: 10.0),
          alignment: Alignment.center,
          child: Text('评论关闭',
              style: const TextStyle(
                  fontSize: SizeConstant.TWEET_DISABLE_REPLY_SIZE,
                  color: ColorConstant.TWEET_DISABLE_COLOR_TEXT_COLOR)));
    }
    ;

    if (replies == null || replies.length == 0) {
      return Container(
          margin: const EdgeInsets.only(top: 10.0),
          alignment: Alignment.center,
          child: Text('快来第一个评论吧',
              style: MyDefaultTextStyle.getTweetTimeStyle(context, fontSize: Dimens.font_sp13p5)));
    }

    int len = replies.length;
    List<Widget> trWs = new List();
    for (int i = 0; i < len; i++) {
      TweetReply dirTr = replies[i];
      trWs.add(TweetReplyItemDetail(
          tweetAccountId: tweet.account.id,
          tweetAnonymous: tweet.anonymous,
          reply: dirTr,
          parentId: dirTr.id,
          tweetId: tweet.id,
          tweetType: tweet.type,
          onTapReply: (displayNick) => _sendReply(2, dirTr.id, dirTr.account.id, tarAccNick: displayNick),
          refresh: this.refreshReply));

      if (!CollectionUtil.isListEmpty(dirTr.children)) {
        dirTr.children.forEach((tr) {
          trWs.add(TweetReplyItemDetail(
            tweetAccountId: tweet.account.id,
            tweetType: tweet.type,
            tweetAnonymous: tweet.anonymous,
            reply: tr,
            parentId: dirTr.id,
            tweetId: tweet.id,
            onTapReply: (displayNick) => _sendReply(2, dirTr.id, tr.account.id, tarAccNick: displayNick),
            refresh: this.refreshReply,
          ));
        });
      }
    }

    return Container(
      child: ListView(
          shrinkWrap: true,
          physics: new NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          children: trWs),
    );
  }

  _sendReply(int type, int parentId, String tarAccId, {String tarAccNick}) {
    if (showReplyInputCb != null) {
      TweetReply tr = new TweetReply();
      tr.tweetId = tweet.id;
      tr.type = type;
      tr.parentId = parentId;
      tr.anonymous = false;
      tr.tarAccount = Account.fromId(tarAccId);
      showReplyInputCb(tr, tarAccNick, tarAccId);
    }
  }
}
//class TweetReplyWrapper extends StatefulWidget {
//  final int tweetId;
//
//  TweetReplyWrapper(this.tweetId);
//
//  @override
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//    return _TweetReplyWrapper();
//  }
//
////  _sendReply(int type, int parentId, String tarAccId, {String tarAccNick}) {
////    if (showReplyInputCb != null) {
////      TweetReply tr = new TweetReply();
////      tr.tweetId = tweet.id;
////      tr.type = type;
////      tr.parentId = parentId;
////      tr.anonymous = false;
////      tr.tarAccount = Account.fromId(tarAccId);
////      showReplyInputCb(tr, tarAccNick, tarAccId);
////    }
////  }
//}
//
//class _TweetReplyWrapper extends State<TweetReplyWrapper> {
//  Future<List<TweetReply>> _fetchDataTask;
//
//  Future<List<TweetReply>> _loadData() async {
//    List<TweetReply> replies = await TweetApi.queryTweetReply(widget.tweetId, true);
//    return replies;
//  }
//
//  @override
//  void initState() {
//    super.initState();
//    this._fetchDataTask = _loadData();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    if (widget.tweetId <= 0) {
//      return Gaps.empty;
//    }
//    return Container(
//        child: FutureBuilderWidget<List<TweetReply>>(
//      commonWidget: TweetReplyWrapperView(),
//      loadData: (context) => _fetchDataTask,
//      loadingWidget: SpinKitThreeBounce(color: ColorConstant.TWEET_DETAIL_REPLY_ROW_COLOR, size: 18.0),
//    ));
//  }
//}

class TweetReplyWrapperView extends NetNormalWidget<List<TweetReply>> {
  @override
  Widget buildContainer(BuildContext context, List<TweetReply> t) {
    if (t == null || t.length == 0) {
      return Container(
          margin: const EdgeInsets.only(top: 10.0),
          alignment: Alignment.center,
          child: Text('快来第一个评论吧',
              style: MyDefaultTextStyle.getTweetTimeStyle(context, fontSize: Dimens.font_sp13p5)));
    }
//    return Text('评论${t.length}',style: TextStyle(color: Colors.black),);
    return ListView.builder(
        primary: false,
        itemCount: t.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Text("hello$index");
        });
  }
}
