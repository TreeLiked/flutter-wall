import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/component/tweet/tweet_card.dart';
import 'package:iap_app/component/widget_sliver_future_builder.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/widget_util.dart';

class HistoryPushedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HistoryPushedPage();
  }
}

class _HistoryPushedPage extends State<HistoryPushedPage> {
  EasyRefreshController _easyRefreshController;
  Function _getPushedTask;

  List<BaseTweet> _accountTweets = List();

  int _currentPage = 1;

  Future<List<BaseTweet>> _getTweets(BuildContext context) async {
    List<BaseTweet> tweets = await TweetApi.querySelfTweets(
        PageParam(_currentPage, pageSize: 6), Application.getAccountId,
        needAnonymous: true);

    if (!CollectionUtil.isListEmpty(tweets)) {
      setState(() {
        _currentPage++;
        this._accountTweets.addAll(tweets);
      });
    }
    return tweets;
  }

  @override
  void initState() {
    super.initState();
    _easyRefreshController = EasyRefreshController();
    _getPushedTask = _getTweets;
  }

  @override
  void dispose() {
    _easyRefreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        centerTitle: '我的发布',
      ),
      body: CustomSliverFutureBuilder(
          futureFunc: _getPushedTask, builder: (context, data) => _buildBody(context, data)),
    );
  }

  _buildBody(BuildContext context, dynamic data) {
    return EasyRefresh(
      controller: _easyRefreshController,
      enableControlFinishLoad: true,
      footer: ClassicalFooter(
          textColor: Colors.grey,
          extent: 40.0,
          noMoreText: '没有更多了～',
          loadedText: '加载完成',
          loadFailedText: '加载失败',
          loadingText: '正在加载...',
          loadText: '上滑加载',
          loadReadyText: '释放加载',
          showInfo: false,
          enableHapticFeedback: true,
          enableInfiniteLoad: true),
      onLoad: _loadMoreData,
      child: !CollectionUtil.isListEmpty(_accountTweets)
          ? ListView.builder(
              itemCount: _accountTweets.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return TweetCard2(_accountTweets[index],
                    upClickable: false, downClickable: false, displayPraise: false, displayComment: false);
              })
          : Center(
              child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: LoadAssetImage(ThemeUtils.isDark(context) ? "no_data_dark" : 'no_data',
                      width: ScreenUtil().setWidth(250)))),
    );
  }

  Future<void> _loadMoreData() async {
    List<BaseTweet> tweets = await _getTweets(context);
    if (!CollectionUtil.isListEmpty(tweets)) {
      // _currentPage++;
      // setState(() {
      //   this._accountTweets.addAll(tweets);
      // });
      _easyRefreshController.finishLoad(success: true, noMore: false);
    } else {
      _easyRefreshController.finishLoad(success: true, noMore: true);
    }
  }
}
