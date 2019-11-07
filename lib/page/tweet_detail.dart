import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/photo_wrap_item.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/account_util.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart';

import '../application.dart';

class TweetDetail extends StatefulWidget {
  final BaseTweet _tweet;
  final int hotRank;
  bool _fromhot = false;

  TweetDetail(this._tweet, {this.hotRank = -1}) {
    if (this.hotRank > 0) {
      _fromhot = true;
    }
  }
  @override
  State<StatefulWidget> createState() {
    print('TweetDetail create state');
    return TweetDetailState();
  }
}

class TweetDetailState extends State<TweetDetail>
    with AutomaticKeepAliveClientMixin {
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

  TweetDetailState() {
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
    return await TweetApi.quertTweetPraise(widget._tweet.id);
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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        // 头像
        Container(
          margin: EdgeInsets.only(right: 5),
          child: ClipOval(
            child: Image.network(
              // imageUrl:
              !widget._tweet.anonymous
                  ? widget._tweet.account.avatarUrl
                  : PathConstant.ANONYMOUS_PROFILE,
              width: SizeConstant.TWEET_PROFILE_SIZE - 1,
              height: SizeConstant.TWEET_PROFILE_SIZE - 1,
              fit: BoxFit.cover,
              repeat: ImageRepeat.noRepeat,
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: 10, left: 0),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(bottom: 2),
                  child: RichText(
                    softWrap: true,
                    text: TextSpan(children: [
                      TextSpan(
                          text: widget._tweet.account.nick,
                          style: MyDefaultTextStyle.getTweetHeadNickStyle(
                              SizeConstant.TWEET_NICK_SIZE,
                              anonymous: widget._tweet.anonymous)),
                      TextSpan(
                          text: " 发表于 " +
                              TimeUtil.getShortTime(widget._tweet.gmtCreated),
                          style: TextStyle(
                              fontSize: SizeConstant.TWEET_TIME_SIZE,
                              color: Colors.grey))
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
    const Radius temp = Radius.circular(8);
    return Container(
      padding: EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Text(
                  "${widget._tweet.views} 次浏览",
                  style: MyDefaultTextStyle.getTweetTimeStyle(13),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                  decoration: BoxDecoration(
                      color: tweetTypeMap[widget._tweet.type].color,
                      borderRadius: BorderRadius.only(
                        topLeft: temp,
                        topRight: temp,
                        bottomLeft: temp,
                        // bottomRight: temp,
                      )),
                  child: Text(
                    '# ' + tweetTypeMap[widget._tweet.type].zhTag,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _bodyContainer() {
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: Wrap(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget._tweet.body,
                  softWrap: true,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: GlobalConfig.TWEET_FONT_SIZE,
                      color: GlobalConfig.tweetBodyColor,
                      height: 1.5),
                ),
              )
            ],
          )
        ],
      ),
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
                child: Text(
                  body,
                  softWrap: true,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: GlobalConfig.TWEET_FONT_SIZE - 2,
                      color: GlobalConfig.tweetBodyColor,
                      height: 1.5),
                ),
              )
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
    spans.add(WidgetSpan(
        child: GestureDetector(
            onTap: () {
              updatePraise(widget._tweet);
            },
            child: Padding(
              padding: EdgeInsets.only(right: 2),
              child: Image.asset(
                // PathConstant.ICON_PRAISE_ICON_UNPRAISE,
                widget._tweet.loved
                    ? PathConstant.ICON_PRAISE_ICON_PRAISE
                    : PathConstant.ICON_PRAISE_ICON_UNPRAISE,
                width: 18,
                height: 18,
              ),
            ))));

    if (!CollectionUtil.isListEmpty(praiseAccounts)) {
      for (int i = 0;
          i < praiseAccounts.length && i < GlobalConfig.MAX_DISPLAY_PRAISE;
          i++) {
        Account account = praiseAccounts[i];
        spans.add(TextSpan(
            text: "${account.nick}" +
                (i != praiseAccounts.length - 1 ? '、' : ' '),
            style: MyDefaultTextStyle.getTweetNickStyle(13, bold: false),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // goAccountDetail();
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
              TextSpan(
                  text: title + '  ',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              TextSpan(
                  text: subTitle,
                  style: TextStyle(color: Colors.lightGreen, fontSize: 13)),
            ]),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(padding: EdgeInsets.only(right: 10), child: tail)
              ],
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
    Widget reply = WidgetUtil.getIcon(Icons.message, Colors.grey, click: true,
        callback: () {
      // 直接回复
      curReply.parentId = widget._tweet.id;
      curReply.type = 1;
      curReply.tarAccount = widget._tweet.account;
      showReplyContainer("", widget._tweet.account.id);
    });
    if (!widget._tweet.enableReply) {
      return _textTitleRow('评论关闭');
    }
    if (CollectionUtil.isListEmpty(widget._tweet.dirReplies)) {
      return _textTitleRow('暂无评论', tail: reply);
    } else {
      return _textTitleRow('评论',
          subTitle: '${widget._tweet.replyCount}', tail: reply);
    }
  }

  Widget _praiseTitleContainer() {
    Widget wgt = WidgetUtil.getAsset(
        widget._tweet.loved
            ? PathConstant.ICON_PRAISE_ICON_PRAISE
            : PathConstant.ICON_PRAISE_ICON_UNPRAISE,
        click: true, callback: () {
      updatePraise(widget._tweet);
    });

    if (widget._tweet.praise <= 0) {
      return _textTitleRow('快来第一个点赞吧', tail: wgt);
    } else {
      return _textTitleRow('点赞',
          subTitle: '${widget._tweet.praise}', tail: wgt);
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
              debugPrint("done-praise");
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
              debugPrint("done");
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
        tweet.praise++;
        tweet.latestPraise.insert(0, Application.getAccount);
        if (praiseAccounts == null) {
          praiseAccounts = List();
        }
        praiseAccounts.insert(0, Application.getAccount);
      } else {
        tweet.praise--;
        tweet.latestPraise
            .removeWhere((account) => account.id == Application.getAccount.id);
        if (!CollectionUtil.isListEmpty(praiseAccounts)) {
          praiseAccounts.removeWhere(
              (account) => account.id == Application.getAccount.id);
        }
      }
      TweetApi.operateTweet(tweet.id, 'PRAISE', tweet.loved);
    });
  }

  Widget _leftContainer(String headUrl, bool sub, {bool isAuthor = false}) {
    double size = SizeConstant.TWEET_PROFILE_SIZE - (sub ? 7 : 5);
    return Container(
      padding: EdgeInsets.fromLTRB(0, 5, 5, 0),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipOval(
            child: Image.network(
              widget._tweet.anonymous && isAuthor
                  ? PathConstant.ANONYMOUS_PROFILE
                  : headUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          )
        ],
      ),
    );
  }

  Widget _headContainer(TweetReply reply) {
    BaseTweet bt = widget._tweet;
    bool authorReplyWithAnonymous =
        (reply.account.id == bt.account.id) && bt.anonymous;
    bool replyAuthorWithAnonymous = (reply.tarAccount != null) &&
        (reply.tarAccount.id == bt.account.id) &&
        bt.anonymous;

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(children: [
            TextSpan(
                text: authorReplyWithAnonymous
                    ? TextConstant.TWEET_AUTHOR_TEXT
                    : reply.account.nick,
                style: authorReplyWithAnonymous
                    ? MyDefaultTextStyle.getTweetReplyAnonymousNickStyle(
                        SizeConstant.TWEET_FONT_SIZE - 2)
                    : MyDefaultTextStyle.getTweetNickStyle(
                        SizeConstant.TWEET_FONT_SIZE - 2,
                        bold: false)),
            TextSpan(
                text: reply.type == 1 || reply.tarAccount == null ? '' : ' 回复 ',
                style: MyDefaultTextStyle.getTweetTimeStyle(
                    SizeConstant.TWEET_TIME_SIZE)),
            TextSpan(
                text: reply.type == 1 || reply.tarAccount == null
                    ? ''
                    : (replyAuthorWithAnonymous
                        ? TextConstant.TWEET_AUTHOR_TEXT
                        : reply.tarAccount.nick),
                style: replyAuthorWithAnonymous
                    ? MyDefaultTextStyle.getTweetReplyAnonymousNickStyle(
                        SizeConstant.TWEET_FONT_SIZE - 2)
                    : MyDefaultTextStyle.getTweetNickStyle(
                        SizeConstant.TWEET_FONT_SIZE - 2,
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

  Widget _picContainer() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Wrap(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Wrap(
                    children: ((!CollectionUtil.isListEmpty(
                            widget._tweet.picUrls))
                        ? (widget._tweet.picUrls.length == 1
                            ? <Widget>[
                                _imgContainerSingle(widget._tweet.picUrls[0])
                              ]
                            : _handleMultiPics())
                        : <Widget>[])),
              )
            ],
          )
        ],
      ),
    );
  }

  List<Widget> _handleMultiPics() {
    List<String> picUrls = widget._tweet.picUrls;
    List<Widget> list = new List(picUrls.length);
    for (int i = 0; i < picUrls.length; i++) {
      list[i] = _imgContainer(picUrls[i], i, picUrls.length);
    }
    return list;
  }

  Widget _imgContainer(String url, int index, int totalSize) {
    // 减去空白边距
    double left = (sw - 30 - totalSize * 1);
    double perw;
    if (totalSize == 2 || totalSize == 4) {
      perw = left / 2;
    } else {
      perw = left / 3;
    }

    return Container(
        // %2 因为索引从0开始，3的倍数右边距设为0
        padding: EdgeInsets.only(right: 1, bottom: 1),
        width: perw,
        height: perw,
        child: GestureDetector(
          onTap: () {
            // List<PhotoWrapItem> items = widget._tweet.picUrls
            //     .map((f) => PhotoWrapItem(index: index, url: f))
            //     .toList();
            Utils.openPhotoView(context, widget._tweet.picUrls, index);
          },
          child: CachedNetworkImage(
            imageUrl: url + "?x-oss-process=style/image_thumbnail",
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              padding: EdgeInsets.all(20),
              child: Image.asset(PathConstant.LOADING_GIF),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ));
  }

  Widget _imgContainerSingle(String url) {
    return GestureDetector(
        onTap: () => Utils.openPhotoView(context, widget._tweet.picUrls, 0),
        child: Container(
            child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: (sw - 30) * 0.9),
          child: CachedNetworkImage(
            imageUrl: url + "?x-oss-process=style/image_thumbnail",
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              padding: EdgeInsets.all(20),
              child: Image.asset(PathConstant.LOADING_GIF),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        )));
  }

  Widget replyWrapContainer(TweetReply reply, bool subDir, int parentId) {
    Widget wd = GestureDetector(
        onTap: () {
          curReply.parentId = parentId;
          curReply.type = 2;
          curReply.tarAccount = Account.fromId(reply.account.id);
          if (widget._tweet.anonymous &&
              widget._tweet.account.id == reply.account.id) {
            // 推文匿名 && 回复的是推文作者
            showReplyContainer(
                TextConstant.TWEET_AUTHOR_TEXT, reply.account.id);
          } else {
            showReplyContainer(
                AccountUtil.getNickFromAccount(reply.account, false),
                reply.account.id);
          }
        },
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: subDir ? 15 : 0),
            ),
            _leftContainer(reply.account.avatarUrl, subDir,
                isAuthor: reply.account.id == widget._tweet.account.id),
            Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(right: 5, left: 2, top: 5),
                  child: Column(children: <Widget>[
                    _headContainer(reply),
                    _replyBodyContainer(reply.body),
                    Row(children: <Widget>[
                      Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            TimeUtil.getShortTime(reply.gmtCreated),
                            style: MyDefaultTextStyle.getTweetTimeStyle(12),
                          )),
                    ]),
                    Divider()
                  ]),
                )),
          ],
        ));
    return wd;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    sw = MediaQuery.of(context).size.width;

    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanDown: (_) {
          hideReplyContainer();
        },
        child: Scaffold(
            backgroundColor:
                widget.hotRank != -1 ? Color(0xffF5F5F5) : Colors.white,
            // backgroundColor: Colors.white,
            body: Stack(
              children: <Widget>[
                NestedScrollView(
                  // headerSliverBuilder: null,
                  headerSliverBuilder: (context, innerBoxIsScrolled) =>
                      _sliverBuilder(context, innerBoxIsScrolled),

                  body: SingleChildScrollView(
                      child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    padding: EdgeInsets.only(
                        top: 10, left: 15, right: 15, bottom: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _spaceRow(),
                        _bodyContainer(),
                        _picContainer(),
                        _viewContainer(),
                        Divider(),
                        // _loveContainer(),
                        _templateWidget(
                            _praiseTitleContainer(), _praiseFutureContainer()),
                        _templateWidget(
                            _replyTitleContainer(), _replyFutureContainer()),
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
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                      // height: ,
                      width: _replyContainerHeight,
                      decoration: BoxDecoration(
                        color: Color(0xfff2f2f2),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
                      child: Row(
                        children: <Widget>[
                          ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: Application.getAccount.avatarUrl,
                              width: 35,
                              height: 35,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: TextField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  decoration: InputDecoration(
                                      hintText: _hintText,
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        color: ColorConstant.TWEET_TIME_COLOR,
                                        fontSize:
                                            SizeConstant.TWEET_TIME_SIZE - 1,
                                      )),
                                  textInputAction: TextInputAction.send,
                                  cursorColor: Colors.grey,
                                  style: TextStyle(
                                      fontSize:
                                          SizeConstant.TWEET_FONT_SIZE - 1,
                                      color:
                                          ColorConstant.TWEET_REPLY_FONT_COLOR),
                                  onSubmitted: (value) {
                                    _sendReply(value);
                                  },
                                )),
                          ),
                        ],
                      )),
                )
              ],
            )));
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
          backgroundColor: widget._fromhot ? Color(0xffCD5555) : Colors.white,
          centerTitle: true, //标题居中
          title: Text('详情',
              style: TextStyle(
                  color: widget._fromhot ? Colors.white : Colors.black)),
          elevation: 0.5,
          expandedHeight: widget._fromhot
              ? ScreenUtil().setHeight(180) + ScreenUtil.statusBarHeight
              : 0,
          floating: true,
          pinned: true,
          snap: false,
          leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back,
                color: widget._fromhot ? Colors.white : Colors.black,
              )),
          flexibleSpace: widget.hotRank != -1
              ? Container(
                  height: 100,
                  margin: EdgeInsets.only(top: ScreenUtil.statusBarHeight + 50),
                  padding: EdgeInsets.only(bottom: 20),
                  // padding: EdgeInsets.only(left: 20),
                  // decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: '当前热门榜：',
                            style:
                                TextStyle(color: Colors.white, fontSize: 15)),
                        TextSpan(
                            text: 'No. ',
                            style:
                                TextStyle(fontSize: 15, color: Colors.white)),
                        TextSpan(
                            text: '${widget.hotRank} ',
                            style: TextStyle(
                                fontSize: 17,
                                color: widget.hotRank < 5
                                    ? Colors.redAccent
                                    : Colors.white))
                      ])),
                      getFires(widget.hotRank),
                      // Text(
                      //   '当前热门榜单: No' + widget.hotRank.toString(),
                      //   style: TextStyle(color: Colors.white70),
                      // )
                    ],
                  ),
                )
              : Container(
                  height: 0,
                )),
    ];
  }

  Widget getFires(int rank) {
    List<Widget> list = List();
    if (rank == 1) {
      list.add(Image.asset(
        PathConstant.ICON_CHAMPIN,
        width: 18,
        height: 18,
      ));
    } else {
      int count = 5 - rank;
      if (count >= 0) {
        for (int i = 0; i < count; i++) {
          list.add(Image.asset(
            PathConstant.ICON_FIRE,
            width: 18,
            height: 18,
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

  void showReplyContainer(String destAccountNick, String destAccountId) {
    print('show reply container');
    if (StringUtil.isEmpty(destAccountNick)) {
      setState(() {
        _hintText = "评论";
      });
    } else {
      setState(() {
        _hintText = "回复 $destAccountNick";
      });
    }
    setState(() {
      // curReply = tr;
      _replyContainerHeight = MediaQuery.of(context).size.width;
      // this.destAccountId = destAccountId;
    });
    _focusNode.requestFocus();
  }

  void hideReplyContainer() {
    setState(() {
      _replyContainerHeight = 0;
      _controller.clear();
      _focusNode.unfocus();
    });
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
        if (!widget._fromhot) {
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
              TweetReply tr2 = tweet.dirReplies
                  .where((dirReply) => dirReply.id == parentId)
                  .first;
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
              '回复失败，请稍后重试',
              gravity: ToastGravity.CENTER,
            );
          }
        }
      } else {
        ToastUtil.showToast(
          '回复失败，请稍后重试',
          gravity: ToastGravity.CENTER,
        );
      }
    });
  }
}