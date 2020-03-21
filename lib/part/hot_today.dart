import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/component/hot_app_bar.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/oss_canstant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/hot_tweet.dart';
import 'package:iap_app/model/media.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/page/tweet_detail.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
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

class _HotTodayState extends State<HotToday> with AutomaticKeepAliveClientMixin {
  double _expandedHeight = ScreenUtil().setWidth(380);

  UniHotTweet hotTweet;

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
    UniHotTweet ht = await TweetApi.queryOrgHotTweets(Application.getOrgId);

    if (ht == null) {
      ToastUtil.showToast(context, '数据加载错误');
      setState(() {
        this.hotTweet = null;
      });
      return;
    }
    setState(() {
      this.hotTweet = ht;
      if (ht.tweets != null) {
        ht.tweets.forEach((f) => print(f.toJson()));
      }
    });
    ToastUtil.showToast(context, '更新完成');
  }

  get getBackgroundUrl {
    String baseUrl = PathConstant.HOT_COVER_URL + OssConstant.THUMBNAIL_SUFFIX;
    if (hotTweet == null) {
      return baseUrl;
    }
    List<HotTweet> bts = hotTweet.tweets;
    if (CollectionUtil.isListEmpty(bts)) {
      return baseUrl;
    }
    Media firstMedia = bts[0].cover;

    if (firstMedia == null || firstMedia.mediaType != Media.TYPE_IMAGE) {
      return baseUrl;
    }

    return firstMedia.url + OssConstant.THUMBNAIL_SUFFIX;
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
                              text: '${DateUtil.formatDate(DateTime.now(), format: 'dd')} ',
                              style: TextStyle(fontSize: 30)),
                          TextSpan(
                              text: '/ ${DateUtil.formatDate(DateTime.now(), format: 'MM')}',
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
                          '精选20条最热门的内容，每小时更新一次',
                          softWrap: true,
                          maxLines: 2,
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        Text(
                          '上次更新时间：' +
                              (hotTweet != null
                                  ? DateUtil.formatDate(hotTweet.lastFetched, format: "HH:mm").toString()
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

  List<Widget> _getRenderList(UniHotTweet ht) {
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
                width: ScreenUtil().setHeight(210),
                child: LoadAssetImage(
                  'no_data',
                  fit: BoxFit.cover,
                  width: 100,
                )),
//             Text('暂无数据', style: Theme.of(context).textTheme.subhead),
          ],
        ),
      ];
    } else {
      // 正在加载过程
      return <Widget>[];
    }
  }

  _forwardDetail(int tweetId, int rank) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TweetDetail(null, tweetId: tweetId, hotRank: rank), maintainState: true),
    );
  }

  _buildHotTweetCard(HotTweet bt, int index) {
    if (!bt.anonymous && bt.account == null) {
      return Gaps.empty;
    }
    index = index + 1;
    String idxStr = index.toString();
    if (index < 10) {
      idxStr = '0$index';
    }

    String nick;
    if (bt.anonymous) {
      nick = TextConstant.TWEET_ANONYMOUS_NICK;
    } else {
      nick = bt.account.nick;
    }

    String oriCoverUrl = (bt.cover != null && bt.cover.mediaType == Media.TYPE_IMAGE) ? bt.cover.url : null;
    bool hasBody = !StringUtil.isEmpty(bt.body);
    return GestureDetector(
        onTap: () => _forwardDetail(bt.id, index),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: index == 0 ? 0 : 5),
              padding: const EdgeInsets.only(top: 5, bottom: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: Text(
                              idxStr,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimens.font_sp16,
                                  color: index <= 3
                                      ? Colors.red
                                      : (index <= 6
                                          ? Colors.amber
                                          : Theme.of(context).textTheme.overline.color)),
                            ),
                          ),
                          Container(
                              child: bt.upTrend
                                  ? Icon(
                                      Icons.arrow_upward,
                                      color: Colors.redAccent,
                                      size: 16,
                                    )
                                  : Icon(
                                      Icons.arrow_downward,
                                      color: Colors.lightGreen,
                                      size: 16,
                                    )),
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
                                  hasBody
                                      ? Text(
                                          bt.body,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          style: TextStyle(fontSize: Dimens.font_sp15),
                                        )
                                      : Gaps.empty,
                                  Gaps.vGap4,
                                  RichText(
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(children: [
                                      TextSpan(
                                          text: nick,
                                          style: MyDefaultTextStyle.getTweetNickStyle(
                                              context, Dimens.font_sp13p5,
                                              bold: false, anonymous: bt.anonymous)),
                                      TextSpan(
                                          text: ' 发表于${TimeUtil.getShortTime(bt.sentTime)}',
                                          style: TextStyle(color: Colors.grey, fontSize: Dimens.font_sp13)),
//                                      TextSpan(
//                                          text: TimeUtil.getShortTime(bt.sentTime),
//                                          style: TextStyle(
//                                              color: ColorConstant.TWEET_TIME_COLOR,
//                                              fontSize: Dimens.font_sp13)),
                                    ]),
                                  ),
                                  Container(
                                      padding: const EdgeInsets.only(bottom: 2, top: 3),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            '# ' + tweetTypeMap[bt.type].zhTag.toString(),
                                            style: TextStyle(
                                                color: tweetTypeMap[bt.type].color,
                                                fontSize: Dimens.font_sp12,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Padding(
                                              padding: const EdgeInsets.only(right: 20),
                                              child: Text(
                                                '热度 ${bt.hot}',
                                                style:
                                                    TextStyle(color: Colors.grey, fontSize: Dimens.font_sp12),
                                              ))
                                        ],
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  oriCoverUrl != null
                      ? Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              clipBehavior: Clip.antiAlias,
                              borderRadius: BorderRadius.circular(5),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: CachedNetworkImage(
                                  imageUrl: oriCoverUrl + OssConstant.THUMBNAIL_SUFFIX,
                                  placeholder: (context, url) => CupertinoActivityIndicator(),
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                            ),
                          ))
                      : Expanded(flex: 2, child: Gaps.empty),
                  Divider()
                ],
              ),
            ),
            Divider()
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
