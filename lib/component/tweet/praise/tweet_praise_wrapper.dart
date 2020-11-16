import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/theme_utils.dart';
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
    if (tweet == null) {
      return Gaps.empty;
    }
    bool hasPraise = tweet.latestPraise != null && tweet.latestPraise.length > 0;
    if (!hasPraise) {
//      if (!prefixIcon) {
      return Gaps.empty;
//      }
    }
    // 最近点赞的人数

    List<Widget> items = List();

    List<InlineSpan> spans = List();
    if (prefixIcon) {
      spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: const Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: const LoadAssetIcon(PathConstant.ICON_PRAISE_ICON_LOVE,
                width: 17, height: 17, color: ColorConstant.TWEET_NICK_COLOR),
          )));
    }

    List<Account> praiseList = tweet.latestPraise;
    int len = hasPraise ? praiseList.length : -1;
    if (hasPraise) {
      for (int i = 0; i < len && i < GlobalConfig.MAX_DISPLAY_PRAISE; i++) {
        Account account = praiseList[i];
        spans.add(TextSpan(
            text: "${account.nick}" + (i != GlobalConfig.MAX_DISPLAY_PRAISE - 1 && i != len - 1 ? '、' : ' '),
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
    if (hasPraise && len > GlobalConfig.MAX_DISPLAY_PRAISE) {
      int diff = len - GlobalConfig.MAX_DISPLAY_PRAISE;
      spans.add(TextSpan(
        text: " 等共$len人刚刚赞过",
        style: MyDefaultTextStyle.getTweetBodyStyle(context, fontSize: 13.0),
      ));
    }
    items.add(widgetT);

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: ThemeUtils.isDark(context)
              ? ColorConstant.DEFAULT_BAR_BACK_COLOR_DARK
              : ColorConstant.TWEET_RICH_BG,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Wrap(
            alignment: WrapAlignment.start, crossAxisAlignment: WrapCrossAlignment.center, children: items));
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
