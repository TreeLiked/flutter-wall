import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/api/message.dart';
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
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:iap_app/model/message/topic_reply_message.dart';
import 'package:iap_app/model/message/tweet_praise_message.dart';
import 'package:iap_app/model/message/tweet_reply_message.dart';
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
import 'package:iap_app/routes/square_router.dart';
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
import 'package:pull_to_refresh/pull_to_refresh.dart';

class InteractiveNotificationMainPage extends StatefulWidget {
  @override
  _InteractiveNotificationMainPageState createState() => _InteractiveNotificationMainPageState();
}

class _InteractiveNotificationMainPageState extends State<InteractiveNotificationMainPage>
    with AutomaticKeepAliveClientMixin<InteractiveNotificationMainPage> {
  bool isDark = false;

  List<Widget> interMsgList;

  RefreshController _refreshController = RefreshController(initialRefresh: true);

  int currentPage = 1;
  int pageSize = 25;

  @override
  void initState() {
    super.initState();
  }

  void _fetchInteractiveMessages() async {
    print('--------------------------请求互动消息---------------');
    List<AbstractMessage> msgs = await getData(1, pageSize);
    if (msgs == null || msgs.length == 0) {
      setState(() {
        if (this.interMsgList != null) {
          this.interMsgList.clear();
        }
      });
      _refreshController.refreshCompleted();
      return;
    }
    List<Widget> cards = msgs.map((absMsg) {
      print(absMsg.toJson());
      switch (absMsg.messageType) {
        case MessageType.TWEET_PRAISE:
          return TweetPraiseCard(absMsg as TweetPraiseMessage);
        case MessageType.TWEET_REPLY:
          return TweetReplyCard(absMsg as TweetReplyMessage);
        case MessageType.TOPIC_REPLY:
          return TopicReplyCard(absMsg as TopicReplyMessage);
        case MessageType.POPULAR:
        case MessageType.PLAIN_SYSTEM:
        case MessageType.REPORT:
          return Gaps.empty;
      }
      return Gaps.empty;
    }).toList();
    setState(() {
      if (this.interMsgList != null) {
        this.interMsgList.clear();
      } else {
        this.interMsgList = List();
      }
      this.interMsgList.addAll(cards);
    });
    _refreshController.refreshCompleted(resetFooterState: true);

//    List<BaseTweet> pbt =
//        await (MessageAPI.queryTestMsgs(PageParam(currentPage, pageSize: pageSize, orgId: Application.getOrgId)));
//    List temp = pbt.map((tweet) {
//      return InteractiveCard(
//          optType: 'PRAISE',
//          cover: tweet.medias == null ? null : tweet.medias[0].url,
//          content: tweet.body,
//          jumpRefId: tweet.id.toString(),
//          jump: () {
//            NavigatorUtils.push(context, Routes.tweetDetail + "?tweetId=${tweet.id}");
//          },
//          isDark: isDark,
//          date: tweet.gmtCreated,
//          optAccount: tweet.account,
//          optAccountAnonymous: tweet.anonymous);
//    }).toList();
//    setState(() {
//      this.interMsgList = temp;
//    });
  }

  Future<List<AbstractMessage>> getData(int currentPage, int pageSize) async {
    return await MessageAPI.queryInteractionMsg(currentPage, pageSize);
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
        body: SafeArea(
            top: false,
            child: SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: true,
                header: WaterDropHeader(
                  waterDropColor: Colours.app_main,
                  complete: const Text('刷新完成'),
                ),
                footer: ClassicFooter(
                  loadingText: '正在加载更多消息...',
                  canLoadingText: '释放以加载更多',
                  noDataText: '没有更多消息了',
                ),
                onRefresh: _fetchInteractiveMessages,
                child: SingleChildScrollView(
                    child: interMsgList != null && interMsgList.length > 0
                        ? Column(children: interMsgList)
                        : _refreshController.isRefresh
                            ? Gaps.empty
                            : Container(
                                alignment: Alignment.topCenter,
                                margin: const EdgeInsets.only(top: 50),
                                child: Text('暂无消息'),
                              )))));
