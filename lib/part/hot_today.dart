import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/component/hot_app_bar.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/oss_canstant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/hot_tweet.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/page/tweet_detail.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/image_utils.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart';

class HotToday extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HotTodayState();
  }
}

class _HotTodayState extends State<HotToday>
    with AutomaticKeepAliveClientMixin {
  double _expandedHeight = ScreenUtil().setWidth(380);

  final items = new List<String>.generate(10000, (i) => "Item $i");
  int orgId = 1;

  HotTweet hotTweet;

  // 连接通知器
  LinkHeaderNotifier _headerNotifier;

  Future<void> _onRefresh() async {
    await getData();
  }

  @override
  void initState() {
    super.initState();
    // _futureTask = getData();
    _headerNotifier = LinkHeaderNotifier();
  }

  @override
  void dispose() {
    _headerNotifier.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    HotTweet ht = await TweetApi.queryOrgHotTweets(orgId);

    if (ht == null) {
      ToastUtil.showToast(context, '数据加载错误');
      setState(() {
        this.hotTweet = null;
      });
      return;
    }
    setState(() {
      this.hotTweet = ht;
    });
    ToastUtil.showToast(context, '更新完成');
  }

  get getBackgroundUrl {
    String baseUrl = PathConstant.HOT_COVER_URL + OssConstant.THUMBNAIL_SUFFIX;
    if (hotTweet == null) {
      return baseUrl;
    }
    List<BaseTweet> bts = hotTweet.tweets;
    if (CollectionUtil.isListEmpty(bts)) {
      return baseUrl;
    }
    List<String> s = bts[0].picUrls;
    if (CollectionUtil.isListEmpty(s)) {
      return baseUrl;
    }
    return s[0] + OssConstant.THUMBNAIL_SUFFIX;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: EasyRefresh.custom(
          header: LinkHeader(
            _headerNotifier,
            extent: 70.0,
            triggerDistance: 70.0,
            // completeDuration: Duration(milliseconds: 5000),
            enableHapticFeedback: true,
          ),
          firstRefresh: true,
          slivers: <Widget>[
            HotAppBarWidget(
              headerNotifier: _headerNotifier,
              backgroundImg: getBackgroundUrl,
              count: 10,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Spacer(),
                  Container(
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(40)),
                    margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(5)),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text:
                                  '${DateUtil.formatDate(DateTime.now(), format: 'dd')} ',
                              style: TextStyle(fontSize: 30)),
                          TextSpan(
                              text:
                                  '/ ${DateUtil.formatDate(DateTime.now(), format: 'MM')}',
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(40)),
                    margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '精选20条最热门的内容，每小时更新一次',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        Text(
                          '上次更新时间：' +
                              (hotTweet != null
                                  ? DateUtil.formatDate(hotTweet.lastFetched,
                                          format: "HH:mm")
                                      .toString()
                                  : '暂未更新'),
                          style: TextStyle(fontSize: 13, color: Colors.white60),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              expandedHeight: _expandedHeight,
              title: '校园热门',
            ),
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: SliverList(
                delegate: SliverChildListDelegate(_getRenderList(hotTweet)),
              ),
            )
          ],
          onRefresh: _onRefresh,
          onLoad: null),
    );
  }

  List<Widget> _getRenderList(HotTweet ht) {
    print('hot card render .................................');
    if (hotTweet != null && !CollectionUtil.isListEmpty(hotTweet.tweets)) {
      print(ht.toJson());
      List<Widget> list = new List();
      for (int i = 0; i < hotTweet.tweets.length; i++) {
        list.add(_buildHotTweetCard(ht.tweets[i], i));
      }
      return list;
    } else if (hotTweet != null) {
      // 加载完成无数据
      return <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: ScreenUtil().setHeight(100),
            ),
            SizedBox(
                width: 100.0,
                height: 100.0,
                child: Image.asset(
                    ImageUtils.getImgPath("no_data", format: 'png'))),
            // Text('暂无数据', style: Theme.of(context).textTheme.subhead),
          ],
        ),
      ];
    } else {
      // 正在加载过程
      return <Widget>[];
    }
  }

  _forwardDetail(BaseTweet bt, int rank) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TweetDetail(bt, hotRank: rank)),
    );
  }

  _buildHotTweetCard(BaseTweet bt, int index) {
    index = index + 1;
    String idxStr = index.toString();
    if (index < 10) {
      idxStr = '0$index';
    }
    if (bt.anonymous) {
      bt.account.nick = TextConstant.TWEET_ANONYMOUS_NICK;
    }
    return GestureDetector(
        onTap: () => _forwardDetail(bt, index),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: index == 0 ? 0 : 10),
              padding: EdgeInsets.only(top: 5, bottom: 15),
              // constraints: BoxConstraints(maxHeight: 150),

              // margin: EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                      flex: 2,
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    idxStr,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 16,
                                        color: index <= 3
                                            ? Colors.red
                                            : (index <= 6
                                                ? Color(0xffEEE685)
                                                : Theme.of(context)
                                                    .textTheme
                                                    .overline
                                                    .color)),
                                  ),
                                ),
                                Container(
                                    child: bt.upTrend
                                        ? Icon(
                                            Icons.arrow_upward,
                                            color: Colors.red,
                                            size: 13,
                                          )
                                        : Icon(
                                            Icons.arrow_downward,
                                            color: Colors.green,
                                            size: 13,
                                          )),
                              ],
                            ),
                          )
                        ],
                      )),
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  StringUtil.isEmpty(bt.body)
                                      ? WidgetUtil.getEmptyContainer()
                                      : Wrap(children: <Widget>[
                                          Text(
                                            bt.body,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ]),
                                  Container(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Wrap(
                                        children: <Widget>[
                                          RichText(
                                            text: TextSpan(children: [
                                              TextSpan(
                                                  text: !bt.anonymous
                                                      ? bt.account.nick
                                                      : TextConstant
                                                          .TWEET_ANONYMOUS_NICK,
                                                  style: MyDefaultTextStyle
                                                      .getTweetNickStyle(
                                                          context, 14,
                                                          bold: false,
                                                          anonymous:
                                                              bt.anonymous)),
                                              TextSpan(
                                                  text: ' 发表于',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13)),
                                              TextSpan(
                                                  text: TimeUtil.getShortTime(
                                                      bt.gmtCreated),
                                                  style: TextStyle(
                                                      color: ColorConstant
                                                          .TWEET_TIME_COLOR,
                                                      fontSize: 13)),
                                            ]),
                                          ),
                                        ],
                                      )),
                                  Container(
                                      padding:
                                          EdgeInsets.only(bottom: 2, top: 3),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            '# ' +
                                                tweetTypeMap[bt.type]
                                                    .zhTag
                                                    .toString(),
                                            style: TextStyle(
                                                color:
                                                    tweetTypeMap[bt.type].color,
                                                fontSize: 12),
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(right: 20),
                                              child: Text(
                                                ' ${bt.hot}',
                                                style: TextStyle(
                                                    color: Color(0xffBEBEBE),
                                                    fontSize: 12),
                                              ))
                                        ],
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Divider()
                      ],
                    ),
                  ),
                  !CollectionUtil.isListEmpty(bt.picUrls)
                      ? Expanded(
                          flex: 2,
                          child: Container(
                            padding: EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              clipBehavior: Clip.antiAlias,
                              borderRadius: BorderRadius.circular(5),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: CachedNetworkImage(
                                  imageUrl: bt.picUrls[0] +
                                      OssConstant.THUMBNAIL_SUFFIX,
                                  placeholder: (context, url) => Container(
                                      padding: EdgeInsets.all(10),
                                      child: Image.asset(
                                          PathConstant.LOADING_GIF)),
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                          ))
                      : Expanded(
                          flex: 2,
                          child: Container(height: 0),
                        ),
                  Divider()
                ],
              ),

              // Container(
              //   padding: EdgeInsets.only(left: 40),
              //   child: Divider(),
              // )
            ),
            Divider()
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
