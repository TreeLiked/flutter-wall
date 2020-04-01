import 'package:flustars/flustars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/api/unlike.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/component/bottom_sheet_confirm.dart';
import 'package:iap_app/component/simgple_tag.dart';
import 'package:iap_app/component/tweet/tweet_image_wrapper.dart';
import 'package:iap_app/component/tweet_delete_bottom_sheet.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/page/common/report_page.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/account_util.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart' as prefix0;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../application.dart';

class TweetDetail extends StatefulWidget {
  BaseTweet _tweet;
  final int hotRank;
  final bool accountMore;

  int tweetId;
  bool _fromHot = false;

  TweetDetail(this._tweet, {this.tweetId, this.hotRank = -1, this.accountMore = false}) {
    if (this.hotRank > 0) {
      _fromHot = true;
    }
  }

//  TweetDetail({this.tweetId, this.hotRank = -1});

  @override
  State<StatefulWidget> createState() {
    print('TweetDetail create state');
    return TweetDetailState();
  }
}

class TweetDetailState extends State<TweetDetail> {
  double sw;

  Future _getPraiseTask;
  Future _getReplyTask;

  List<Account> praiseAccounts = [];
  List<TweetReply> replies = [];

  // 回复相关
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();
  double _replyContainerHeight = 0;
  TweetReply curReply = TweetReply();
  String _hintText = "评论";

  bool isDark = false;

  TweetDetailState() {
    curReply.anonymous = false;
    print('TweetDETAIL state construct');
  }

  TextStyle _replyBodyStyle;

  @override
  void initState() {
    super.initState();

    _fetchTweetIfNullAndFetchExtra();
  }

  _fetchTweetIfNullAndFetchExtra() async {
    if (widget._tweet == null) {
      BaseTweet bt = await TweetApi.queryTweetById(widget.tweetId);
      if (bt == null) {
        ToastUtil.showToast(context, '内容不存在或已经被删除');
        NavigatorUtils.goBack(context);
        return;
      }
      setState(() {
        widget._tweet = bt;
      });
      _getReplyTask = getTweetReply();
      _getPraiseTask = getTweetPraises();
    } else {
      _getReplyTask = getTweetReply();
      _getPraiseTask = getTweetPraises();
    }
  }

  Future<List<TweetReply>> getTweetReply() async {
    List<TweetReply> replies = await TweetApi.queryTweetReply(widget._tweet.id, true);
    if (replies == null) {
      ToastUtil.showToast(context, TextConstant.TEXT_SERVICE_ERROR);
      return [];
    } else {
      _replyBodyStyle =
          MyDefaultTextStyle.getMainTextBodyStyle(isDark, fontSize: SizeConstant.TWEET_REPLY_FONT_SIZE);
      return replies;
    }
  }

  Future<List<Account>> getTweetPraises() async {
    return await TweetApi.queryTweetPraise(widget._tweet.id);
  }

  Future refresh() async {
    setState(() {
      _getReplyTask = getTweetReply();
    });
  }

  void updateListData(List data, int type) {
    if (data != null) {
      if (type == 1) {
        // setState(() {
        this.praiseAccounts = data;
        // });
      } else if (type == 2) {
        // setState(() {
        this.replies = data;
        // });
      }
    }
  }

