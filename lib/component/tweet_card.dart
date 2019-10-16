import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:iap_app/component/divider.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/shared_data.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/page/create_page.dart';
import 'package:iap_app/page/tweet_detail.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:provider/provider.dart';

class TweetCard extends StatefulWidget {
  BaseTweet tweet;

  TweetCardState s;

  TweetCard(BaseTweet tweet) {
    this.tweet = tweet;
    print('tc construct' + this.tweet.toJson().toString());
  }

  @override
  State<StatefulWidget> createState() {
    s = TweetCardState();
    return s;
  }

  refresh() {
    s.refresh();
  }
}

class TweetCardState extends State<TweetCard> {
  BaseTweet tweet;

  double sw;

  refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  String _aniName = "heart";

  String _likeAssetPath = "assets/images/unlike.png";

  Widget _imgContainer(String url, int index, int totalSize) {
    // 40 最外层container左右padding,
    double left = (sw - 40 - 5 * 2);
    double perw;
    if (totalSize == 4) {
      perw = left / 2.5;
    } else {
      perw = left / 3;
    }

    return Container(
      // %2 因为索引从0开始，3的倍数右边距设为0
      padding: EdgeInsets.only(
          right: totalSize == 4 ? 5 : (index % 3 == 2 ? 0 : 5), bottom: 5),
      width: perw,
      height: perw,
      child: Image.network(
        url,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _imgContainerSingle(String url) {
    return Container(
        padding: EdgeInsets.only(right: 5, bottom: 5),
        // width: 100,
        // height: 100,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 200),
          child: Image.network(
            url,
            fit: BoxFit.cover,
          ),
        ));
  }

  Widget _bodyContainer(String body) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Wrap(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  body,
                  softWrap: true,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 10,
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

  void _showAni() {
    setState(() {
      if (_aniName == "like") {
        this.tweet.praise -= 1;
        this._aniName = "cry";
        // this._aniName = "sleep";
      } else {
        this._aniName = "like";
        this.tweet.praise += 1;
      }
    });
  }

  Widget _extraSingleContainer(String iconPath, String text,
      {Function callback, double size = 20}) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () => callback(),
            child: Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.scaleDown, image: AssetImage(iconPath))),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 10, left: 5),
            child: Text(
              text,
              style: TextStyle(color: GlobalConfig.tweetTimeColor),
            ),
          ),
        ],
      ),
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
                    children:
                        ((!CollectionUtil.isListEmpty(widget.tweet.picUrls))
                            ? (widget.tweet.picUrls.length == 1
                                ? <Widget>[
                                    _imgContainerSingle(widget.tweet.picUrls[0])
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
    List<String> picUrls = widget.tweet.picUrls;
    List<Widget> list = new List(picUrls.length);
    for (int i = 0; i < picUrls.length; i++) {
      list[i] = _imgContainer(picUrls[i], i, picUrls.length);
    }
    return list;
  }

  void _updateLikeOrUnlikd() {
    setState(() {
      if (_likeAssetPath == "assets/images/like.png") {
        _likeAssetPath = "assets/images/unlike.png";
        tweet.praise--;
      } else {
        _likeAssetPath = "assets/images/like.png";
        tweet.praise++;
      }
    });
  }

  Widget _coverWidget(String url) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        child: Image.network(
          url,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Widget _headContainer() {}

  Widget _mainContainer() {}
  Widget _profileContainer(String profileUrl) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      child: Column(
        children: <Widget>[
          ClipOval(
            child: Image.network(
              profileUrl,
              width: SizeConstant.TWEET_PROFILE_SIZE,
              height: SizeConstant.TWEET_PROFILE_SIZE,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _nickContainer(String nickName) {
    return Container(
      child: Text(
        nickName,
        style: TextStyle(
            fontSize: SizeConstant.TWEET_FONT_SIZE,
            fontWeight: FontWeight.bold,
            color: ColorConstant.TWEET_NICK_COLOR),
      ),
    );
  }

  Widget _timeContainer(DateTime dt) {
    return Text(TimeUtil.getShortTime(dt),
        style: TextStyle(
          fontSize: SizeConstant.TWEET_TIME_SIZE,
          color: ColorConstant.TWEET_TIME_COLOR,
        ));
  }

  Widget _signatureContainer(String sig) {
    return Container(
      child: Text(sig,
          style: TextStyle(
            fontSize: SizeConstant.TWEET_TIME_SIZE,
            color: ColorConstant.TWEET_TIME_COLOR,
          )),
    );
  }

  Widget _typeContainer() {
    const Radius temp = Radius.circular(10);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 7),
      decoration: BoxDecoration(
          color: tweetTypeMap[tweet.type].color,
          borderRadius: BorderRadius.only(
            topRight: temp,
            bottomLeft: temp,
            bottomRight: temp,
          )),
      child: Text(
        '# ' + tweetTypeMap[tweet.type].zhTag,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _extraContainer() {
    return Container(
      padding: EdgeInsets.only(top: 15),
      child: GestureDetector(
        onTap: () => _forwardDetail(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _extraSingleContainer(
              _likeAssetPath,
              tweet.praise.toString(),
              callback: this._updateLikeOrUnlikd,
            ),
            _extraSingleContainer('assets/images/people.png',
                tweet.views > 999 ? '999+' : tweet.views.toString(),
                size: 16),
            _extraSingleContainer(
                'assets/images/' +
                    (tweet.enableReply ? 'chat.png' : 'warning.png'),
                tweet.enableReply ? tweet.replyCount.toString() : '评论关闭',
                size: 18),
          ],
        ),
      ),
    );
  }

  Widget _praiseContainer() {
    return GestureDetector(
      onTap: () => _forwardDetail(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/icons/thumb_up.png",
                  width: 15,
                  height: 15,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    '愿为东南风刚刚赞过,愿为东南风刚刚赞过',
                    softWrap: true,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _commentContainer() {
    if (tweet.enableReply) {
      return Container(
          margin: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
              color: Color(0xfff2f2f2),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          padding: EdgeInsets.all(15),
          child: Row(
            children: <Widget>[
              ClipOval(
                child: Image.network(
                  'https://tva1.sinaimg.cn/large/006y8mN6ly1g7jpvd6h0oj30u00u0grg.jpg',
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    '评论',
                    style: TextStyle(color: GlobalConfig.tweetTimeColor),
                  ))
            ],
          ));
    } else {
      return Container();
    }
  }

  String _getNickFromAccount(Account account) {
    if (account != null) {
      if (!StringUtil.isEmpty(account.nick)) {
        return account.nick;
      }
    }
    return '';
  }

  List<Widget> _getReplyList() {
    if (CollectionUtil.isListEmpty(tweet.dirReplies)) {
      return [];
    }
    List<Widget> list = new List();

    int displayCnt = 0;
    for (var dirTr in tweet.dirReplies) {
      if (displayCnt == GlobalConfig.MAX_DISPLAY_REPLY) {
        break;
      }
      list.add(_singleReplyContainer(_getNickFromAccount(dirTr.account),
          _getNickFromAccount(dirTr.tarAccount), dirTr.body, false, false));
      displayCnt++;
      if (!CollectionUtil.isListEmpty(dirTr.children)) {
        dirTr.children.forEach((tr) {
          list.add(_singleReplyContainer(_getNickFromAccount(tr.account),
              _getNickFromAccount(tr.tarAccount), tr.body, true, false));
          displayCnt++;
        });
      }
    }
    if (tweet.replyCount > GlobalConfig.MAX_DISPLAY_REPLY) {
      list.add(_singleReplyContainer(
          "",
          "",
          "查看更多 ${tweet.replyCount - GlobalConfig.MAX_DISPLAY_REPLY} 条回复...",
          false,
          true));
    }

    return list;
  }

  Widget _replyContainer() {
    return Container(
      padding: EdgeInsets.only(top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _getReplyList()),
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
      padding: EdgeInsets.only(bottom: 5, left: isSub ? 5 : 0),
      child: Wrap(
        // mainAxisAlignment: MainAxisAlignment.start,

        children: <Widget>[
          RichText(
            maxLines: 10,
            overflow: TextOverflow.fade,
            softWrap: true,
            text: TextSpan(children: [
              TextSpan(
                  text: user, style: MyDefaultTextStyle.getTweetNickStyle(15)),
              TextSpan(
                text: !StringUtil.isEmpty(destUser) ? ' 回复 ' : '',
                style: TextStyle(color: Colors.grey),
              ),
              TextSpan(
                  text: destUser,
                  style: MyDefaultTextStyle.getTweetNickStyle(15)),
              TextSpan(
                text: !StringUtil.isEmpty(destUser) ? ' 说：' : '：',
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

  void _forwardDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TweetDetail(this.tweet)),
    );
  }

  Widget cardContainer2() {
    Widget wd = new Row(
      children: <Widget>[
        Expanded(
          child: Container(
              padding: EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.only(
                //     // topLeft: Radius.circular(20),
                //     topRight: Radius.circular(30),
                //     bottomLeft: Radius.circular(20),
                //     bottomRight: Radius.circular(20)),
                color: Colors.white,
              ),
              child: GestureDetector(
                onTap: _forwardDetail,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    // Row(
                    //   children: <Widget>[
                    //     // _coverWidget(!CollectionUtil.isListEmpty(tweet.pics)
                    //     //     ? tweet.pics[0]
                    //     //     : 'https://gratisography.com/thumbnails/gratisography-bunny-newspaper-thumbnail.jpg')
                    //   ],
                    // ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.only(
                      //       topLeft: Radius.circular(10),
                      //       topRight: Radius.circular(10)),
                      // ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              _profileContainer(tweet.account.avatarUrl),
                              Expanded(
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          _nickContainer(tweet.account.nick),
                                          Expanded(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                _timeContainer(
                                                    tweet.gmtCreated),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          _signatureContainer(
                                              tweet.account.signature),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Row(
                              children: <Widget>[
                                _typeContainer(),
                              ],
                            ),
                          ),
                          _bodyContainer(tweet.body),
                          _picContainer(),
                          _extraContainer(),
                          _praiseContainer(),
                          tweet.enableReply ? _replyContainer() : Container(),
                          divider,
                          tweet.enableReply ? _commentContainer() : Container()
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        )
      ],
    );
    return wd;
  }

  @override
  Widget build(BuildContext context) {
    print('tweet card build');
    sw = MediaQuery.of(context).size.width;

    setState(() {
      this.tweet = widget.tweet;
    });
    return new Container(
      child: Column(
        children: <Widget>[
          // cardContainer(),
          cardContainer2(),
          Divider(height: 1)
        ],
      ),
      // margin: EdgeInsets.only(bottom: 10),
    );
  }
}
