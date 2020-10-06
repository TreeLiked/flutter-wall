import 'package:flustars/flustars.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/api/unlike.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/component/title_item_wrapper.dart';
import 'package:iap_app/component/tweet/praise/tweet_praise_wrapper_detail.dart';
import 'package:iap_app/component/tweet/reply/tweet_reply_wrapper_detail.dart';
import 'package:iap_app/component/tweet/tweet_body_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_image_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_link_wrapper.dart';
import 'package:iap_app/component/tweet/tweet_type_wrapper.dart';
import 'package:iap_app/component/tweet_delete_bottom_sheet.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/tweet_account.dart';
import 'package:iap_app/model/gender.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/page/common/report_page.dart';
import 'package:iap_app/page/tweet/tweet_comment_wrapper.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/http_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/tweet_reply_util.dart';
import 'package:iap_app/util/umeng_util.dart';
import 'package:iap_app/util/widget_util.dart' as prefix0;
import 'package:provider/provider.dart';

import '../application.dart';

class TweetDetail extends StatefulWidget {
  BaseTweet _tweet;
  final int hotRank;
  final bool newLink;
  final bool accountMore;
  final Function onDelete;

  int tweetId;
  bool _fromHot = false;

  TweetDetail(this._tweet,
      {this.tweetId, this.hotRank = -1, this.accountMore = false, this.newLink = false, this.onDelete}) {
    if (this.hotRank >= 0) {
      _fromHot = true;
    }
  }

  @override
  State<StatefulWidget> createState() {
    print('TweetDetail create state');
    return TweetDetailState();
  }
}

class TweetDetailState extends State<TweetDetail> with AutomaticKeepAliveClientMixin<TweetDetail> {
  Future _getPraiseTask;
  Future _getReplyTask;
  Future _getLinkTask;

  BuildContext myContext;
  PersistentBottomSheetController _bottomSheetController;

  List<Account> praiseAccounts = [];
  List<TweetReply> replies = [];

  // 回复相关
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();
  double _replyContainerWidth = 0;
  TweetReply curReply = TweetReply();
  String _hintText = "评论";

  bool isDark = false;

  TweetDetailState() {
    curReply.anonymous = false;
    print('TweetDETAIL state construct');
  }

  BaseTweet tweet;

  bool firInit = true;

  @override
  void initState() {
    super.initState();

//    _getPraiseTask = _loadData();
    _fetchTweetIfNullAndFetchExtra();

    UMengUtil.userGoPage(
        widget._fromHot ? UMengUtil.PAGE_TWEET_INDEX_DETAIL_HOT : UMengUtil.PAGE_TWEET_INDEX_DETAIL);
  }

  _fetchTweetIfNullAndFetchExtra() async {
    if (widget._tweet == null) {
      BaseTweet bt = await TweetApi.queryTweetById(widget.tweetId, pop: false);
      if (bt == null) {
        ToastUtil.showToast(context, '内容不存在或已经被删除');
        NavigatorUtils.goBack(context);
        return;
      }
      setState(() {
        firInit = false;
        widget._tweet = bt;
        widget._tweet.linkWrapper = null;
        tweet = widget._tweet;
      });
      checkHasLink();
      _getReplyTask = getTweetReply();
      _getPraiseTask = getTweetPraises();
    } else {
      setState(() {
        firInit = false;
        tweet = widget._tweet;
      });
      checkHasLink();
      _getReplyTask = getTweetReply();
      _getPraiseTask = getTweetPraises();
    }
  }

  checkHasLink() {
    if (tweet.linkWrapper != null && !widget.newLink) {
      return;
    }
    String body = widget._tweet.body;
    if (!StringUtil.isEmpty(body) && body.trim().length > 0) {
      String link = StringUtil.getFirstUrlInStr(body);
      if (link != null) {
        _getLinkTask = HttpUtil.loadHtml(context, link);
      }
    }
  }

  Future<List<TweetReply>> getTweetReply() async {
    List<TweetReply> replies = await TweetApi.queryTweetReply(widget._tweet.id, true);
    setState(() {
      this.replies = replies;
    });
    return replies;
  }