  Widget _spaceRow() {
    BaseTweet t = widget._tweet;
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // 头像
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
                onTap: () => _forwardAccountProfile(true, t.account),
                child: AccountAvatar(
                    avatarUrl: !t.anonymous ? t.account.avatarUrl : PathConstant.ANONYMOUS_PROFILE,
                    size: SizeConstant.TWEET_PROFILE_SIZE,
                    cache: true,
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
                          ..onTap = () => _forwardAccountProfile(true, t.account),
                        text: t.anonymous ? TextConstant.TWEET_ANONYMOUS_NICK : (t.account.nick ?? ""),
                        style: MyDefaultTextStyle.getTweetHeadNickStyle(
                            context, SizeConstant.TWEET_NICK_SIZE + 3,
                            anonymous: t.anonymous)),
                  ])),
              Text(TimeUtil.getShortTime(widget._tweet.sentTime),
                  style: TextStyle(fontSize: SizeConstant.TWEET_TIME_SIZE, color: Colors.grey))
            ],
          ),
        )
      ],
    );
  }

  Widget _viewContainer() {
    const Radius temp = Radius.circular(7.0);
    bool unKnownType = tweetTypeMap[widget._tweet.type] == null;
    if (unKnownType) {
      widget._tweet.type = "OTHER";
    }
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Text(
                  "${widget._tweet.views} 次浏览",
                  style: MyDefaultTextStyle.getTweetTimeStyle(context, fontSize: Dimens.font_sp13),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                      color: (!ThemeUtils.isDark(context)
                              ? tweetTypeMap[widget._tweet.type].color
                              : tweetTypeMap[widget._tweet.type].color.withAlpha(100)) ??
                          Colors.blueAccent,
                      borderRadius: BorderRadius.only(
                        topLeft: temp,
                        topRight: temp,
                        bottomLeft: temp,
                        // bottomRight: temp,
                      )),
                  child: Text(
                      '# ' + (!unKnownType
                          ? tweetTypeMap[widget._tweet.type].zhTag
                          : TextConstant.TEXT_UN_CATCH_TWEET_TYPE),
                      style: MyDefaultTextStyle.getTweetTypeStyle(context)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _bodyContainer() {
    if (StringUtil.isEmpty(widget._tweet.body)) {
      return Container(height: 0);
    }
    return Wrap(
      children: <Widget>[
        Row(children: <Widget>[
          Expanded(
              child: Text(widget._tweet.body,
                  softWrap: true,
                  textAlign: TextAlign.left,
                  style: MyDefaultTextStyle.getMainTextBodyStyle(isDark)))
        ]),
        Gaps.vGap8
      ],
    );
  }

  Widget _replyBodyContainer(String body) {
    return GestureDetector(
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return BottomSheetConfirm(
                  title: '评论操作',
                  optChoice: '举报',
                  optColor: Colors.redAccent,
                  onTapOpt: () => NavigatorUtils.goReportPage(
                      context, ReportPage.REPORT_TWEET_REPLY, widget._tweet.id.toString(), "评论举报"));
            },
          );
        },
        child: Container(
            padding: const EdgeInsets.only(top: 1.0),
            child: Text(body ?? "", softWrap: true, textAlign: TextAlign.left, style: _replyBodyStyle)));
  }

  List<Widget> _getReplyList() {
    List<Widget> list = new List();

    int displayCnt = 0;
    for (var dirTr in replies) {
      if (displayCnt == GlobalConfig.MAX_DISPLAY_REPLY) {
        break;
      }
      list.add(replyWrapContainer(dirTr, false, dirTr.id));
      if (!CollectionUtil.isListEmpty(dirTr.children)) {
        dirTr.children.forEach((tr) {
          list.add(replyWrapContainer(tr, true, dirTr.id));
          displayCnt++;
        });
      }
    }
    return list;
  }

  Widget _getPraiseList() {
    List<InlineSpan> spans = List();

    if (!CollectionUtil.isListEmpty(praiseAccounts)) {
      for (int i = 0; i < praiseAccounts.length && i < GlobalConfig.MAX_DISPLAY_PRAISE; i++) {
        Account account = praiseAccounts[i];
        spans.add(TextSpan(
            text: "${account.nick}" + (i != praiseAccounts.length - 1 ? '、' : ' '),
            style: MyDefaultTextStyle.getTweetNickStyle(context, 13, bold: false),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
//                 goAccountDetail();
                _forwardAccountProfile(false, account);
              }));
      }

      if (praiseAccounts.length > GlobalConfig.MAX_DISPLAY_PRAISE_DETAIL) {
        int diff = praiseAccounts.length - GlobalConfig.MAX_DISPLAY_PRAISE;
        spans.add(TextSpan(
          text: " 等共$diff人觉得很赞",
          style: TextStyle(fontSize: 13),
        ));
      }
    }

    return RichText(text: TextSpan(children: spans), softWrap: true);
  }

  Widget _textTitleRow(String title, {String subTitle = '', Widget tail}) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Row(
        children: <Widget>[
          RichText(
            text: TextSpan(children: [
              TextSpan(text: title + '  ', style: TextStyle(color: Colors.grey, fontSize: 14)),
              TextSpan(text: subTitle, style: TextStyle(color: ColorConstant.TWEET_TIME_COLOR, fontSize: 13)),
            ]),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[Container(padding: EdgeInsets.only(right: 10), child: tail)],
            ),
          )
        ],
      ),
    );
  }

  Widget _templateWidget(Widget titleWidget, Widget bodyWidget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[titleWidget, bodyWidget],
    );
  }

  Widget _replyTitleContainer() {
    Widget reply = GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: prefix0.LoadAssetIcon(PathConstant.ICON_COMMENT_ICON, width: 20, height: 20),
        onTap: () {
          curReply.parentId = widget._tweet.id;
          curReply.type = 1;
          curReply.tarAccount = widget._tweet.account;
          curReply.anonymous = false;
          showReplyContainer("", widget._tweet.account.id, false);
        });

    if (!widget._tweet.enableReply) {
      return _textTitleRow('评论关闭');
    }
    if (CollectionUtil.isListEmpty(widget._tweet.dirReplies)) {
      return _textTitleRow('暂无评论', tail: reply);
    } else {
      return _textTitleRow('评论', subTitle: '${widget._tweet.replyCount}', tail: reply);
    }
  }

  Widget _praiseTitleContainer() {
    Widget wgt = GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: prefix0.LoadAssetIcon(
        widget._tweet.loved ? PathConstant.ICON_PRAISE_ICON_PRAISE : PathConstant.ICON_PRAISE_ICON_UN_PRAISE,
        width: 20,
        height: 20,
      ),
      onTap: () {
        updatePraise(widget._tweet);
      },
    );

    if (widget._tweet.praise <= 0) {
      return _textTitleRow('快来第一个点赞吧', tail: wgt);
    } else {
      return _textTitleRow('点赞', subTitle: '${widget._tweet.praise}', tail: wgt);
    }
  }

  Widget _praiseFutureContainer() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: FutureBuilder<List<Account>>(
          builder: (context, AsyncSnapshot<List<Account>> async) {
            //在这里根据快照的状态，返回相应的widget
            if (async.connectionState == ConnectionState.active ||
                async.connectionState == ConnectionState.waiting) {
              return new Center(
                  child: new SpinKitThreeBounce(
                color: Colors.lightBlue,
                size: 18,
              ));
            }
            if (async.connectionState == ConnectionState.done) {
              if (async.hasError) {
                print("${async.error}");
                return new Center(
                  child: new Text("拉取点赞失败"),
                );
              } else if (async.hasData) {
                List<Account> list = async.data;
                updateListData(list, 1);
                return Wrap(
                  alignment: WrapAlignment.start,
                  children: [_getPraiseList()],
                );
              }
            }
            return Container();
          },
          future: _getPraiseTask),
    );
    // list.addAll(_getReplyList());
  }

  Widget _replyFutureContainer() {
    if (!widget._tweet.enableReply) {
      return Container(height: 0);
    }
    return Container(
      child: FutureBuilder<List<TweetReply>>(
          builder: (context, AsyncSnapshot<List<TweetReply>> async) {
            //在这里根据快照的状态，返回相应的widget
            if (async.connectionState == ConnectionState.active ||
                async.connectionState == ConnectionState.waiting) {
              return new Center(
                child: new SpinKitThreeBounce(
                  color: Colors.lightBlue,
                  size: 18,
                ),
              );
            }
            if (async.connectionState == ConnectionState.done) {
              if (async.hasError) {
                return _textTitleRow('拉取回复失败');
              } else if (async.hasData) {
                List<TweetReply> list = async.data;
                updateListData(list, 2);
                return Column(
                  children: _getReplyList(),
                );
              }
            }
            return Container();
          },
          future: _getReplyTask),
    );
    // list.addAll(_getReplyList());
  }

  void updatePraise(BaseTweet tweet) {
    if (tweet.latestPraise == null) {
      tweet.latestPraise = List();
    }
    setState(() {
      tweet.loved = !tweet.loved;
      if (tweet.loved) {
        Utils.showFavoriteAnimation(context);
        Future.delayed(Duration(seconds: 2)).then((_) => Navigator.pop(context));
        tweet.praise++;
        tweet.latestPraise.insert(0, Application.getAccount);
        if (praiseAccounts == null) {
          praiseAccounts = List();
        }
        praiseAccounts.insert(0, Application.getAccount);
      } else {
        tweet.praise--;
        tweet.latestPraise.removeWhere((account) => account.id == Application.getAccountId);
        if (!CollectionUtil.isListEmpty(praiseAccounts)) {
          praiseAccounts.removeWhere((account) => account.id == Application.getAccountId);
        }
      }
      TweetApi.operateTweet(tweet.id, 'PRAISE', tweet.loved);
    });
  }

  /// 头像url, 是否此条评论匿名, 回复的账户
  Widget _leftContainer(String headUrl, bool anonymous, Account replyAccount) {
    bool authorReply = replyAccount.id == widget._tweet.account.id;
    double size = SizeConstant.TWEET_PROFILE_SIZE - 5;
    bool forbiddenJump = (widget._tweet.anonymous && authorReply) || anonymous;
    return GestureDetector(
      child: Container(
//        alignment: Alignment.centerLeft,
          padding: EdgeInsets.fromLTRB(0, 5, 5, 0),
          child: AccountAvatar(
            cache: true,
            avatarUrl:
                forbiddenJump ? PathConstant.ANONYMOUS_PROFILE : headUrl ?? PathConstant.DEFAULT_PROFILE,
            size: size,
          )),
      onTap:
          !forbiddenJump ? () => _forwardAccountProfile(false, replyAccount, forceForbid: anonymous) : null,
    );
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

  Widget _headContainer(TweetReply reply) {
    BaseTweet bt = widget._tweet;

    bool tweetAnonymous = bt.anonymous;
    bool replyAnonymous = reply.anonymous;

    bool isAuthorReply = reply.account.id == bt.account.id;
    bool directReply = reply.type == 1;

    bool authorReplyWithTweetAnon = isAuthorReply && tweetAnonymous;
    bool targetAuthor = reply.tarAccount == null || reply.tarAccount.id == bt.account.id;
    bool targetAuthorAndTweetAnon = tweetAnonymous && targetAuthor;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      runAlignment: WrapAlignment.center,
      children: <Widget>[
        RichText(
          softWrap: true,
          text: TextSpan(children: [
            replyAnonymous || !isAuthorReply || directReply
                ? TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // 如果 回复匿名 || （推文匿名 && 作者的回复）
                        if (replyAnonymous || authorReplyWithTweetAnon) {
                          return;
                        }
                        _forwardAccountProfile(false, reply.account);
                      },
                    text: replyAnonymous
                        ? TextConstant.TWEET_ANONYMOUS_REPLY_NICK
                        : authorReplyWithTweetAnon ? "" : reply.account.nick,
                    style: replyAnonymous
                        ? MyDefaultTextStyle.getTweetReplyAnonymousNickStyle(
                            context, SizeConstant.TWEET_REPLY_FONT_SIZE)
                        : MyDefaultTextStyle.getTweetNickStyle(context, SizeConstant.TWEET_REPLY_FONT_SIZE,
                            bold: false))
                : WidgetSpan(
                    child: SimpleTag(
                    '作者',
                    round: false,
                    bgColor: Colours.app_main.withAlpha(200),
                    textColor: Colors.white,
                    verticalPadding: 0,
                  )),
            !replyAnonymous && directReply && isAuthorReply
                ? WidgetSpan(
                    child: SimpleTag(
                    '作者',
                    round: false,
                    bgColor: Colours.app_main.withAlpha(200),
                    textColor: Colors.white,
                    verticalPadding: 0,
                    leftMargin: 5,
                  ))
                : TextSpan(text: ''),
            TextSpan(
                text: reply.type == 1 || reply.tarAccount == null ? '' : ' 回复 ',
                style: TextStyle(
                    fontSize: SizeConstant.TWEET_REPLY_FONT_SIZE - 1,
                    color: ColorConstant.getTweetTimeColor(context))),
            TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    if (!targetAuthorAndTweetAnon) {
                      _forwardAccountProfile(false, reply.tarAccount);
                    }
                  },
                text: directReply || reply.tarAccount == null
                    ? ''
                    : (targetAuthorAndTweetAnon ? TextConstant.TWEET_AUTHOR_TEXT : reply.tarAccount.nick),
                style: targetAuthorAndTweetAnon
                    ? MyDefaultTextStyle.getTweetReplyAnonymousNickStyle(
                        context, SizeConstant.TWEET_REPLY_FONT_SIZE)
                    : MyDefaultTextStyle.getTweetNickStyle(context, SizeConstant.TWEET_REPLY_FONT_SIZE,
                        bold: false))
          ]),
        ),
      ],
    );
  }

  Widget replyWrapContainer(TweetReply reply, bool subDir, int parentId) {
    String tweetAccountId = widget._tweet.account.id;
    // 推文是否匿名
    bool tweetAnonymous = widget._tweet.anonymous;
    // 是否作者回复
    bool authorReply = reply.account.id == tweetAccountId;
    // 是否此条评论匿名
    bool thisReplyAnonymous = reply.anonymous;

    Widget wd = GestureDetector(
        behavior: HitTestBehavior.opaque,
        // 这条评论不是匿名回复，都可以回复这条评论
        onTap: !thisReplyAnonymous
            ? () {
                curReply.parentId = parentId;
                curReply.type = 2;
                curReply.tarAccount = Account.fromId(reply.account.id);
                if (tweetAnonymous && authorReply) {
                  // 推文匿名 && 回复 => 推文作者
                  showReplyContainer(TextConstant.TWEET_AUTHOR_TEXT, reply.account.id, false);
                } else {
                  showReplyContainer(
                      AccountUtil.getNickFromAccount(reply.account, false), reply.account.id, false);
                }
              }
            : () {
                ToastUtil.showToast(context, '匿名评论不可回复');
              },
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            subDir ? Container(width: 42) : Gaps.empty,
            _leftContainer(reply.account.avatarUrl, thisReplyAnonymous, reply.account),
            Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.only(right: 5, left: 2, top: 5),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    _headContainer(reply),
                    _replyBodyContainer(reply.body),
                    Row(children: <Widget>[
                      Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            TimeUtil.getShortTime(reply.sentTime),
                            style: TextStyle(
                                fontSize: SizeConstant.TWEET_TIME_SIZE,
                                color: ColorConstant.getTweetTimeColor(context)),
                          )),
                    ]),
                    Gaps.vGap4,
                    Divider()
                  ]),
                )),
          ],
        ));
    return wd;
  }

  @override
  Widget build(BuildContext context) {
    isDark = ThemeUtils.isDark(context);

    sw = Application.screenWidth;
    return Scaffold(
        backgroundColor: !isDark
            ? (widget._fromHot ? Color(0xffe9e9e9) : null)
            : (widget._fromHot ? Color(0xff2c2c2c) : Color(0xff303030)),
        body: Stack(
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanDown: (_) {
                hideReplyContainer();
              },
              child: NestedScrollView(
                // headerSliverBuilder: null,
                headerSliverBuilder: (context, innerBoxIsScrolled) =>
                    _sliverBuilder(context, innerBoxIsScrolled),

                body: widget._tweet != null
                    ? SingleChildScrollView(
                        child: Container(
                        decoration: BoxDecoration(
                            color: ThemeUtils.isDark(context)
                                ? Color(0xff303030)
                                : widget._fromHot ? Color(0xfff0f0f0) : null,
                            borderRadius: BorderRadius.all(Radius.circular(18))),
                        padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 50),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _spaceRow(),
                            Gaps.vGap10,
                            _bodyContainer(),
                            TweetMediaWrapper(widget._tweet.id, medias: widget._tweet.medias),
                            Gaps.vGap8,
                            _viewContainer(),
                            Gaps.vGap15,
                            Divider(),
                            _templateWidget(_praiseTitleContainer(), _praiseFutureContainer()),
                            _templateWidget(_replyTitleContainer(), _replyFutureContainer()),
                          ],
                        ),
                      ))
                    : Container(
                        alignment: Alignment.topCenter, child: prefix0.WidgetUtil.getLoadingAnimation()),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                  // height: ,
                  width: _replyContainerHeight,
                  decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.color,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
                  child: Row(
                    children: <Widget>[
                      AccountAvatar(
                        avatarUrl: Application.getAccount.avatarUrl,
                        cache: true,
                        size: 35,
                      ),
                      // ClipOval(
                      //   child: CachedNetworkImage(
                      //     imageUrl: Application.getAccount.avatarUrl,
                      //     width: 35,
                      //     height: 35,
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),
                      Expanded(
                        child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: TextField(
                              keyboardAppearance: Theme.of(context).brightness,
                              controller: _controller,
                              focusNode: _focusNode,
                              decoration: InputDecoration(
                                hintText: _hintText,
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  // color: ColorConstant.TWEET_TIME_COLOR,
                                  fontSize: SizeConstant.TWEET_TIME_SIZE - 1,
                                ),
                                suffixIcon: curReply != null && curReply.type == 1
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            curReply.anonymous = !curReply.anonymous;
                                            if (curReply.anonymous) {
                                              ToastUtil.showToast(context, '此条评论将匿名回复');
                                            }
                                          });
                                        },
                                        child: Icon(
                                          curReply.anonymous ? Icons.visibility_off : Icons.visibility,
                                          size: SizeConstant.TWEET_PROFILE_SIZE * 0.5,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : null,
                              ),
                              textInputAction: TextInputAction.send,
                              cursorColor: Colors.grey,
                              style: TextStyle(
                                fontSize: SizeConstant.TWEET_FONT_SIZE - 1,
                              ),
                              onSubmitted: (value) {
                                _sendReply(value);
                              },
                            )),
                      ),
                    ],
                  )),
            )
          ],
        ));
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
      items.add(BottomSheetItem(Icon(Icons.do_not_disturb_alt, color: Colors.deepOrange), '屏蔽此内容', () {
        Navigator.pop(context);
        _showShieldedBottomSheet();
      }));

      items.add(BottomSheetItem(Icon(Icons.do_not_disturb_on, color: Colors.red), '屏蔽此人', () {
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
            icon: Icon(Icons.more_horiz),
            onPressed: () {
              BottomSheetUtil.showBottomSheetView(context, _getSheetItems());
            },
          )
        ],
        backgroundColor: widget._fromHot
            ? (ThemeUtils.isDark(context) ? Color(0xff292929) : Color(0xfff0f0f0))
            : (ThemeUtils.isDark(context) ? Color(0xff303030) : null),
        centerTitle: true,
        //标题居中
        title: Text(
          '详情',
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

  @override
  bool get wantKeepAlive => true;

  void showReplyContainer(String destAccountNick, String destAccountId, bool dirAno) {
    print('show reply container');
    if (StringUtil.isEmpty(destAccountNick)) {
      setState(() {
        _hintText = "评论";
        _replyContainerHeight = MediaQuery.of(context).size.width;
      });
    } else {
      setState(() {
        _hintText = "回复 $destAccountNick";
        _replyContainerHeight = MediaQuery.of(context).size.width;
      });
    }
    // setState(() {
    //   // curReply = tr;
    //   // this.destAccountId = destAccountId;
    // });
    _focusNode.requestFocus();
  }

  void hideReplyContainer() {
    if (_replyContainerHeight != 0) {
      setState(() {
        _replyContainerHeight = 0;
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
            Utils.showDefaultLoading(context);
            Result r = await TweetApi.deleteAccountTweets(Application.getAccountId, widget._tweet.id);
            NavigatorUtils.goBack(context);
            if (r == null) {
              ToastUtil.showToast(context, '服务错误');
            } else {
              if (r.isSuccess) {
                ToastUtil.showToast(context, '删除成功');
                NavigatorUtils.goBack(context);
                Provider.of<TweetProvider>(context).delete(widget._tweet.id);
              } else {
                ToastUtil.showToast(context, '用户身份验证失败');
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
}
