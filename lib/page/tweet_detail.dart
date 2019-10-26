import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/time_util.dart';

class TweetDetail extends StatefulWidget {
  final BaseTweet _tweet;

  TweetDetail(this._tweet);
  @override
  State<StatefulWidget> createState() {
    print('TweetDetail create state');
    return TweetDetailState();
  }
}

class TweetDetailState extends State<TweetDetail>
    with AutomaticKeepAliveClientMixin {
  //获取实例
  OverlayState overlayState;
//创建OverlayEntry
  OverlayEntry overlayEntry;

  double sw;

  TweetDetailState() {
    print('TweetDETAIL state construct');
  }
  @override
  void initState() {
    super.initState();
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
                            fontSize: SizeConstant.TWEET_FONT_SIZE + 1,
                            fontWeight: FontWeight.bold,
                            color: ColorConstant.TWEET_NICK_COLOR),
                      ),
                      TextSpan(
                          text: " 发表于" +
                              TimeUtil.getShortTime(widget._tweet.gmtCreated),
                          style: TextStyle(
                              fontSize: SizeConstant.TWEET_TIME_SIZE + 1,
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
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: Row(
        children: <Widget>[
          Text(
            "${widget._tweet.views} 次浏览",
            style: MyDefaultTextStyle.getTweetTimeStyle(13),
          )
        ],
      ),
    );
  }

  Widget _loveContainer() {
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            "assets/images/heart.png",
            width: 66,
            height: 66,
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

  List<Widget> _getReplyList() {
    if (CollectionUtil.isListEmpty(widget._tweet.dirReplies)) {
      return [];
    }
    List<Widget> list = new List();

    List<TweetReply> originReversed =
        widget._tweet.dirReplies.reversed.toList();
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
    // if (widget._tweet.replyCount > GlobalConfig.MAX_DISPLAY_REPLY) {
    //   list.add(_singleReplyContainer(
    //       "",
    //       "",
    //       "查看更多 ${widget._tweet.replyCount - GlobalConfig.MAX_DISPLAY_REPLY} 条回复...",
    //       false,
    //       true));
    // }

    return list;
  }

  String _getNickFromAccount(Account account) {
    if (account != null) {
      if (!StringUtil.isEmpty(account.nick)) {
        return account.nick;
      }
    }
    return '';
  }

  Widget _textTitleRow(String title) {
    return Row(
      children: <Widget>[Text(title)],
    );
  }

  Widget _praiseContainer() {
    List<Widget> list = new List();
    list.add(_textTitleRow('点赞'));
    return Container(
      padding: EdgeInsets.only(top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: list),
          )
        ],
      ),
    );
  }

  Widget _replyContainer() {
    List<Widget> list = new List();
    list.add(_textTitleRow('评论'));
    list.addAll(_getReplyList());
    return Container(
      padding: EdgeInsets.only(top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: list),
          )
        ],
      ),
    );
  }

  Widget _singleReplyContainer(
      String user, String destUser, String body, bool isSub, bool bottom) {
    if (bottom) {
      return Padding(
        padding: EdgeInsets.only(top: 5),
        child: Text(
          body,
          style: TextStyle(color: ColorConstant.TWEET_NICK_COLOR),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.only(bottom: 5, left: isSub ? 10 : 0),
      child: Wrap(
        // mainAxisAlignment: MainAxisAlignment.start,

        children: <Widget>[
          RichText(
            maxLines: 10,
            overflow: TextOverflow.fade,
            softWrap: true,
            text: TextSpan(children: [
              TextSpan(
                  text: user,
                  style: TextStyle(color: ColorConstant.TWEET_NICK_COLOR)),
              TextSpan(
                text: !StringUtil.isEmpty(destUser) ? ' 回复 ' : '',
                style: TextStyle(color: Colors.grey),
              ),
              TextSpan(
                  text: destUser,
                  style: TextStyle(color: ColorConstant.TWEET_NICK_COLOR)),
              TextSpan(
                text: !StringUtil.isEmpty(destUser) ? ' ���：' : '：',
                style: TextStyle(color: Colors.grey),
              ),
              TextSpan(
                text: body,
                style: TextStyle(color: Colors.grey),
              ),
            ]),
          ),
        ],
      ),
    );
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
                    SizeConstant.TWEET_FONT_SIZE - 2)),
            TextSpan(
                text: StringUtil.isEmpty(tarNick) ? '' : ' 回复 ',
                style: MyDefaultTextStyle.getTweetTimeStyle(
                    SizeConstant.TWEET_TIME_SIZE)),
            TextSpan(
                text: StringUtil.isEmpty(tarNick) ? '' : tarNick,
                style: MyDefaultTextStyle.getTweetNickStyle(
                    SizeConstant.TWEET_FONT_SIZE - 2))
          ]),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(time,
                  style: TextStyle(
                    fontSize: SizeConstant.TWEET_TIME_SIZE - 1,
                    color: GlobalConfig.tweetTimeColor,
                  ))
            ],
          ),
        )
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
      backgroundColor: ColorConstant.DEFAULT_BAR_BACK_COLOR,
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
            children: <Widget>[
              _spaceRow(),
              _bodyContainer(),
              _picContainer(),
              _viewContainer(),
              // _loveContainer(),
              _praiseContainer(),
              _replyContainer(),
            ],
          ),
        )),
      ),
    );
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
          centerTitle: true, //标题居中
          title: Text('详情'),
          elevation: 0.5,
          expandedHeight: 120,
          floating: true,
          pinned: true,
          snap: false,
          flexibleSpace: Container(
            margin: EdgeInsets.only(top: ScreenUtil.statusBarHeight + 60),
            padding: EdgeInsets.only(left: 20),
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              children: <Widget>[
                Text(
                  '今日热门',
                  style: TextStyle(color: Colors.black),
                )
              ],
            ),
          )),
    ];
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
