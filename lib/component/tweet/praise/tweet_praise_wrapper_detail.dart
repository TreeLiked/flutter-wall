import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/bezier_bounce_footer.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/common-widget/my_future_builder.dart';
import 'package:iap_app/component/tweet/item/tweet_reply_item_simple.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TweetPraiseWrapper2 extends StatelessWidget {
  final List<Account> t;

  TweetPraiseWrapper2(this.t);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (t == null || t.length == 0) {
      return Container(
          margin: const EdgeInsets.only(top: 10.0),
          alignment: Alignment.center,
          child: Text('快来第一个点赞吧',
              style: MyDefaultTextStyle.getTweetTimeStyle(context, fontSize: Dimens.font_sp13p5)));
    }
//    return Text('评论${t.length}',style: TextStyle(color: Colors.black),);
    int limit = GlobalConfig.MAX_DISPLAY_PRAISE_DETAIL;
    bool exceed = t.length > limit;
    int len = exceed ? limit : t.length;

    List<Widget> items = List();
    List<InlineSpan> spans = List();

    for (int i = 0; i < len; i++) {
      Account account = t[i];
      spans.add(TextSpan(
          text: "${account.nick}" + (i != len - 1 ? '、' : ' '),
          style: MyDefaultTextStyle.getTweetNickStyle(13, bold: false, context: context),
          recognizer: TapGestureRecognizer()
            ..onTap = () => NavigatorUtils.goAccountProfile2(context, account)));
    }

    Widget widgetT = RichText(
      text: TextSpan(children: spans),
      softWrap: true,
    );
    items.add(widgetT);
    if (exceed) {
      int diff = t.length - limit;
      items.add(Text(
        " 等共$diff人觉得很赞",
        style: TextStyle(fontSize: 13),
      ));
    }

    return Wrap(
        alignment: WrapAlignment.start, crossAxisAlignment: WrapCrossAlignment.center, children: items);
  }
}

class TweetPraiseWrapper extends StatefulWidget {
  final int tweetId;
  final Future getPraiseTask;

  TweetPraiseWrapper(this.tweetId, {this.getPraiseTask});

  var state = _TweetPraiseWrapper();

  refresh() {
    if (state != null) {
      state.refresh();
    }
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return state;
  }
}

class _TweetPraiseWrapper extends State<TweetPraiseWrapper> {
  Future<List<Account>> _fetchDataTask;
  int tweetId;

  Future<List<Account>> _loadData() async {
    List<Account> replies = await TweetApi.queryTweetPraise(widget == null ? tweetId : widget.tweetId);
    print(replies.length);
    return replies;
  }

  void refresh() {
    _fetchDataTask = _loadData();
  }

  @override
  void initState() {
    super.initState();
    tweetId = widget.tweetId;
    this._fetchDataTask = _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tweetId <= 0) {
      return Gaps.empty;
    }
    return Container(
        child: FutureBuilderWidget<List<Account>>(
      commonWidget: TweetReplyWrapperView(),
      loadData: (context) => widget.getPraiseTask,
      loadingWidget: SpinKitThreeBounce(color: ColorConstant.TWEET_DETAIL_PRAISE_ROW_COLOR, size: 18.0),
    ));
  }
}

class TweetReplyWrapperView extends NetNormalWidget<List<Account>> {
  @override
  Widget buildContainer(BuildContext context, List<Account> t) {
    if (t == null || t.length == 0) {
      return Container(
          margin: const EdgeInsets.only(top: 10.0),
          alignment: Alignment.center,
          child: Text('快来第一个点赞吧',
              style: MyDefaultTextStyle.getTweetTimeStyle(context, fontSize: Dimens.font_sp13p5)));
    }
//    return Text('评论${t.length}',style: TextStyle(color: Colors.black),);
    int limit = GlobalConfig.MAX_DISPLAY_PRAISE_DETAIL;
    bool exceed = t.length > limit;
    int len = exceed ? limit : t.length;

    List<Widget> items = List();
    List<InlineSpan> spans = List();

    for (int i = 0; i < len; i++) {
      Account account = t[i];
      spans.add(TextSpan(
          text: "${account.nick}" + (i != len - 1 ? '、' : ' '),
          style: MyDefaultTextStyle.getTweetNickStyle(13, bold: false, context: context),
          recognizer: TapGestureRecognizer()
            ..onTap = () => NavigatorUtils.goAccountProfile2(context, account)));
    }

    Widget widgetT = RichText(
      text: TextSpan(children: spans),
      softWrap: true,
    );
    items.add(widgetT);
    if (exceed) {
      int diff = t.length - limit;
      items.add(Text(
        " 等共$diff人觉得很赞",
        style: TextStyle(fontSize: 13),
      ));
    }

    return Wrap(
        alignment: WrapAlignment.start, crossAxisAlignment: WrapCrossAlignment.center, children: items);
  }
}