  Future<List<Account>> getTweetPraises() async {
    List<Account> as = await TweetApi.queryTweetPraise(widget._tweet.id);
    setState(() {
      this.praiseAccounts = as;
    });
    return as;
  }

  Widget _spaceRow() {
    BaseTweet t = widget._tweet;
    if (t == null) {
      if (firInit) {
        return SpinKitThreeBounce(
          color: Colors.amber,
        );
      } else {
        return Gaps.empty;
      }
    }
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // 头像
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
                onTap: t.anonymous ? null : () => _forwardAccountProfile3(true, t.account),
                child: AccountAvatar(
                    avatarUrl: !t.anonymous ? t.account.avatarUrl : PathConstant.ANONYMOUS_PROFILE,
                    size: SizeConstant.TWEET_PROFILE_SIZE,
                    cache: true,
                    gender: t.anonymous ? Gender.UNKNOWN : Gender.parseGenderByTweetAccount(t.account),
                    whitePadding: false))
          ],
        ),
        Gaps.hGap8,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RichText(
                  softWrap: true,
                  text: TextSpan(children: [
                    TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = t.anonymous ? null : () => _forwardAccountProfile3(true, t.account),
                        text: t.anonymous ? TextConstant.TWEET_ANONYMOUS_NICK : (t.account.nick ?? ""),
                        style: MyDefaultTextStyle.getTweetHeadNickStyle(
                                context, SizeConstant.TWEET_NICK_SIZE + 3,
                                anonymous: t.anonymous)
                            .copyWith(fontFamily: TextConstant.PING_FANG_FONT)),
                  ])),
              Text(TimeUtil.getShortTime(widget._tweet.sentTime),
                  style: pfStyle.copyWith(fontSize: SizeConstant.TWEET_TIME_SIZE, color: Colors.grey))
            ],
          ),
        )
      ],
    );
  }

  Widget _viewContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
            child: Text(
          "${tweet.views > 0 ? '${tweet.views} 次浏览' : ''}",
          style: MyDefaultTextStyle.getTweetTimeStyle(context, fontSize: Dimens.font_sp13p5),
        )),
        Expanded(
            child: Container(
          alignment: Alignment.centerRight,
          child: TweetTypeWrapper(
            tweet.id,
            tweet.type,
            reverseDir: true,
          ),
        ))
      ],
    );
  }

  void updatePraise(BuildContext context, BaseTweet tweet) async {
    if (tweet.latestPraise == null) {
      tweet.latestPraise = List();
    }

    if (!tweet.loved) {
      Utils.showFavoriteAnimation(context);
      Future.delayed(Duration(milliseconds: 1800)).then((_) => NavigatorUtils.goBack(context));
    }
    TweetApi.operateTweet(tweet.id, 'PRAISE', !tweet.loved).then((_) {
      setState(() {
        tweet.loved = !tweet.loved;
        if (tweet.loved) {
          if (praiseAccounts == null) {
            praiseAccounts = List();
          }
          praiseAccounts.insert(0, Application.getAccount);
          if (widget._fromHot) {
            tweet.praise++;
          }
        } else {
          if (tweet.praise > 0) {
            if (!CollectionUtil.isListEmpty(praiseAccounts)) {
              praiseAccounts.removeWhere((account) => account.id == Application.getAccountId);
            }
            if (widget._fromHot) {
              tweet.praise--;
            }
          }
        }
      });
      // 只在首页的推文有效
      final _tweetProvider = Provider.of<TweetProvider>(context);
      final _localAccProvider = Provider.of<AccountLocalProvider>(context);
      _tweetProvider.updatePraise(context, _localAccProvider.account, tweet.id, tweet.loved);
    });
  }

  _forwardAccountProfile(bool up, Account account, {bool forceForbid = false}) {
    if (((up && !widget._tweet.anonymous) || !up) && !forceForbid) {
      NavigatorUtils.push(
          context,
          Routes.accountProfile +
              Utils.packConvertArgs(
                  {'nick': account.nick, 'accId': account.id, 'avatarUrl': account.avatarUrl}));
    }
  }

  _forwardAccountProfile3(bool up, TweetAccount account, {bool forceForbid = false}) {
    if (((up && !widget._tweet.anonymous) || !up) && !forceForbid) {
      NavigatorUtils.push(
          context,
          Routes.accountProfile +
              Utils.packConvertArgs(
                  {'nick': account.nick, 'accId': account.id, 'avatarUrl': account.avatarUrl}));
    }
  }

  @override
  Widget build(BuildContext context) {
    isDark = ThemeUtils.isDark(context);
    BaseTweet tweet = widget._tweet;
    this.myContext = context;
    if (tweet == null) {
      if (firInit) {
        return Scaffold(
          body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) =>
                  _sliverBuilder(context, innerBoxIsScrolled),
              body: Column(
                children: <Widget>[
                  Container(
                    height: 80,
                    alignment: Alignment.topLeft,
                    child: SpinKitChasingDots(color: Colours.app_main, size: 18),
                  )
                ],
              )),
        );
      } else {
        return Gaps.empty;
      }
    }

    return Scaffold(
        backgroundColor: !isDark
            ? (widget._fromHot ? Color(0xffe9e9e9) : null)
            : (widget._fromHot ? Color(0xff2c2c2c) : Colours.dark_bg_color),
        body: Builder(builder: (context) {
          this.myContext = context;
          return Listener(
//                behavior: HitTestBehavior.opaque,
//                onPanDown: (_) {
//                  hideReplyContainer();
//                  hideBottomSheetReplyContainer();
//                },
            onPointerDown: (_) {
              hideBottomSheetReplyContainer();
            },
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) =>
                  _sliverBuilder(context, innerBoxIsScrolled),
              body: widget._tweet != null
                  ? SingleChildScrollView(
                      child: Container(
                      decoration: BoxDecoration(
                          color: isDark ? Colours.dark_bg_color : widget._fromHot ? Color(0xfff0f0f0) : null,
                          borderRadius: const BorderRadius.all(Radius.circular(18))),
                      padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 50.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _spaceRow(),
                          Gaps.vGap10,
                          TweetBodyWrapper(tweet.body, height: 2.0, selectable: true),
                          TweetMediaWrapper(tweet.id, medias: tweet.medias),
                          widget.newLink
                              ? TweetLinkWrapper2(widget._tweet, _getLinkTask, fromHot: widget._fromHot)
                              : TweetLinkWrapper(tweet),
                          Gaps.vGap8,
                          _viewContainer(),
                          Gaps.vGap15,
                          Divider(),
                          Gaps.vGap10,
                          _praiseWrapper(context),
                          TweetPraiseWrapper2(praiseAccounts),
                          _replyWrapper(context),
                          TweetReplyWrapper(tweet, replies,
                              (TweetReply tr, String tarAccNick, String tarAccId) {
                            String hintText = "回复：$tarAccNick";
                            if (tweet.anonymous && tarAccId == tweet.account.id) {
                              hintText = "回复：作者";
                            }
                            showBottomSheetReplyContainer(2, false, hintText, (String value, bool anonymous) {
                              TweetReply reply = TRUtil.assembleReply(tweet, value, false, false,
                                  parentId: tr.parentId, tarAccountId: tarAccId);
                              reply.sentTime = DateTime.now();
                              TRUtil.publicReply(
                                  context,
                                  reply,
                                  (bool success, TweetReply newReply) =>
                                      this.handleSendResult(success, newReply));
                            });
                          }, () {
                            setState(() {
                              _getReplyTask = getTweetReply();
                            });
                          }),
                        ],
                      ),
                    ))
                  : Container(
                      alignment: Alignment.topCenter, child: prefix0.WidgetUtil.getLoadingAnimation()),
            ),
          );
        }));
  }

  Widget _praiseWrapper(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 6.0),
        child: TitleItemWrapper(
            Text(
              "点赞",
              style: pfStyle.copyWith(
                  color: ColorConstant.TWEET_DETAIL_PRAISE_ROW_COLOR, fontSize: Dimens.font_sp14),
            ),
            subTitleText: tweet.praise > 0
                ? Text("${tweet.praise}",
                    style: pfStyle.copyWith(
                        color: ColorConstant.getTweetTimeColor(context), fontSize: Dimens.font_sp13p5))
                : null,
            suffixWidget: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: prefix0.LoadAssetIcon(
                  widget._tweet.loved
                      ? PathConstant.ICON_PRAISE_ICON_PRAISE
                      : PathConstant.ICON_PRAISE_ICON_UN_PRAISE,
                  width: 20,
                  height: 20,
                  color: widget._tweet.loved ? Colors.pink[100] : Colors.grey,
                ),
                onTap: () => updatePraise(context, widget._tweet))));
  }

  Widget _replyWrapper(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 11.0, bottom: 6.0),
        child: TitleItemWrapper(
          Text(
            "评论",
            style: pfStyle.copyWith(
                color: ColorConstant.TWEET_DETAIL_REPLY_ROW_COLOR, fontSize: Dimens.font_sp14),
          ),
          subTitleText: tweet.replyCount > 0
              ? Text(
                  "${tweet.replyCount}",
                  style: pfStyle.copyWith(
                      color: ColorConstant.getTweetTimeColor(context), fontSize: Dimens.font_sp13p5),
                )
              : null,
          suffixWidget: tweet.enableReply
              ? GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: prefix0.LoadAssetIcon(PathConstant.ICON_COMMENT_ICON,
                      width: 20, height: 20, color: Colors.grey),
                  onTap: () {
                    showBottomSheetReplyContainer(1, true, "评论", (String value, bool anonymous) {
                      TweetReply reply = TRUtil.assembleReply(tweet, value, anonymous, true);
                      reply.sentTime = DateTime.now();
                      TRUtil.publicReply(
                          context, reply, (success, data) => this.handleSendResult(success, data));
                    });
                  })
              : null,
        ));
  }

  void handleSendResult(bool success, TweetReply newReply) {
    if (success) {
      hideBottomSheetReplyContainer();
      setState(() {
        _getReplyTask = getTweetReply();
      });
      if (!widget._fromHot) {
        if (newReply != null) {
          if (newReply.type == 1) {
            // 设置到直接回复
            setState(() {
              widget._tweet.replyCount++;
              if (tweet.dirReplies == null) {
                tweet.dirReplies = List();
              }
              tweet.dirReplies.add(newReply);
            });
          } else {
            // 子回复
            int parentId = newReply.parentId;
            TweetReply tr2 = tweet.dirReplies.where((dirReply) => dirReply.id == parentId).first;
            setState(() {
              widget._tweet.replyCount++;
              if (tr2.children == null) {
                tr2.children = List();
              }
              tr2.children.add(newReply);
            });
          }
        } else {
          ToastUtil.showToast(context, TextConstant.TWEET_REPLY_FAIL, gravity: ToastGravity.CENTER);
        }
      }
    } else {
      ToastUtil.showToast(context, TextConstant.TWEET_REPLY_FAIL, gravity: ToastGravity.CENTER);
    }
  }

  void showBottomSheetReplyContainer(replyType, showAnonymous, hintText, onSend) {
    _bottomSheetController = Scaffold.of(this.myContext).showBottomSheet((context) =>
        TweetIndexCommentWrapper(
            showAnonymous: showAnonymous, replyType: replyType, hintText: hintText, onSend: onSend));
  }

  void hideBottomSheetReplyContainer() {
    if (_bottomSheetController != null) {
      _bottomSheetController?.close();
      _bottomSheetController = null;
    }
  }

  List<BottomSheetItem> _getSheetItems() {
    List<BottomSheetItem> items = List();

//    items.add(BottomSheetItem(
//        Icon(
//          Icons.star,
//          color: Color(0xffEE9A49),
//        ),
//        '收藏', () {
//      ToastUtil.showToast(context, '收藏功能暂未开放');
//      Navigator.pop(context);
//    }));
    String accountId = Application.getAccountId;
    if (!StringUtil.isEmpty(accountId) && accountId == widget._tweet.account.id) {
      // 作者自己的内容
      items.add(BottomSheetItem(Icon(Icons.delete, color: Colors.redAccent), '删除', () {
        Navigator.pop(context);
        _showDeleteBottomSheet();
      }));
    } else {
      // 非自己
      items.add(BottomSheetItem(Icon(Icons.do_not_disturb_alt, color: Colors.grey), '屏蔽此内容', () {
        Navigator.pop(context);
        _showShieldedBottomSheet();
      }));

      items.add(BottomSheetItem(Icon(Icons.do_not_disturb_on, color: Colors.orangeAccent), '屏蔽此人', () {
        Navigator.pop(context);
        _showShieldedAccountBottomSheet();
      }));
    }
    items.add(BottomSheetItem(
        Icon(
          Icons.warning,
          color: Colors.grey,
        ),
        '举报', () {
      NavigatorUtils.goBack(context);
      NavigatorUtils.goReportPage(context, ReportPage.REPORT_TWEET, widget._tweet.id.toString(), "推文内容举报");
    }));
    return items;
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              BottomSheetUtil.showBottomSheetView(context, _getSheetItems());
            },
          )
        ],
        backgroundColor: widget._fromHot
            ? (isDark ? Colours.dark_bg_color : Color(0xfff0f0f0))
            : (isDark ? Colours.dark_bg_color : null),
        centerTitle: true,
        //标题居中
        title: Text(
          '详情',
          style:
              pfStyle.copyWith(fontSize: Dimens.font_sp16, fontWeight: FontWeight.w500, letterSpacing: 1.2),
        ),
        elevation: 0.4,
        floating: true,
        pinned: !widget._fromHot,
        snap: false,
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
            )),
        bottom: widget._fromHot
            ? PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: Container(
                    height: 60,
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: '当前热门榜：',
                                style: TextStyle(
                                    fontSize: Dimens.font_sp16,
                                    color: ThemeUtils.isDark(context) ? Colors.grey : Colors.black)),
                            TextSpan(
                                text: 'No. ',
                                style: TextStyle(
                                    fontSize: Dimens.font_sp16,
                                    color: ThemeUtils.isDark(context) ? Colors.grey : Colors.black)),
                            TextSpan(
                                text: '${widget.hotRank}  ',
                                style: TextStyle(
                                    fontSize: Dimens.font_sp16,
                                    color: widget.hotRank < 5
                                        ? Colors.redAccent
                                        : (ThemeUtils.isDark(context) ? Colors.grey : Colors.black)))
                          ])),
                          getFires(widget.hotRank),
                        ],
                      ),
                    )),
              )
            : null,
      )
    ];
  }

  Widget getFires(int rank) {
    List<Widget> list = List();
    if (rank == 1) {
      list.add(Image.asset(
        PathConstant.ICON_CHAMPIN,
        color: Colors.red,
        width: SizeConstant.TWEET_HOT_RANK_ICON_SIZE,
        height: SizeConstant.TWEET_HOT_RANK_ICON_SIZE,
      ));
    } else {
      int count = 5 - rank;
      if (count >= 0) {
        for (int i = 0; i < count; i++) {
          list.add(Image.asset(
            PathConstant.ICON_FIRE,
            color: Colors.pink,
            width: SizeConstant.TWEET_HOT_RANK_ICON_SIZE,
            height: SizeConstant.TWEET_HOT_RANK_ICON_SIZE,
          ));
        }
      }
    }

    return Row(
      children: list,
    );
  }

  void showReplyContainer(String destAccountNick, String destAccountId, bool dirAno) {
    print('show reply container');
    if (StringUtil.isEmpty(destAccountNick)) {
      setState(() {
        _hintText = "评论";
        _replyContainerWidth = MediaQuery.of(context).size.width;
      });
    } else {
      setState(() {
        _hintText = "回复 $destAccountNick";
        _replyContainerWidth = MediaQuery.of(context).size.width;
      });
    }
    _focusNode.requestFocus();
  }

  void hideReplyContainer() {
    if (_replyContainerWidth != 0) {
      setState(() {
        _replyContainerWidth = 0;
        _controller.clear();
        _focusNode.unfocus();
      });
    }
  }

  _sendReply(String value) {
    if (StringUtil.isEmpty(value) || value.trim().length == 0) {
      return;
    }

    curReply.body = value;
    curReply.account = Application.getAccount;
    BaseTweet tweet = widget._tweet;
    curReply.tweetId = tweet.id;

    TweetApi.pushReply(curReply, curReply.tweetId).then((result) {
      hideReplyContainer();
      if (result.isSuccess) {
        setState(() {
          _getReplyTask = getTweetReply();
        });
        if (!widget._fromHot) {
          TweetReply newReply = TweetReply.fromJson(result.data);
          if (newReply != null) {
            if (newReply.type == 1) {
              // 设置到直接回复
              setState(() {
                widget._tweet.replyCount++;
                if (tweet.dirReplies == null) {
                  tweet.dirReplies = List();
                }
                tweet.dirReplies.add(newReply);
              });
            } else {
              // 子回复
              int parentId = newReply.parentId;
              TweetReply tr2 = tweet.dirReplies.where((dirReply) => dirReply.id == parentId).first;
              setState(() {
                widget._tweet.replyCount++;
                if (tr2.children == null) {
                  tr2.children = List();
                }
                tr2.children.add(newReply);
              });
            }
          } else {
            ToastUtil.showToast(
              context,
              '回复失败，请稍后重试',
              gravity: ToastGravity.CENTER,
            );
          }
        }
      } else {
        ToastUtil.showToast(
          context,
          '回复失败，请稍后重试',
          gravity: ToastGravity.CENTER,
        );
      }
    });
  }

  _showDeleteBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SimpleConfirmBottomSheet(
          onTapDelete: () async {
            Utils.showDefaultLoading(this.myContext);
            Result r = await TweetApi.deleteAccountTweets(Application.getAccountId, widget._tweet.id);
            NavigatorUtils.goBack(this.myContext);
            if (r == null) {
              ToastUtil.showToast(this.myContext, '服务错误');
            } else {
              if (r.isSuccess) {
                Provider.of<TweetProvider>(this.myContext).delete(widget._tweet.id);
                ToastUtil.showToast(this.myContext, '删除成功');
                NavigatorUtils.goBack(this.myContext);
                if (widget.onDelete != null) {
                  widget.onDelete(widget._tweet.id);
                }
              } else {
                ToastUtil.showToast(this.myContext, '用户身份验证失败');
              }
            }
          },
        );
      },
    );
  }

  _showShieldedBottomSheet() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SimpleConfirmBottomSheet(
            tip: "您确认屏蔽此条内容，屏蔽后我们将会减少类似推荐",
            onTapDelete: () async {
              Utils.showDefaultLoading(Application.context);
              List<String> unlikeList = SpUtil.getStringList(SharedConstant.MY_UN_LIKED, defValue: List());
              if (unlikeList == null) {
                unlikeList = List();
              }
              unlikeList.add(widget._tweet.id.toString());
              await SpUtil.putStringList(SharedConstant.MY_UN_LIKED, unlikeList);

              final _tweetProvider = Provider.of<TweetProvider>(Application.context);
              _tweetProvider.delete(widget._tweet.id);
              NavigatorUtils.goBack(Application.context);
              ToastUtil.showToast(Application.context, '屏蔽成功');
              NavigatorUtils.goBack(Application.context);
            });
      },
    );
  }

  _showShieldedAccountBottomSheet() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SimpleConfirmBottomSheet(
            tip: "您确认屏蔽此用户，屏蔽后此用户的内容将对您不可见",
            onTapDelete: () async {
              Utils.showDefaultLoading(Application.context);
              Result r = await UnlikeAPI.unlikeAccount(widget._tweet.account.id.toString());
              NavigatorUtils.goBack(Application.context);
              if (r == null) {
                ToastUtil.showToast(Application.context, TextConstant.TEXT_SERVICE_ERROR);
              } else {
                if (r.isSuccess) {
                  final _tweetProvider = Provider.of<TweetProvider>(Application.context);
                  _tweetProvider.delete(widget._tweet.id);
                  NavigatorUtils.goBack(Application.context);
                } else {
                  ToastUtil.showToast(Application.context, "用户屏蔽失败");
                }
              }
            });
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
