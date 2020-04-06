import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/TweetRichWrapper.dart';
import 'package:iap_app/common-widget/my_future_builder.dart';
import 'package:iap_app/common-widget/my_special_text_builder.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/web_link.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/http_util.dart';
import 'package:iap_app/util/string.dart';

class TweetLinkWrapper extends StatelessWidget {
  final BaseTweet tweet;
  final bool fromHot;

  const TweetLinkWrapper(this.tweet, {this.fromHot = false});

  @override
  Widget build(BuildContext context) {
    if (tweet == null) {
      return Gaps.empty;
    }
    final String body = tweet.body;
    if (StringUtil.isEmpty(body)) {
      return Gaps.empty;
    }

    if (tweet.linkWrapper != null) {
      return tweet.linkWrapper;
    }

    String link = StringUtil.getFirstUrlInStr(body);
    if (link == null || link == "") {
      return Gaps.empty;
    }
    final wrapper = TweetRichWrapper(tweet: tweet,fromHot: fromHot);
    tweet.linkWrapper = wrapper;

    return Container(
      child: FutureBuilderWidget<WebLinkModel>(
        loadData: (context) => HttpUtil.loadHtml(context, link),
        commonWidget: wrapper,
      ),
    );
  }
}

class TweetLinkWrapper2 extends StatefulWidget {
  final BaseTweet tweet;
  final bool fromHot;
  final Future task;

  const TweetLinkWrapper2(this.tweet, this.task, {this.fromHot = false});

  @override
  State<StatefulWidget> createState() {
    return _TweetLinkWrapper2();
  }
}

class _TweetLinkWrapper2 extends State<TweetLinkWrapper2> {
  @override
  Widget build(BuildContext context) {
    BaseTweet tweet = widget.tweet;
    if (tweet == null || widget.task == null) {
      return Gaps.empty;
    }
    final String body = tweet.body;
    if (StringUtil.isEmpty(body)) {
      return Gaps.empty;
    }

    String link = StringUtil.getFirstUrlInStr(body);
    if (link == null || link == "") {
      return Gaps.empty;
    }
    final wrapper = TweetRichWrapper(tweet: tweet,fromHot: true);

    return Container(
      child: FutureBuilderWidget<WebLinkModel>(
        loadData: (context) => widget.task,
        commonWidget: wrapper,
      ),
    );
  }
}
