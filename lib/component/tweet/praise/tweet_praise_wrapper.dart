import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/component/tweet/item/tweet_reply_item_simple.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:provider/provider.dart';

class TweetPraiseWrapper extends StatelessWidget {
  final BaseTweet tweet;
  final bool limit;
  final double fontSize;
  final bool prefixIcon;

  TweetPraiseWrapper(this.tweet,
      {this.limit = false, this.fontSize = Dimens.font_sp14, this.prefixIcon = true});

  @override
  Widget build(BuildContext context) {
    if(tweet == null) {
      return Gaps.empty;
    }
    bool hasPraise = tweet.latestPraise != null && tweet.latestPraise.length > 0;
    if (!hasPraise) {
      if(!prefixIcon) {
        return Gaps.empty;
      }
    }
    // 最近点赞的人数

    List<Widget> items = List();

    List<InlineSpan> spans = List();
    if (prefixIcon) {
      spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                updatePraise(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: LoadAssetIcon(
                  tweet.loved
                      ? PathConstant.ICON_PRAISE_ICON_PRAISE
                      : PathConstant.ICON_PRAISE_ICON_UN_PRAISE,
                  width: 17,
                  height: 17,
                  color: tweet.loved ? Colors.pink[100] : null,
                ),
              ))));
    }

    List<Account> praiseList = tweet.latestPraise;
    if (hasPraise) {
      for (int i = 0; i < praiseList.length && i < GlobalConfig.MAX_DISPLAY_PRAISE; i++) {
        Account account = praiseList[i];
        spans.add(TextSpan(
            text: "${account.nick}" + (i != praiseList.length - 1 ? '、' : ' '),
            style: MyDefaultTextStyle.getTweetNickStyle(13, bold: false, context: context),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                NavigatorUtils.goAccountProfile2(context, account);
              }));
      }
    }
    Widget widgetT = RichText(
      text: TextSpan(children: spans),
      softWrap: true,
    );
    items.add(widgetT);
    if (hasPraise && praiseList.length > GlobalConfig.MAX_DISPLAY_PRAISE) {
      int diff = praiseList.length - GlobalConfig.MAX_DISPLAY_PRAISE;
      items.add(Text(
        " 等共$diff人刚刚赞过",
        style: TextStyle(fontSize: 13),
      ));
    }

    return Wrap(
        alignment: WrapAlignment.start, crossAxisAlignment: WrapCrossAlignment.center, children: items);
  }

  void updatePraise(BuildContext context) async {
    if (tweet.latestPraise == null) {
      tweet.latestPraise = List();
    }
    final _tweetProvider = Provider.of<TweetProvider>(context);
    final _localAccProvider = Provider.of<AccountLocalProvider>(context);
    _tweetProvider.updatePraise(context, _localAccProvider.account, tweet.id, !tweet.loved);
    await TweetApi.operateTweet(tweet.id, 'PRAISE', tweet.loved);
    if (tweet.loved) {
      Utils.showFavoriteAnimation(context, size: 20);
      Future.delayed(Duration(milliseconds: 1600)).then((_) => Navigator.pop(context));
    }
  }
}
