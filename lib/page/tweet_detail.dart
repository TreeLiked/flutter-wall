import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/component/tweet/tweet_image_wrapper.dart';
import 'package:iap_app/component/tweet_delete_bottom_sheet.dart';
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
import 'package:iap_app/provider/tweet_provider.dart';
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
import 'package:iap_app/util/widget_util.dart';
import 'package:provider/provider.dart';

import '../application.dart';

class TweetDetail extends StatefulWidget {
  final BaseTweet _tweet;
  final int hotRank;
  bool _fromHot = false;

  TweetDetail(this._tweet, {this.hotRank = -1}) {
    if (this.hotRank > 0) {
      _fromHot = true;
    }
  }

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

  @override
  void initState() {
    super.initState();
    _getReplyTask = getTweetReply();
    _getPraiseTask = getTweetPraises();
  }

  Future<List<TweetReply>> getTweetReply() async {
    return await TweetApi.quertTweetReply(widget._tweet.id, true);
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
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // 头像
        GestureDetector(
            onTap: () => _forwardAccountProfile(true, widget._tweet.account),
            child: AccountAvatar(
                avatarUrl: !widget._tweet.anonymous
                    ? widget._tweet.account.avatarUrl
                    : PathConstant.ANONYMOUS_PROFILE,
                size: SizeConstant.TWEET_PROFILE_SIZE + 1,
                whitePadding: false)),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 8.0),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              children: <Widget>[
                Container(
                  // padding: EdgeInsets.only(bottom: 2),
                  child: RichText(
                    softWrap: true,
                    text: TextSpan(children: [
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // goAccountDetail();
                              _forwardAccountProfile(true, widget._tweet.account);
                            },
                          text: widget._tweet.account.nick,
                          style: MyDefaultTextStyle.getTweetHeadNickStyle(
                              context, SizeConstant.TWEET_NICK_SIZE,
                              anonymous: widget._tweet.anonymous)),
                      TextSpan(
                          text: " 发表于 " + TimeUtil.getShortTime(widget._tweet.gmtCreated),
                          style: TextStyle(fontSize: SizeConstant.TWEET_TIME_SIZE, color: Colors.grey))
                    ]),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _viewContainer() {
    const Radius temp = Radius.circular(7.0);
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
                  child: Text('# ' + tweetTypeMap[widget._tweet.type].zhTag,
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
                  style: MyDefaultTextStyle.getTweetBodyStyle(isDark)))
        ]),
        Gaps.vGap8
      ],
    );
  }

  Widget _replyBodyContainer(String body) {
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: Wrap(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: Text(body,
                      softWrap: true,
                      textAlign: TextAlign.left,
                      style: MyDefaultTextStyle.getTweetBodyStyle(isDark,
                          fontSize: SizeConstant.TWEET_REPLY_FONT_SIZE)))
            ],
          ),
        ],
      ),
    );
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
                _forwardAccountProfile(false, widget._tweet.account);
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
        child: LoadAssetIcon(PathConstant.ICON_COMMENT_ICON, width: 20, height: 20),
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
      child: LoadAssetIcon(
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
                  color: Colors.lightGreen,
                  size: 18,
                ),
              );
            }
            if (async.connectionState == ConnectionState.done) {
              if (async.hasError) {
                return new Center(
                  child: new Text("${async.error}"),
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
                  color: Colors.lightGreen,
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

  Widget _leftContainer(String headUrl, bool sub, bool anonymous, Account replyAccount,
      {bool isAuthor = false}) {
    double size = SizeConstant.TWEET_PROFILE_SIZE - 5;
    return GestureDetector(
      child: Container(
          padding: EdgeInsets.fromLTRB(0, 5, 5, 0),
          child: AccountAvatar(
            avatarUrl:
                (widget._tweet.anonymous && isAuthor || anonymous) ? PathConstant.ANONYMOUS_PROFILE : headUrl,
            size: size,
          )),
      onTap: () => _forwardAccountProfile(false, replyAccount, forceForbid: anonymous),
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
    bool authorReplyWithAnonymous = (reply.account.id == bt.account.id) && bt.anonymous;
    bool replyAuthorWithAnonymous =
        (reply.tarAccount != null) && (reply.tarAccount.id == bt.account.id) && bt.anonymous;

    bool dirReplyAnonymous = (reply.type == 1 && reply.anonymous);
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(children: [
            TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    if (!reply.anonymous) {
                      _forwardAccountProfile(false, reply.account);
                    }
                  },
                text: authorReplyWithAnonymous
                    ? TextConstant.TWEET_AUTHOR_TEXT
                    : dirReplyAnonymous ? TextConstant.TWEET_ANONYMOUS_REPLY_NICK : reply.account.nick,
                style: authorReplyWithAnonymous
                    ? MyDefaultTextStyle.getTweetReplyAnonymousNickStyle(
                        context, SizeConstant.TWEET_FONT_SIZE - 2)
                    : MyDefaultTextStyle.getTweetNickStyle(context, SizeConstant.TWEET_FONT_SIZE - 2,
                        bold: false)),
            TextSpan(
                text: reply.type == 1 || reply.tarAccount == null ? '' : ' 回复 ',
                style: TextStyle(
                    fontSize: SizeConstant.TWEET_TIME_SIZE, color: ColorConstant.getTweetTimeColor(context))),
            TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    if (!reply.anonymous && !replyAuthorWithAnonymous) {
                      _forwardAccountProfile(false, reply.tarAccount);
                    }
                  },
                text: reply.type == 1 || reply.tarAccount == null
                    ? ''
                    : (replyAuthorWithAnonymous ? TextConstant.TWEET_AUTHOR_TEXT : reply.tarAccount.nick),
                style: replyAuthorWithAnonymous
                    ? MyDefaultTextStyle.getTweetReplyAnonymousNickStyle(
                        context, SizeConstant.TWEET_FONT_SIZE - 2)
                    : MyDefaultTextStyle.getTweetNickStyle(context, SizeConstant.TWEET_FONT_SIZE - 2,
                        bold: false))
          ]),
        ),
        // Expanded(
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: <Widget>[
        //       Text(time,
        //           style: TextStyle(
        //             fontSize: SizeConstant.TWEET_TIME_SIZE - 1,
        //             color: GlobalConfig.tweetTimeColor,
        //           ))
        //     ],
        //   ),
        // )
      ],
    );
  }

  Widget replyWrapContainer(TweetReply reply, bool subDir, int parentId) {
    bool dirReplyAnonymous = (reply.type == 1 && reply.anonymous);
    Widget wd = GestureDetector(
        onTap: !dirReplyAnonymous
            ? () {
                curReply.parentId = parentId;
                curReply.type = 2;
                curReply.tarAccount = Account.fromId(reply.account.id);
                if (widget._tweet.anonymous && widget._tweet.account.id == reply.account.id) {
                  // 推文匿名 && 回复的是推文作者
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
            Padding(
              padding: EdgeInsets.only(left: subDir ? 10 : 0),
            ),
            _leftContainer(reply.account.avatarUrl, subDir, dirReplyAnonymous, reply.account,
                isAuthor: reply.account.id == widget._tweet.account.id),
            Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.only(right: 5, left: 2, top: 5),
                  child: Column(children: <Widget>[
                    _headContainer(reply),
                    _replyBodyContainer(reply.body),
                    Row(children: <Widget>[
                      Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            TimeUtil.getShortTime(reply.gmtCreated),
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

                body: SingleChildScrollView(
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
                      TweetImageWrapper(picUrls: widget._tweet.picUrls),
                      Gaps.vGap8,
                      _viewContainer(),
                      Gaps.vGap15,
                      Divider(),
                      // _loveContainer(),
                      _templateWidget(_praiseTitleContainer(), _praiseFutureContainer()),
                      _templateWidget(_replyTitleContainer(), _replyFutureContainer()),
                      // Divider(),

                      // _praiseContainer(),

                      // _replyFutureContainer(),
                      // Container(
                      //     height: widget.hotRank > 0
                      //         ? widget._tweet.dirReplies == null
                      //             ? 200
                      //             : (6 - widget._tweet.dirReplies.length * 60)
                      //         : 0)
                    ],
                  ),
                )),
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
    String accountId = Application.getAccountId;
    if (!StringUtil.isEmpty(accountId) && accountId == widget._tweet.account.id) {
      items.add(BottomSheetItem(Icon(Icons.delete, color: Colors.redAccent), '删除', () {
        Navigator.pop(context);
        _showDeleteBottomSheet();
      }));
    }
    items.add(BottomSheetItem(
        Icon(
          Icons.star,
          color: Color(0xffEE9A49),
        ),
        '收藏', () {
      ToastUtil.showToast(context, '收藏功能暂未开放');
      Navigator.pop(context);
    }));
    items.add(BottomSheetItem(
        Icon(
          Icons.warning,
          color: Colors.grey,
        ),
        '举报', () {
      ToastUtil.showToast(context, '举报成功');
      Navigator.pop(context);
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
          // style: TextStyle(color: widget._fromhot ? Colors.white : null),
        ),
        // title: InkWell(
        //     child: Row(
        //   children: <Widget>[
        //     Padding(
        //         padding: EdgeInsets.only(left: 0.0, right: 10.0),
        //         child: AccountAvatar(
        //           avatarUrl: widget._tweet.account.avatarUrl,
        //           size: SizeConstant.TWEET_PROFILE_SIZE - 5,
        //         )),
        //     Expanded(
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: <Widget>[
        //           SizedBox(height: 15.0),
        //           Text(
        //             widget._tweet.account.nick,
        //             style: TextStyle(
        //               fontWeight: FontWeight.bold,
        //               fontSize: 14,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ],
        // )),
        elevation: 0.4,
        floating: true,
        pinned: !widget._fromHot,
        snap: false,
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              // color: widget._fromhot ? Colors.white : null,
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
                                    fontSize: 15,
                                    color: ThemeUtils.isDark(context) ? Colors.grey : Colors.black)),
                            TextSpan(
                                text: '${widget.hotRank}  ',
                                style: TextStyle(
                                    fontSize: 17,
                                    color: widget.hotRank < 5 ? Colors.redAccent : Colors.white))
                          ])),
                          getFires(widget.hotRank),
                          // Text(
                          //   '当前热门榜单: No' + widget.hotRank.toString(),
                          //   style: TextStyle(color: Colors.white70),
                          // )
                        ],
                      ),
                    )),
              )
            : null,
        // flexibleSpace: widget._fromhot
        //     ? Container(
        //         height: 100,
        //         margin: EdgeInsets.only(top: ScreenUtil.statusBarHeight + 30),
        //         padding: EdgeInsets.only(bottom: 10),
        //         // padding: EdgeInsets.only(left: 20),
        //         // decoration: BoxDecoration(color: Colors.white),
        //         child: Align(
        //           alignment: Alignment.center,
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             crossAxisAlignment: CrossAxisAlignment.center,
        //             children: <Widget>[
        //               RichText(
        //                   text: TextSpan(children: [
        //                 TextSpan(
        //                     text: '当前热门榜：',
        //                     style: TextStyle(
        //                         fontSize: Dimens.font_sp16,
        //                         color: ThemeUtils.isDark(context)
        //                             ? Colors.grey
        //                             : Colors.black)),
        //                 TextSpan(
        //                     text: 'No. ',
        //                     style: TextStyle(
        //                         fontSize: 15,
        //                         color: ThemeUtils.isDark(context)
        //                             ? Colors.grey
        //                             : Colors.black)),
        //                 TextSpan(
        //                     text: '${widget.hotRank} ',
        //                     style: TextStyle(
        //                         fontSize: 17,
        //                         color: widget.hotRank < 5
        //                             ? Colors.redAccent
        //                             : Colors.white))
        //               ])),
        //               getFires(widget.hotRank),
        //               // Text(
        //               //   '当前热门榜单: No' + widget.hotRank.toString(),
        //               //   style: TextStyle(color: Colors.white70),
        //               // )
        //             ],
        //           ),
        //         ))
        //     : Container(
        //         height: 0,
        //       )),
      )
    ];
  }

  Widget getFires(int rank) {
    List<Widget> list = List();
    if (rank == 1) {
      list.add(Image.asset(
        PathConstant.ICON_CHAMPIN,
        width: SizeConstant.TWEET_HOT_RANK_ICON_SIZE,
        height: SizeConstant.TWEET_HOT_RANK_ICON_SIZE,
      ));
    } else {
      int count = 5 - rank;
      if (count >= 0) {
        for (int i = 0; i < count; i++) {
          list.add(Image.asset(
            PathConstant.ICON_FIRE,
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
              // 设置到��接回复
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
        return TweetDeleteBottomSheet(
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
}
