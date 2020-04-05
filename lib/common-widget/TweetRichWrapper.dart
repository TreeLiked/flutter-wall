import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:iap_app/common-widget/imgae_container.dart';
import 'package:iap_app/common-widget/my_future_builder.dart';
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

  TweetRichWrapper({this.tweet});

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
    return MyShadowCard(
        margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 3.0),
        shadowColor: isDark ? Colors.white10 : Colors.black12,
        onClick: () => NavigatorUtils.goWebViewPage(context, t.title, t.url),
        radius: 10.0,
        child: Container(
//          color: isDark ? Colors.black12 : Colors.pink[200],
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