//        body: interMsgList != null && interMsgList.length > 0
//            ? SingleChildScrollView(
//          child: Column(children: interMsgList),
//        )
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class TweetPraiseCard extends StatelessWidget {
  final TweetPraiseMessage praiseMsg;

  TweetPraiseCard(this.praiseMsg);

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(praiseMsg, praiseMsg.praiser, false, "点赞", jump: () {
      NavigatorUtils.push(context, Routes.tweetDetail + "?tweetId=${praiseMsg.tweetId}");
    }, subContent: praiseMsg.tweetBody, coverUrl: praiseMsg.coverUrl);
  }
}

class TweetReplyCard extends StatelessWidget {
  final TweetReplyMessage replyMsg;

  TweetReplyCard(this.replyMsg);

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(replyMsg, replyMsg.replier, replyMsg.anonymous, "评论", jump: () {
      NavigatorUtils.push(context, Routes.tweetDetail + "?tweetId=${replyMsg.tweetId}");
    }, mainContent: replyMsg.replyContent, subContent: replyMsg.tweetBody, coverUrl: replyMsg.coverUrl);
  }
}

class TopicReplyCard extends StatelessWidget {
  final TopicReplyMessage replyMsg;

  TopicReplyCard(this.replyMsg);

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(replyMsg, replyMsg.replier, false, "评论", jump: () {
      NavigatorUtils.push(context, SquareRouter.topicDetail + "?topicId=${replyMsg.topicId}");
    }, mainContent: replyMsg.replyContent, subContent: replyMsg.topicBody);
  }
}

class InteractiveCard extends StatelessWidget {
  final AbstractMessage message;
  final Account optAccount;
  final accountAnonymous;

  // 点赞，评论，回复
  final String optType;

  final Function jump;

  // 回复内容
  final String mainContent;

  // 推文内容 ｜｜ 话题标题
  final String subContent;

  final String coverUrl;
  bool isDark = false;

  InteractiveCard(this.message, this.optAccount, this.accountAnonymous, this.optType,
      {this.jump, this.mainContent, this.subContent, this.coverUrl});

  @override
  Widget build(BuildContext context) {
    isDark = ThemeUtils.isDark(context);
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
              subContent != null && subContent != "" ? _buildContent(context) : _buildCover()
            ],
          ),
        ));
  }

  _buildCover() {
    return coverUrl != null
        ? Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: 180,
            ),
            child: ClipRRect(
              child: CachedNetworkImage(
                placeholder: (context, url) => CupertinoActivityIndicator(),
                imageUrl: coverUrl,
                fit: BoxFit.cover,
              ),
              borderRadius: const BorderRadius.all(const Radius.circular(10)),
            ),
          )
        : Gaps.empty;
  }

  _buildTitle(context) {
    return RichText(
      maxLines: 2,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: [
        TextSpan(
            text: accountAnonymous
                ? TextConstant.TWEET_ANONYMOUS_NICK
                : optAccount!= null? (optAccount.nick ?? TextConstant.TEXT_UN_CATCH_ERROR):"",
            style: MyDefaultTextStyle.getTweetNickStyle(context, Dimens.font_sp15)),
        TextSpan(
            text: " $optType了你",
            style: MyDefaultTextStyle.getMainTextBodyStyle(isDark, fontSize: Dimens.font_sp15))
      ]),
    );
  }

  _buildContent(context) {
    return Container(
        alignment: Alignment.centerLeft,
        child: RichText(
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(children: [
            TextSpan(
                text: subContent,
                style: MyDefaultTextStyle.getMainTextBodyStyle(isDark, fontSize: Dimens.font_sp15))
          ]),
        ));
  }

  _dateTimeContainer(context) {
    return message.sentTime != null
        ? Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.only(bottom: 10),
            child: Text(TimeUtil.getShortTime(message.sentTime),
                style: MyDefaultTextStyle.getTweetTimeStyle(context)),
          )
        : Gaps.empty;
  }
}
