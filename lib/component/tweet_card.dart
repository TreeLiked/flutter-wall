import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/shared_data.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:provider/provider.dart';

class TweetCard extends StatefulWidget {
  BaseTweet tweet;

  TweetCardState s;

  TweetCard(BaseTweet tweet) {
    this.tweet = tweet;
    print('tc construct' + this.tweet.toJson().toString().substring(0, 40));
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

  refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  String _aniName = "heart";

  String _likeAssetPath = "assets/images/unlike.png";

  Widget _imgContainer(String url) {
    return Container(
      padding: EdgeInsets.only(right: 5, bottom: 5),
      width: 100,
      height: 100,
      child: Image.network(
        url,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _bodyContainer(String body) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 2, //主轴上子控件的间距
        runSpacing: 50, //交叉轴上子控件之间的间距
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
    print('wdasdasda');
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

  Widget _leftContainer(String headUrl) {
    return Container(
      padding: EdgeInsets.fromLTRB(2, 0, 10, 0),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              headUrl,
              width: 44,
              height: 44,
            ),
          )
        ],
      ),
    );
  }

  // Widget _headContainer(String nick, String time) {
  //   return Row(
  //     mainAxisSize: MainAxisSize.max,
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     children: <Widget>[
  //       Text(
  //         nick,
  //         style: TextStyle(
  //             fontSize: GlobalConfig.TWEET_FONT_SIZE,
  //             fontWeight: FontWeight.bold,
  //             color: GlobalConfig.tweetNickColor),
  //       ),
  //       Expanded(
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.end,
  //           children: <Widget>[
  //             Text(time,
  //                 style: TextStyle(
  //                   fontSize: 14,
  //                   color: GlobalConfig.tweetTimeColor,
  //                 ))
  //           ],
  //         ),
  //       )
  //     ],
  //   );
  // }

  Widget _picContainer(List<String> pics) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
      child: Wrap(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Wrap(
                    children: ((!CollectionUtil.isListEmpty(pics))
                        ? pics.map((imgUrl) => _imgContainer(imgUrl)).toList()
                        : <Widget>[])),
              )
            ],
          )
        ],
      ),
    );
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

  Widget cardContainer2() {
    Widget wd = new Row(
      children: <Widget>[
        Expanded(
          child: Container(
              padding: EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _coverWidget(
                          'https://gratisography.com/thumbnails/gratisography-bunny-newspaper-thumbnail.jpg')
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            _profileContainer(
                                'https://tva1.sinaimg.cn/large/006y8mN6ly1g7jpvd6h0oj30u00u0grg.jpg'),
                            Expanded(
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        _nickContainer('在梦里见过你'),
                                        Expanded(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              _timeContainer(tweet.gmtCreated),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        _signatureContainer('小猪佩奇我配你，十里春风不如你'),
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
                        _extraContainer(),
                        _commentContainer()
                      ],
                    ),
                  ),
                ],
              )),
        )
      ],
    );
    return wd;
  }

  // Widget cardContainer() {
  //   Widget wd = new Row(
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //       _leftContainer(
  //           'https://tva1.sinaimg.cn/large/006y8mN6gy1g7dtpkfm07j30fj0f9dgs.jpg'),
  //       Flexible(
  //           fit: FlexFit.tight,
  //           flex: 1,
  //           child: Container(
  //             padding: EdgeInsets.only(right: 10, left: 2),
  //             child: Column(
  //               children: <Widget>[
  //                 _headContainer(
  //                     '说好不见面', TimeUtil.getShortTime(_tweet.gmtCreated)),
  //                 _bodyContainer(_tweet.body),
  //                 _picContainer(_tweet.pics),
  //                 Container(
  //                   padding: EdgeInsets.only(top: 10),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     children: <Widget>[
  //                       Container(
  //                         padding: EdgeInsets.only(right: 20),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: <Widget>[
  //                             Text(
  //                               tweetTypeMap[_tweet.type].zhTag,
  //                               style: TextStyle(
  //                                   fontWeight: FontWeight.bold,
  //                                   color: GlobalConfig.tweetTypeColor),
  //                             )
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Container(
  //                   padding: EdgeInsets.only(top: 10),
  //                   child: Wrap(
  //                     spacing: 20, //主轴上子控件的间距
  //                     runSpacing: 50, //����轴上子控件之间的间��
  //                     children: <Widget>[
  //                       Row(
  //                         crossAxisAlignment: CrossAxisAlignment.center,
  //                         children: <Widget>[
  //                           _extraSingleContainer(
  //                             _likeAssetPath,
  //                             _tweet.praise.toString(),
  //                             callback: this._updateLikeOrUnlikd,
  //                           ),
  //                           _extraSingleContainer('assets/images/eye.png',
  //                               _tweet.views.toString()),
  //                           _extraSingleContainer('assets/images/chat.png',
  //                               _tweet.replyCount.toString(),
  //                               size: 18),
  //                         ],
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //                 Container(
  //                   margin: EdgeInsets.only(top: 10),

  //                   decoration: BoxDecoration(
  //                       color: Color(0xfff2f2f2),
  //                       borderRadius: BorderRadius.all(Radius.circular(10))),

  //                   padding: EdgeInsets.all(15),
  //                   child: Row(
  //                     children: <Widget>[
  //                       ClipOval(
  //                         // radius: 50,
  //                         child: Image.network(
  //                           'https://tva1.sinaimg.cn/large/006y8mN6ly1g7jpvd6h0oj30u00u0grg.jpg',
  //                           width: 30,
  //                           height: 30,
  //                           fit: BoxFit.cover,
  //                         ),
  //                       ),
  //                       Padding(
  //                           padding: EdgeInsets.only(left: 10),
  //                           child: Text(
  //                             '评论',
  //                             style:
  //                                 TextStyle(color: GlobalConfig.tweetTimeColor),
  //                           ))
  //                     ],
  //                   ),

  //                   // height: 33,
  //                   // margin: EdgeInsets.only(top: 10),
  //                   // padding: EdgeInsets.only(right: 10),
  //                   // decoration: BoxDecoration(
  //                   //     color: Color(0xffF5F5F5),
  //                   //     border: null,
  //                   //     borderRadius: BorderRadius.all(Radius.circular(4))),
  //                   // child: TextField(
  //                   //   maxLines: 1,
  //                   //   decoration: InputDecoration(
  //                   //       border: InputBorder.none,
  //                   //       prefixIcon: Icon(
  //                   //         Icons.near_me,
  //                   //         size: SizeConstant.TWEET_REPLT_ICON_SIZE,
  //                   //         color: !StringUtil.isEmpty(_replyText)
  //                   //             ? Colors.indigoAccent
  //                   //             : Colors.grey,
  //                   //       ),
  //                   //       hintText: '评论',
  //                   //       hintStyle: TextStyle(color: Colors.grey)),
  //                   //   cursorColor: Colors.blue,
  //                   //   textInputAction: TextInputAction.send,
  //                   //   onChanged: (val) {
  //                   //     this._updateReplyText(val);
  //                   //   },
  //                   // ),
  //                 ),
  //               ],
  //             ),
  //           )),
  //     ],
  //   );
  //   return wd;
  // }

  @override
  Widget build(BuildContext context) {
    print('tweet card build');
    setState(() {
      this.tweet = widget.tweet;
    });
    return new Container(
      child: Column(
        children: <Widget>[
          // cardContainer(),
          cardContainer2(),
        ],
      ),
      padding: EdgeInsets.only(bottom: 20, left: 5, right: 5),
      color: Colors.white,
    );
  }
}
