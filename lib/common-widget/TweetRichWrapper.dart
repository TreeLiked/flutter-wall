import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:iap_app/common-widget/imgae_container.dart';
import 'package:iap_app/common-widget/my_future_builder.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/web_link.dart';
import 'package:iap_app/part/notification/my_sn_card.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/widget_util.dart';

class TweetRichWrapper extends NetNormalWidget<WebLinkModel> {
  final BaseTweet tweet;
  final bool fromHot;

  TweetRichWrapper({this.tweet, this.fromHot = false});

  @override
  Widget buildContainer(BuildContext context, WebLinkModel t) {
    if (t == null) {
      if (tweet == null || tweet.wlm == null) {
        return Gaps.empty;
      }
      t = tweet.wlm;
    } else {
      if (tweet != null) {
        tweet.wlm = t;
      }
    }
    if (StringUtil.isEmpty(t.url)) {
      return Gaps.empty;
    }

    bool isDark = ThemeUtils.isDark(context);
    return GestureDetector(
        onTap: () => NavigatorUtils.goWebViewPage(context, t.title, t.url),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
            margin: const EdgeInsets.only(top: 8.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: isDark ? ColorConstant.TWEET_RICH_BG_DARK : ColorConstant.TWEET_RICH_BG),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  t.iconPath != null && t.iconPath.startsWith("http")
                      ? ImageContainer(
                          round: false,
                          url: t.iconPath,
                          height: 25,
                          width: 25,
                          errorWidget: Icon(Icons.link),
                        )
                      : Gaps.empty,
                  Gaps.hGap8,
                  Expanded(
                    child: Text(
                      t.title ?? "未知链接",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: MyDefaultTextStyle.getMainTextBodyStyle(ThemeUtils.isDark(context),
                          fontSize: Dimens.font_sp13),
                    ),
                  )
                ])));
    return MyShadowCard(
        margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 3.0),
        shadowColor: isDark ? Colors.white10 : Colors.black12,
        onClick: () => NavigatorUtils.goWebViewPage(context, t.title, t.url),
        radius: 10.0,
        child: Container(
          color: ColorConstant.TWEET_RICH_BG,
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              t.iconPath != null && t.iconPath.startsWith("http")
                  ? ImageContainer(
                      url: t.iconPath,
                      height: 28,
                      width: 28,
                      errorWidget: Icon(Icons.link),
                    )
                  : isDark
                      ? const LoadAssetSvg(
                          "link",
                          color: Colors.white38,
                          width: 28,
                          height: 28,
                        )
                      : const LoadAssetSvg(
                          "link_circle",
                          color: Colors.lightBlue,
                          width: 28,
                          height: 28,
                        ),
              Gaps.hGap8,
              Expanded(
                child: Text(
                  t.title ?? "未知链接",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: MyDefaultTextStyle.getMainTextBodyStyle(ThemeUtils.isDark(context),
                      fontSize: Dimens.font_sp16),
                ),
              )
            ],
          ),
        ));
//    return tweet.linkWrapper;
  }
}
