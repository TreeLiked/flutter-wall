import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/component/hot_app_bar.dart';
import 'package:iap_app/component/tweet/tweet_hot_card.dart';
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
      ToastUtil.showToast(context, '当前访问过多，请稍后重试');
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
    bool loadingOrRedisInit = hotTweet == null;
    bool noData = !loadingOrRedisInit && CollectionUtil.isListEmpty(hotTweet.tweets);
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
                          '精选20条校园最热门的内容，每小时更新一次',
                          softWrap: true,
                          maxLines: 2,
                          style: TextStyle(fontSize: Dimens.font_sp14, color: Colors.white70),
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
            new SliverFixedExtentList(
              itemExtent: loadingOrRedisInit ? 0 : !noData ? 100 : Application.screenHeight,
              delegate: new SliverChildBuilderDelegate((BuildContext context, int index) {
                //创建列表项
                if (hotTweet == null) {
                  return Gaps.empty;
                }
                var tweets = hotTweet.tweets;
                if (tweets == null || tweets.length == 0) {
                  return _noDataView();
                }
                return TweetHotCard(tweets[index], index, () => _forwardDetail(tweets[index].id, index + 1));
              }, childCount: loadingOrRedisInit ? 0 : !noData ? hotTweet.tweets.length : 1),
            ),
          ],
          onRefresh: _onRefresh,
          onLoad: null),
    );
  }

  _noDataView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
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
        Gaps.vGap10,
        Text('暂无数据', style: Theme.of(context).textTheme.subhead),
        Gaps.vGap8,
        Text('快去发布内容抢占热门吧!', style: Theme.of(context).textTheme.subhead),
      ],
    );
  }

  _forwardDetail(int tweetId, int rank) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TweetDetail(null, tweetId: tweetId, hotRank: rank, newLink: true)),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
