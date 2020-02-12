import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/click_item.dart';
import 'package:iap_app/common-widget/exit_dialog.dart';
import 'package:iap_app/common-widget/simple_confirm.dart';
import 'package:iap_app/common-widget/text_clickable_iitem.dart';
import 'package:iap_app/component/bottom_sheet_choic_item.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/account_edit_param.dart';
import 'package:iap_app/model/gender.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/page/common/image_crop.dart';
import 'package:iap_app/part/notification/my_sn_card.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/resources.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/routes/setting_router.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/image_utils.dart';
import 'package:iap_app/util/oss_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class InteractiveNotificationMainPage extends StatefulWidget {
  @override
  _InteractiveNotificationMainPageState createState() => _InteractiveNotificationMainPageState();
}

class _InteractiveNotificationMainPageState extends State<InteractiveNotificationMainPage>
    with AutomaticKeepAliveClientMixin<InteractiveNotificationMainPage> {
  bool isDark = false;

  List<InteractiveCard> interMsgList;

  @override
  void initState() {
    super.initState();
    this._fetchInteractiveMessages();
  }

  void _fetchInteractiveMessages() async {
    List<BaseTweet> pbt =
        await (TweetApi.queryTweets(PageParam(1, pageSize: 25, orgId: Application.getOrgId)));
    List temp = pbt.map((tweet) {
      return InteractiveCard(
          optType: 'PRAISE',
          cover: tweet.picUrls == null ? null : tweet.picUrls[0],
          content: tweet.body,
          jumpRefId: tweet.id.toString(),
          jump: () {
            NavigatorUtils.push(context, Routes.tweetDetail + "?tweetId=${tweet.id}");
          },
          isDark: isDark,
          date: tweet.gmtCreated,
          optAccount: tweet.account,
          optAccountAnonymous: tweet.anonymous);
    }).toList();
    setState(() {
      this.interMsgList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    isDark = ThemeUtils.isDark(context);
    return Scaffold(
//        backgroundColor: isDark ? Colours.dark_bg_color : Colours.bg_color,
        appBar: MyAppBar(
          centerTitle: "互动消息",
          isBack: true,
          actionName: '全部已读',
          onPressed: () {},
        ),
        body: interMsgList != null && interMsgList.length > 0
            ? SingleChildScrollView(
                child: Column(children: interMsgList),
              )
            : Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.only(top: 50),
                child: interMsgList == null ? CupertinoActivityIndicator() : Text('暂无消息'),
              ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class InteractiveCard extends StatelessWidget {
  final String optType;
  final String cover;
  final String content;
  final String jumpRefId;
  final Function jump;
  final DateTime date;

  final bool isDark;
  final Account optAccount;
  final bool optAccountAnonymous;

  InteractiveCard(
      {this.optType,
      this.cover,
      this.content,
      this.jumpRefId,
      this.jump,
      this.isDark = false,
      this.date,
      this.optAccount,
      this.optAccountAnonymous = true});

  @override
  Widget build(BuildContext context) {
    return MyShadowCard(
        onClick: jump,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _dateTimeContainer(context),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: _buildTitle(context),
                  ),
                  jump != null
                      ? Container(
                          margin: const EdgeInsets.only(right: 4.0),
                          height: 8.0,
                          width: 8.0,
                          decoration: BoxDecoration(
                            color: Colours.red,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        )
                      : Gaps.empty,
                  jump != null ? Images.arrowRight : Gaps.empty
                ],
              ),
              Gaps.vGap8,
              Gaps.line,
              Gaps.vGap8,
              content != null && content != "" ? _buildContent(context) : _buildCover()
            ],
          ),
        ));
  }

  _buildCover() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: 180,
      ),
      child: ClipRRect(
        child: CachedNetworkImage(
          placeholder: (context, url) => CupertinoActivityIndicator(),
          imageUrl: cover,
          fit: BoxFit.cover,
        ),
        borderRadius: const BorderRadius.all(const Radius.circular(10)),
      ),
    );
  }

  _buildTitle(context) {
    String optStr =
        optType == "PRAISE" ? "点赞" : (optType == "COMMENT" ? "评论" : (optType == "REPLY" ? "回复" : ""));
    return RichText(
      maxLines: 2,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: [
        TextSpan(
            text: optAccountAnonymous
                ? TextConstant.TWEET_ANONYMOUS_NICK
                : (optAccount.nick ?? TextConstant.TEXT_UN_CATCH_ERROR),
            style: MyDefaultTextStyle.getTweetNickStyle(context, Dimens.font_sp15)),
        TextSpan(
            text: optStr == "" ? "" : "$optStr了你", style: MyDefaultTextStyle.getMainTextBodyStyle(isDark,fontSize: Dimens.font_sp15))
      ]),
    );
  }

  _buildContent(context) {
    return Container(
        alignment: Alignment.centerLeft,
        child: RichText(
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
              children: [TextSpan(text: content, style: MyDefaultTextStyle.getMainTextBodyStyle(isDark,fontSize: Dimens.font_sp15))]),
        ));
  }

  _dateTimeContainer(context) {
    return date != null
        ? Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.only(bottom: 10),
            child: Text(TimeUtil.getShortTime(date), style: MyDefaultTextStyle.getTweetTimeStyle(context)),
          )
        : Gaps.empty;
  }
}
