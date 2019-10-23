import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/common-widget/gallery_photo_view_wrapper.dart';
import 'package:iap_app/component/divider.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/shared_data.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/photo_wrap_item.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/page/create_page.dart';
import 'package:iap_app/page/tweet_detail.dart';
import 'package:iap_app/part/recom.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

class TweetCard extends StatefulWidget {
  final recomKey = GlobalKey<RecommendationState>();

  BaseTweet tweet;

  TweetCardState s;

  final callback;

  TweetCard(BaseTweet tweet, {this.callback}) {
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
  double sh;
  double max_width_single_pic;

  String hintText = "Say Something";

  refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  String _aniName = "like";

  String _likeAssetPath = "assets/images/unlike.png";

  String _likeAnimationName = "like";
  String _unlikeAnimationName = "unlike";

  Widget _imgContainer(String url, int index, int totalSize) {
    // 40 最外层container左右padding,
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
            right: totalSize == 4 ? 4 : (index % 3 == 2 ? 0 : 5), bottom: 4),
        width: perw,
        height: perw,
        child: GestureDetector(
          onTap: () => open(context, index),
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (context, url) => GlowingOverscrollIndicator(
              color: Colors.white,
              axisDirection: AxisDirection.left,
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ));
  }

  Widget _imgContainerSingle(String url) {
    return Container(
        padding: EdgeInsets.only(right: 5, bottom: 5),
        // width: 100,
        // height: 100,
        child: GestureDetector(
          onTap: () => open(context, 0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: max_width_single_pic, maxHeight: sh * 0.45),
            child: CachedNetworkImage(
              imageUrl: url,
              placeholder: (context, url) => GlowingOverscrollIndicator(
                color: Colors.white,
                axisDirection: AxisDirection.left,
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ));
  }

  void open(BuildContext context, final int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GalleryPhotoViewWrapper(
            usePageViewWrapper: true,
            galleryItems: widget.tweet.picUrls
                .map((f) => PhotoWrapItem(index: index, url: f))
                .toList(),
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            initialIndex: index,
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
        this._aniName = "unlike";
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
            // _extraSingleContainer(
            //   _likeAssetPath,
            //   tweet.praise.toString(),
            //   callback: this._updateLikeOrUnlikd,
            // ),

            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Text(
                      '${tweet.views}次浏览,  ${tweet.praise}人觉得很赞',
                      style: TextStyle(
                          fontSize: SizeConstant.TWEET_EXTRA_SIZE,
                          color: ColorConstant.TWEET_EXTRA_COLOR),
                    )),
              ],
            )
            // Container(
            //     child: GestureDetector(
            //   onTap: () {
            //     setState(() {
            //       if (this._aniName == "like") {
            //         this._aniName = "unlike";
            //       } else {
            //         this._aniName = "like";
            //       }
            //     });
            //   },
            //   child: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: <Widget>[
            //       Container(
            //         height: 50,
            //         width: 50,
            //         child: FlareActor(
            //           'assets/flrs/thumb_up.flr',
            //           animation: _aniName,
            //         ),
            //       ),
            //       Padding(
            //         padding: EdgeInsets.only(right: 10, left: 5),
            //         child: Text(
            //           tweet.praise.toString(),
            //           style: TextStyle(color: GlobalConfig.tweetTimeColor),
            //         ),
            //       ),
            //     ],
            //   ),
            // )),

            // _extraSingleContainer('assets/images/people.png',
            //     tweet.views > 999 ? '999+' : tweet.views.toString(),
            //     size: 16),
            // _extraSingleContainer(
            //     tweet.enableReply
            //         ? "assets/images/chat.png"
            //         : "assets/icons/warning.png",
            //     tweet.enableReply ? tweet.replyCount.toString() : '评论关闭',
            //     size: 18),
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
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: GestureDetector(
            onTap: () {
              // 点击回复框，直接回复推文
              _sendReply(widget.tweet.id, 1);
            },
            child: Row(
              children: <Widget>[
                ClipOval(
                  child: Image.network(
                    tweet.account.avatarUrl,
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        hintText,
                        style: TextStyle(
                            fontSize: SizeConstant.TWEET_TIME_SIZE - 1,
                            color: ColorConstant.TWEET_TIME_COLOR),
                      )),
                ),
              ],
            ),
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
      list.add(_singleReplyContainer(
          dirTr.id,
          _getNickFromAccount(dirTr.account),
          _getNickFromAccount(dirTr.tarAccount),
          // 对于直接回复，那么回复就是直接回复的账户
          dirTr.account.id,
          dirTr.body,
          false,
          false));
      displayCnt++;
      if (!CollectionUtil.isListEmpty(dirTr.children)) {
        dirTr.children.forEach((tr) {
          list.add(_singleReplyContainer(
              dirTr.id,
              _getNickFromAccount(tr.account),
              _getNickFromAccount(tr.tarAccount),
              // 如果是子回复，回复第一个用户, parentId不变
              dirTr.account.id,
              tr.body,
              false,
              false));
        });
      }
    }
    if (tweet.replyCount > GlobalConfig.MAX_DISPLAY_REPLY) {
      list.add(_singleReplyContainer(
          -1,
          "",
          "",
          "",
          "查看更多 ${tweet.replyCount - GlobalConfig.MAX_DISPLAY_REPLY} 条回复..",
          false,
          true));
    }

    return list;
  }

  Widget _replyContainer() {
    if (tweet.enableReply && !CollectionUtil.isListEmpty(tweet.dirReplies)) {
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
    } else {
      return Container(height: 0.0);
    }
  }

  Widget _singleReplyContainer(int parentId, String user, String destUser,
      String destAccId, String body, bool isSub, bool bottom) {
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
        child: GestureDetector(
          onTap: () {
            // 只要点击评论中的某一行，都是它的子回复
            _sendReply(parentId, 2,
                destAccountNick: user, destAccountId: destAccId);
          },
          child: Wrap(
            children: <Widget>[
              RichText(
                maxLines: 5,
                overflow: TextOverflow.fade,
                softWrap: true,
                text: TextSpan(children: [
                  TextSpan(
                      text: user,
                      style: MyDefaultTextStyle.getTweetReplyNickStyle(15)),
                  TextSpan(
                    text: !StringUtil.isEmpty(destUser) ? ' 回复 ' : '',
                    style: TextStyle(color: Colors.black87),
                  ),
                  TextSpan(
                      text: destUser,
                      style: MyDefaultTextStyle.getTweetReplyNickStyle(15)),
                  TextSpan(
                    text: '：',
                    style: TextStyle(color: Colors.black87),
                  ),
                  TextSpan(
                    text: body,
                    style:
                        TextStyle(color: ColorConstant.TWEET_REPLY_FONT_COLOR),
                  ),
                ]),
              ),
            ],
          ),
        ));
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
                      padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
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
                          // _praiseContainer(),
                          _replyContainer(),
                          divider,
                          _commentContainer()
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
    sh = MediaQuery.of(context).size.height;

    max_width_single_pic = (sw - 40);

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

  /*
   * desAccountNick 显示在输入框中的回复， destAccountId 移动推送
   */
  _sendReply(int parentId, int type,
      {String destAccountNick, String destAccountId}) {
    TweetReply tr = new TweetReply();
    tr.type = type;
    tr.parentId = parentId;
    if (type == 2) {
      tr.tarAccount = Account.fromId(destAccountId);
    }
    widget.callback(tr, destAccountNick, destAccountId);
  }
}
