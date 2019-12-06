import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/imgae_container.dart';
import 'package:iap_app/common-widget/v_empty_view.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/oss_canstant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/page/tweet_detail.dart';
import 'package:iap_app/part/recom.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/account_util.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart';

class TweetCard extends StatefulWidget {
  final recomKey = GlobalKey<RecommendationState>();

  BaseTweet tweet;

  final callback;

  TweetCard(BaseTweet tweet, {this.callback}) {
    this.tweet = tweet;
    print('tc construct');
  }

  @override
  State<StatefulWidget> createState() {
    return _TweetCardState(tweet);
  }
}

class _TweetCardState extends State<TweetCard>
    with AutomaticKeepAliveClientMixin<TweetCard> {
  BaseTweet tweet;

  double sw;
  double sh;
  double maxWidthSinglePic;
  double _imgRightPadding = 1.5;

  _TweetCardState(BaseTweet tweet) {
    this.tweet = tweet;
  }
  @override
  void initState() {
    super.initState();
  }

  Widget _imgContainer(String url, int index, int totalSize) {
    // 40 最外层container左右padding,
    double left = (sw - 20);
    double perw;
    double rp = 1.5;

    if (totalSize == 2 || totalSize == 4) {
      perw = (left - _imgRightPadding - 1) / 2;
      if (index % 2 != 0) {
        rp = 0;
      }
    } else {
      perw = (left - _imgRightPadding * 2 - 1) / 3;
      if (index % 3 == 2) {
        rp = 0;
      }
    }

    return ImageCoatainer(
      url: url,
      width: perw,
      height: perw,
      padding: EdgeInsets.only(right: rp, bottom: 1.5),
      callback: () => open(context, index),
    );
    // return Container(
    //     // %2 因为索引从0开始，3的倍数右边距设为0
    //     padding: EdgeInsets.only(
    //         right: totalSize == 4 ? 1 : (index % 3 == 2 ? 0 : 1), bottom: 1),
    //     width: perw,
    //     height: perw,
    //     child: GestureDetector(
    //       onTap: () => open(context, index),
    //       child: FadeInImage.assetNetwork(
    //         image: url,
    //         fit: BoxFit.cover,
    //         placeholder: PathConstant.IAMGE_HOLDER,
    //       ),
    //       // child: CachedNetworkImage(
    //       //   imageUrl: url,
    //       //   fit: BoxFit.cover,
    //       //   placeholder: (context, url) => WidgetUtil.getLoadingGif(),
    //       //   errorWidget: (context, url, error) =>
    //       //       WidgetUtil.getAsset(PathConstant.IAMGE_FAILED, size: 10),
    //       // ),
    //       // child: Image.network(url),
    //     ));
  }

  Widget _imgContainerSingle(String url) {
    return GestureDetector(
      onTap: () => open(context, 0),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: maxWidthSinglePic, maxHeight: sh * 0.4),
        // child: FadeInImage.assetNetwork(
        //   image: url,
        //   placeholder: PathConstant.IAMGE_HOLDER,
        //   fit: BoxFit.cover,
        // ),
        child: CachedNetworkImage(
          filterQuality: FilterQuality.medium,
          imageUrl: url,
          placeholder: (context, url) => LoadAssetImage(
              PathConstant.IAMGE_HOLDER,
              width: Application.screenWidth * 0.25,
              height: Application.screenWidth * 0.25),
          errorWidget: (context, url, error) => LoadAssetImage(
              PathConstant.IAMGE_FAILED,
              width: Application.screenWidth * 0.25,
              height: Application.screenWidth * 0.25),
        ),
      ),
    );
  }

  void open(BuildContext context, final int index) {
    // print('===========');
    Utils.openPhotoView(context, widget.tweet.picUrls, index);
  }

  Widget _bodyContainer(BaseTweet tweet) {
    String body = tweet.body;
    return !StringUtil.isEmpty(body)
        ? Container(
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
                            // color: GlobalConfig.tweetBodyColor,
                            height: 1.5),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        : Container(height: 0);
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
      padding: EdgeInsets.only(top: 10),
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
                                    _imgContainerSingle(
                                        "${widget.tweet.picUrls[0]}${OssConstant.THUMBNAIL_SUFFIX}")
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
    List<String> picUrls = widget.tweet.picUrls
        .map((f) => "$f${OssConstant.THUMBNAIL_SUFFIX}")
        .toList();
    List<Widget> list = new List(picUrls.length);
    for (int i = 0; i < picUrls.length; i++) {
      list[i] = _imgContainer(picUrls[i], i, picUrls.length);
    }
    return list;
  }

  Widget _profileContainer(String profileUrl) {
    return GestureDetector(
        onTap: () => tweet.anonymous
            ? null
            : goAccountDetail(tweet.account.id, tweet.account.nick),
        child: Container(
            margin: EdgeInsets.only(right: 10),
            child: AccountAvatar(
              avatarUrl: !tweet.anonymous
                  ? (profileUrl ?? '')
                  : PathConstant.ANONYMOUS_PROFILE,
              size: SizeConstant.TWEET_PROFILE_SIZE,
            )));
  }

  Widget _nickContainer(String nickName) {
    if (tweet.anonymous) {
      tweet.account.nick = TextConstant.TWEET_ANONYMOUS_NICK;
    }
    return tweet.anonymous
        ? Container(
            child: Text(
            TextConstant.TWEET_ANONYMOUS_NICK,
            style: MyDefaultTextStyle.getTweetHeadNickStyle(
                context, SizeConstant.TWEET_NICK_SIZE,
                anonymous: true, bold: true),
          ))
        : GestureDetector(
            onTap: () => tweet.anonymous
                ? null
                : goAccountDetail(tweet.account.id, tweet.account.nick),
            child: Container(
              child: Text(
                nickName ?? "",
                style: MyDefaultTextStyle.getTweetHeadNickStyle(
                    context, SizeConstant.TWEET_NICK_SIZE,
                    bold: true),
              ),
            ));
  }

  Widget _timeContainer(DateTime dt) {
    if (dt == null) {
      return VEmptyView(0);
    }
    return Text(TimeUtil.getShortTime(dt),
        style: TextStyle(
            fontSize: SizeConstant.TWEET_TIME_SIZE,
            color: ColorConstant.getTweetTimeColor(context)));
  }

  Widget _signatureContainer(String sig) {
    if (StringUtil.isEmpty(sig)) {
      return VEmptyView(0);
    }
    return Container(
        margin: EdgeInsets.only(right: ScreenUtil.screenWidthDp * 0.15),
        child: Text(
          !tweet.anonymous ? sig : TextConstant.TWEET_ANONYMOUS_SIG,
          style: TextStyle(
              fontSize: SizeConstant.TWEET_TIME_SIZE,
              color: ColorConstant.getTweetSigColor(context)),
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          maxLines: 2,
        ));
  }

  Widget _typeContainer() {
    const Radius temp = Radius.circular(10);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 7),
      decoration: BoxDecoration(
          color: tweetTypeMap[tweet.type].color ?? Colors.blueAccent,
          borderRadius: BorderRadius.only(
            topRight: temp,
            bottomLeft: temp,
            bottomRight: temp,
          )),
      child: Text(
        '# ' + tweetTypeMap[tweet.type].zhTag,
        style: TextStyle(
            color: !ThemeUtils.isDark(context)
                ? Colors.white
                : ColorConstant.TWEET_TYPE_TEXT_DARK,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _extraContainer() {
    return Container(
      padding: EdgeInsets.only(top: 10),
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
                      '${tweet.views}次浏览 , ${tweet.praise}人觉得很赞',
                      style: TextStyle(
                          fontSize: SizeConstant.TWEET_EXTRA_SIZE,
                          color: ColorConstant.getTweetSigColor(context)),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  void updatePraise() async {
    if (tweet.latestPraise == null) {
      tweet.latestPraise = List();
    }

    setState(() {
      tweet.loved = !tweet.loved;
      if (tweet.loved) {
        Utils.showFavoriteAnimation(context);
        Future.delayed(Duration(seconds: 2))
            .then((_) => Navigator.pop(context));
        tweet.praise++;
        tweet.latestPraise.insert(0, Application.getAccount);
      } else {
        tweet.praise--;
        tweet.latestPraise
            .removeWhere((account) => account.id == Application.getAccountId);
      }
    });
    TweetApi.operateTweet(tweet.id, 'PRAISE', tweet.loved);
  }

  Widget _praiseContainer() {
    // 最近点赞的人数
    List<Widget> items = List();

    List<InlineSpan> spans = List();
    spans.add(WidgetSpan(
        child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              updatePraise();
            },
            child: Padding(
              padding: EdgeInsets.only(right: 5),
              child: Image.asset(
                // PathConstant.ICON_PRAISE_ICON_UNPRAISE,
                tweet.loved
                    ? PathConstant.ICON_PRAISE_ICON_PRAISE
                    : PathConstant.ICON_PRAISE_ICON_UNPRAISE,
                width: 18,
                height: 18,
              ),
            ))));
    List<Account> praiseList = tweet.latestPraise;
    if (!CollectionUtil.isListEmpty(praiseList)) {
      for (int i = 0;
          i < praiseList.length && i < GlobalConfig.MAX_DISPLAY_PRAISE;
          i++) {
        Account account = praiseList[i];
        print(account);
        spans.add(TextSpan(
            text: "${account.nick}" + (i != praiseList.length - 1 ? '、' : ' '),
            style:
                MyDefaultTextStyle.getTweetNickStyle(context, 13, bold: false),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                goAccountDetail(account.id, account.nick);
              }));
      }

      if (praiseList.length > GlobalConfig.MAX_DISPLAY_PRAISE) {
        int diff = praiseList.length - GlobalConfig.MAX_DISPLAY_PRAISE;
        items.add(Text(
          " 等共$diff人刚刚赞过",
          style: TextStyle(fontSize: 13),
        ));
      }
    }
    Widget widget = RichText(
      text: TextSpan(children: spans),
      softWrap: true,
    );
    items.add(widget);

    return GestureDetector(
        onTap: () => _forwardDetail(),
        child: Container(
          margin: EdgeInsets.only(top: 10),
          child: Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: items),
        ));
  }

  void goAccountDetail(String accountId, String nick) {
    NavigatorUtils.push(
        context,
        Routes.accountProfile +
            Utils.packConvertArgs({'nick': nick, 'accId': accountId}));
  }

  Widget _commentContainer() {
    if (tweet.enableReply) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _sendReply(1, tweet.id, tweet.account.id),
        child: Container(
          margin: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
              color: ThemeUtils.isDark(context)
                  ? Color(0xff363636)
                  : Color(0xfff2f2f2),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          padding: EdgeInsets.all(9),
          child: Row(
            children: <Widget>[
              AccountAvatar(
                  cache: true,
                  avatarUrl: Application.getAccount.avatarUrl,
                  size: SizeConstant.TWEET_PROFILE_SIZE * 0.8),
              Expanded(
                child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      TextConstant.TWEET_CARD_REPLY_HINT,
                      style: TextStyle(
                          fontSize: SizeConstant.TWEET_TIME_SIZE - 1,
                          color: ColorConstant.TWEET_TIME_COLOR),
                    )),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
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
      list.add(_singleReplyContainer(dirTr, true, false, parentId: dirTr.id));
      displayCnt++;
      if (!CollectionUtil.isListEmpty(dirTr.children)) {
        dirTr.children.forEach((tr) {
          list.add(_singleReplyContainer(tr, true, false, parentId: dirTr.id));
        });
      }
    }
    if (tweet.replyCount > GlobalConfig.MAX_DISPLAY_REPLY) {
      list.add(_singleReplyContainer(null, false, true));
    }

    return list;
  }

  Widget _replyContainer() {
    if (tweet.enableReply) {
      if (!CollectionUtil.isListEmpty(tweet.dirReplies)) {
        return GestureDetector(
          onTap: () => _forwardDetail(),
          child: Container(
            padding: EdgeInsets.only(top: 10),
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
          ),
        );
      } else {
        return Container(height: 0.0);
      }
    } else {
      // 评论关闭
      return Container(
          padding: EdgeInsets.only(top: 10),
          child: Text('评论关闭', style: MyDefaultTextStyle.getTweetTimeStyle(12)));
    }
  }

  Widget _singleReplyContainer(TweetReply reply, bool isSub, bool bottom,
      {int parentId}) {
    if (bottom) {
      return Padding(
        padding: EdgeInsets.only(top: 5),
        child: Text(
          "查看更多 ${tweet.replyCount - GlobalConfig.MAX_DISPLAY_REPLY} 条回复 ..",
          style: TextStyle(color: ColorConstant.TWEET_NICK_COLOR),
        ),
      );
    }
    bool authorAnonymous = widget.tweet.anonymous;
    String accNick = AccountUtil.getNickFromAccount(reply.account, false);
    bool isAuthorReply = (tweet.account.id == reply.account.id);
    if (isAuthorReply && authorAnonymous) {
      accNick = "作者";
      reply.account.nick = "作者";
    }

    bool replyAuthor =
        reply.tarAccount == null || (tweet.account.id == reply.tarAccount.id);
    String tarNick = AccountUtil.getNickFromAccount(reply.tarAccount, false);
    if (replyAuthor && authorAnonymous) {
      tarNick = "作者";
      if (reply.tarAccount != null) {
        reply.tarAccount.nick = "作者";
      }
    }

    bool dirReplyAnonymous = (reply.type == 1 && reply.anonymous);
    if (dirReplyAnonymous) {
      // 直接回复匿名
      reply.account.nick = TextConstant.TWEET_ANONYMOUS_REPLY_NICK;
    }
    // if (!replyAuthor) {

    return Container(
        width: double.infinity,
        padding: EdgeInsets.only(bottom: 5),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: !dirReplyAnonymous
              ? () {
                  // 只要点击评论中的某一行，都是它的子回复
                  _sendReply(2, parentId, reply.account.id,
                      tarAccNick: accNick);
                }
              : () {
                  ToastUtil.showToast(context, '匿名评论不可回复');
                },
          child: Wrap(
            children: <Widget>[
              RichText(
                maxLines: 5,
                overflow: TextOverflow.fade,
                softWrap: true,
                text: TextSpan(children: [
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          if (!dirReplyAnonymous) {
                            goAccountDetail(
                                reply.account.id, reply.account.nick);
                          }
                        },
                      text: dirReplyAnonymous
                          ? TextConstant.TWEET_ANONYMOUS_REPLY_NICK
                          : accNick,
                      style: isAuthorReply && authorAnonymous
                          ? MyDefaultTextStyle.getTweetReplyAnonymousNickStyle(
                              context, Dimens.font_sp14)
                          : MyDefaultTextStyle.getTweetReplyNickStyle(
                              context, Dimens.font_sp14)),
                  TextSpan(
                      text: reply.type == 2 ? ' 回复 ' : '',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.subtitle.color)),
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          if (replyAuthor && authorAnonymous) {
                            goAccountDetail(
                                reply.account.id, reply.account.nick);
                          }
                        },
                      text: reply.type == 2 ? tarNick : '',
                      style: replyAuthor && authorAnonymous
                          ? MyDefaultTextStyle.getTweetReplyAnonymousNickStyle(
                              context, Dimens.font_sp14)
                          : MyDefaultTextStyle.getTweetReplyNickStyle(
                              context, Dimens.font_sp14)),
                  TextSpan(
                    text: '：',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.subtitle.color,
                        fontSize: Dimens.font_sp14),
                  ),
                  TextSpan(
                    text: reply.body,
                    style: TextStyle(
                        color: !ThemeUtils.isDark(context)
                            ? Theme.of(context).textTheme.subhead.color
                            : ColorConstant.TWEET_TIME_COLOR_DARK,
                        fontSize: Dimens.font_sp14,
                        fontWeight: FontWeight.w400),
                    // recognizer: MultiTapGestureRecognizer()
                    //   ..onLongTapDown = (_, __) {
                    //     Utils.copyTextToClipBoard(reply.body);
                    //     ToastUtil.showToast(context, '内容已复制到粘贴板');
                    // }
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
                  // color: Colors.white,
                  ),
              child: GestureDetector(
                onTap: _forwardDetail,
                behavior: HitTestBehavior.translucent,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                      Wrap(
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
                          _bodyContainer(tweet),
                          _picContainer(),
                          _extraContainer(),
                          _praiseContainer(),
                          _replyContainer(),
                          // divider,
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
    super.build(context);
    print('tweet card build');
    sw = Application.screenWidth;
    sh = Application.screenHeight;

    maxWidthSinglePic = sw * 0.75;

    setState(() {
      this.tweet = widget.tweet;
    });
    return widget.tweet != null && widget.tweet.account != null
        ? Container(
            child: Column(
              children: <Widget>[
                // cardContainer(),
                cardContainer2(),
                Divider(height: 1)
              ],
            ),
            // margin: EdgeInsets.only(bottom: 10),
          )
        : VEmptyView(0);
  }

  /*
   * tarAccNick 显示在输入框中的回复， tarAccId 目标账户推送
   * type 1=> 评论， 2=> 子回复 
   */
  _sendReply(int type, int parentId, String tarAccId, {String tarAccNick}) {
    TweetReply tr = new TweetReply();
    tr.tweetId = tweet.id;
    tr.type = type;
    tr.parentId = parentId;
    tr.anonymous = false;
    tr.tarAccount = Account.fromId(tarAccId);

    widget.callback(tr, tarAccNick, tarAccId, _sendReplyCallback);
  }

  _sendReplyCallback(TweetReply tr) {
    print('评论回复结果回调 ！！！！！！！！！！！！！！！！！！！！！！！！！！！！');
    print(tr.toJson());
    if (tr == null) {
      ToastUtil.showToast(
        context,
        '回复失败，请稍后重试',
        gravity: ToastGravity.TOP,
      );
    } else {
      if (tr.type == 1) {
        // 设置到直接回复
        setState(() {
          if (tweet.dirReplies == null) {
            tweet.dirReplies = List();
          }
          tweet.dirReplies.add(tr);
        });
      } else {
        // 子回复
        int parentId = tr.parentId;
        setState(() {
          TweetReply tr2 = tweet.dirReplies
              .where((dirReply) => dirReply.id == parentId)
              .first;
          if (tr2.children == null) {
            tr2.children = List();
          }
          tr2.children.add(tr);
        });
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
}
