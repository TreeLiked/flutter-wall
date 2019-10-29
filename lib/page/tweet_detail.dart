import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/widget_util.dart';

import '../application.dart';

class TweetDetail extends StatefulWidget {
  final BaseTweet _tweet;
  final int hotRank;

  TweetDetail(this._tweet, {this.hotRank = -1});
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

  Widget _spaceRow() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // 头像
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: 10, left: 0),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: ClipOval(
                    child: Image.network(
                      widget._tweet.account.avatarUrl,
                      width: SizeConstant.TWEET_PROFILE_SIZE - 1,
                      height: SizeConstant.TWEET_PROFILE_SIZE - 1,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 2),
                  child: RichText(
                    softWrap: true,
                    text: TextSpan(children: [
                      TextSpan(
                        text: widget._tweet.account.nick,
                        style: TextStyle(
                            fontSize: SizeConstant.TWEET_FONT_SIZE,
                            color: ColorConstant.TWEET_NICK_COLOR),
                      ),
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
                      fontSize: GlobalConfig.TWEET_FONT_SIZE + 1,
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

  List<Widget> _getReplyList(List<TweetReply> data) {
    List<Widget> list = new List();

    List<TweetReply> originReversed = data.reversed.toList();
    int displayCnt = 0;
    for (var dirTr in originReversed) {
      if (displayCnt == GlobalConfig.MAX_DISPLAY_REPLY) {
        break;
      }
      list.add(replyWrapContainer(dirTr, false));

      if (!CollectionUtil.isListEmpty(dirTr.children)) {
        dirTr.children.forEach((tr) {
          list.add(replyWrapContainer(tr, true));
          displayCnt++;
        });
      }
    }

    return list;
  }

  Widget _getPraiseList(List<Account> data) {
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

    if (!CollectionUtil.isListEmpty(data)) {
      for (int i = 0;
          i < data.length && i < GlobalConfig.MAX_DISPLAY_PRAISE;
          i++) {
        Account account = data[i];
        spans.add(TextSpan(
            text: "${account.nick}" + (i != data.length - 1 ? '、' : ' '),
            style: MyDefaultTextStyle.getTweetNickStyle(13, bold: false),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // goAccountDetail();
              }));
      }

      if (data.length > GlobalConfig.MAX_DISPLAY_PRAISE_DETAIL) {
        int diff = data.length - GlobalConfig.MAX_DISPLAY_PRAISE;
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
    Widget reply = Icon(
      Icons.message,
      size: 20,
      color: Colors.grey,
    );
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

    if (widget._tweet.replyCount <= 0) {
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
              debugPrint("done");
              if (async.hasError) {
                return new Center(
                  child: new Text("${async.error}"),
                );
              } else if (async.hasData) {
                List<Account> list = async.data;
                return Wrap(
                  alignment: WrapAlignment.start,
                  children: [_getPraiseList(list)],
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
                return Column(
                  children: _getReplyList(list),
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
      } else {
        tweet.praise--;
        tweet.latestPraise
            .removeWhere((account) => account.id == Application.getAccount.id);
      }
      TweetApi.operateTweet(tweet.id, 'PRAISE', tweet.loved);
    });
  }

  Widget _leftContainer(String headUrl, bool sub) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipOval(
            child: Image.network(
              headUrl,
              width: SizeConstant.TWEET_PROFILE_SIZE - (sub ? 8 : 5),
              height: SizeConstant.TWEET_PROFILE_SIZE - (sub ? 8 : 5),
              fit: BoxFit.cover,
            ),
          )
        ],
      ),
    );
  }

  Widget _headContainer(String nick, String tarNick, String time) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(children: [
            TextSpan(
                text: nick,
                style: MyDefaultTextStyle.getTweetNickStyle(
                    SizeConstant.TWEET_FONT_SIZE - 2,
                    bold: false)),
            TextSpan(
                text: StringUtil.isEmpty(tarNick) ? '' : ' 回复 ',
                style: MyDefaultTextStyle.getTweetTimeStyle(
                    SizeConstant.TWEET_TIME_SIZE)),
            TextSpan(
                text: StringUtil.isEmpty(tarNick) ? '' : tarNick,
                style: MyDefaultTextStyle.getTweetNickStyle(
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
      padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
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
    double left = (sw - 20 - (totalSize - 1) * 4);
    double perw;
    if (totalSize == 2) {
      perw = left / 2.1;
    } else if (totalSize == 4) {
      perw = left / 2.1;
    } else {
      perw = left / 3.1;
    }

    return Container(
      // %2 因为索引从0开始，3的倍数右边距设为0
      padding: EdgeInsets.only(
          right: totalSize == 4 ? 1 : (index % 3 == 2 ? 0 : 1), bottom: 1),
      width: perw,
      height: perw,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          padding: EdgeInsets.all(20),
          child: Image.asset(PathConstant.LOADING_GIF),
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }

  Widget _imgContainerSingle(String url) {
    return Container(
        child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: (sw - 15) * 0.9),
      child: Image.network(
        url,
        fit: BoxFit.cover,
      ),
    ));
  }

  Widget replyWrapContainer(TweetReply reply, bool subDir) {
    Widget wd = new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: subDir ? 15 : 0),
        ),
        _leftContainer(reply.account.avatarUrl, subDir),
        Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(right: 10, left: 2, top: 5),
              child: Column(children: <Widget>[
                _headContainer(
                    reply.account.nick,
                    reply.tarAccount == null ? "" : reply.tarAccount.nick,
                    TimeUtil.getShortTime(reply.gmtCreated)),
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
    );
    return wd;
  }

  @override
  Widget build(BuildContext context) {
    sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: widget.hotRank != -1 ? Color(0xff4f4f4f) : Colors.white,
      // backgroundColor: Colors.white,
      body: NestedScrollView(
        // headerSliverBuilder: null,
        headerSliverBuilder: (context, innerBoxIsScrolled) =>
            _sliverBuilder(context, innerBoxIsScrolled),
        body: SingleChildScrollView(
            child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(15))),
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
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
              _templateWidget(_replyTitleContainer(), _replyFutureContainer()),

              // _praiseContainer(),

              // _replyFutureContainer(),
              // Container(height: ScreenUtil.screenWidthDp)
            ],
          ),
        )),
      ),
    );
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
          backgroundColor:
              widget.hotRank != -1 ? Color(0xff4f4f4f) : Colors.white,
          centerTitle: true, //标题居中
          title: Text('详情',
              style: TextStyle(
                  color: widget.hotRank != -1 ? Colors.white : Colors.black)),
          elevation: 0.5,
          expandedHeight: widget.hotRank != -1 ? 110 : 0,
          floating: true,
          pinned: true,
          snap: false,
          leading: null,
          flexibleSpace: widget.hotRank != -1
              ? Container(
                  margin: EdgeInsets.only(top: ScreenUtil.statusBarHeight + 60),
                  // padding: EdgeInsets.only(left: 20),
                  // decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                                fontSize: 17, color: Colors.redAccent))
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
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
