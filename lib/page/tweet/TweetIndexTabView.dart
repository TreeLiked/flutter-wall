import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/component/tweet/tweet_card.dart';
import 'package:iap_app/component/tweet/tweet_no_data_view.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/page/tweet/tweet_comment_wrapper.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/message_util.dart';
import 'package:iap_app/util/page_shared.widget.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/tweet_reply_util.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TweetIndexTabView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TweetIndexTabViewState();
  }
}

class _TweetIndexTabViewState extends State<TweetIndexTabView> {
  RefreshController _refreshController = PageSharedWidget.tabIndexRefreshController;

//  List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  AnimationController animationController;

  ScrollController _scrollController = PageSharedWidget.homepageScrollController;

  PersistentBottomSheetController _bottomSheetController;

  TweetProvider tweetProvider;

  int _currentPage = 1;

  Widget loadingIconStatic =
      SizedBox(width: 25.0, height: 25.0, child: const CupertinoActivityIndicator(animating: false));

  @override
  Widget build(BuildContext context) {
    tweetProvider = Provider.of<TweetProvider>(context);
    return Scaffold(
      // bottomSheet: Container(
      //   child: Text("12333213"),
      // ),
      body: Consumer<TweetProvider>(builder: (context, provider, _) {
        var tweets = provider.displayTweets;
        return Listener(
            onPointerDown: (_) {
              closeReplyInput();
            },
            child: Scrollbar(
//          controller: _scrollController,
                child: SmartRefresher(
              enablePullUp: tweets != null && tweets.length > 0,
              enablePullDown: true,
              primary: false,
              scrollController: _scrollController,
              controller: _refreshController,
              cacheExtent: 20,
              header: ClassicHeader(
                idleText: '',
                releaseText: '',
                refreshingText: '',
                completeText: '',
                refreshStyle: RefreshStyle.Follow,
                idleIcon: loadingIconStatic,
                releaseIcon: loadingIconStatic,
                completeDuration: Duration(milliseconds: 0),
                completeIcon: null,
              ),
              footer: ClassicFooter(
                loadingText: '正在加载...',
                canLoadingText: '释放以加载更多',
                noDataText: '到底了哦',
                idleText: '继续上滑',
              ),
              child: tweets == null
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: WidgetUtil.getLoadingAnimation(),
                    )
                  : tweets.length == 0
                      ? TweetNoDataView(onTapReload: () {
                          if (_refreshController != null) {
                            _refreshController.resetNoData();
                            _refreshController.requestRefresh();
                          }
                        })
                      : ListView.builder(
                          primary: true,
                          itemCount: tweets.length,
                          itemBuilder: (context, index) {
                            return TweetCard2(
                              tweets[index],
                              displayExtra: true,
                              displayPraise: true,
                              displayComment: true,
                              displayLink: true,
                              canPraise: true,
                              indexInList: index,
                              onClickComment: (TweetReply subReply, String targetNick, String targetAccountId) {
                                _bottomSheetController =
                                    Scaffold.of(context).showBottomSheet((context) => Container(
                                            child: TweetIndexCommentWrapper(
                                          // 如果是子回复 ，reply不为空
                                          replyType: subReply == null ? 1 : 2,
                                          showAnonymous: subReply == null,
                                          hintText: targetNick != null ? '回复: $targetNick' : '评论',
                                          onSend: (String value, bool anonymous) async {
                                            TweetReply reply = TRUtil.assembleReply(
                                                tweets[index], value, anonymous, true, subReply: subReply);

                                            await TRUtil.publicReply(context, reply,
                                                (bool success, TweetReply newReply) {
                                              if (success) {
                                                closeReplyInput();
                                                final _tweetProvider = Provider.of<TweetProvider>(context);
                                                _tweetProvider.updateReply(context, newReply);
                                              } else {
                                                ToastUtil.showToast(context, "评论失败，请稍后再试");
                                              }
                                            });
                                          },
                                        )));
                              },
                            );
                          }),
              onRefresh: () => _onRefresh(context),
              onLoading: _onLoading,
            )));
      }),
    );
  }

  void closeReplyInput() {
    if (_bottomSheetController != null) {
      _bottomSheetController.close();
    }
  }

  Future<void> _onRefresh(BuildContext context) async {
    print(''
        'On refresh');
    _refreshController.resetNoData();
    _currentPage = 1;
    List<BaseTweet> temp = await getData(_currentPage);
    tweetProvider.update(temp, clear: true, append: false);
    MessageUtil.clearTabIndexTweetCnt();
    if (temp == null) {
      _refreshController.refreshFailed();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  void initData() async {
    List<BaseTweet> temp = await getData(1);
    tweetProvider.update(temp, clear: true, append: false);
    _refreshController.refreshCompleted();

  }

  Future<void> _onLoading() async {
    List<BaseTweet> temp = await getData(++_currentPage);
    tweetProvider.update(temp, append: true, clear: false);
    if (CollectionUtil.isListEmpty(temp)) {
      _currentPage--;
      _refreshController.loadNoData();
    } else {
      _refreshController.loadComplete();
    }
  }

  Future getData(int page) async {
    print('get data ------$page------');
    List<BaseTweet> pbt = await (TweetApi.queryTweets(PageParam(
      page,
      pageSize: 10,
      orgId: Application.getOrgId,
//        types: ((typesFilterProvider.selectAll ?? true) ? null : typesFilterProvider.selTypeNames)))
      types: null,
    )));
    return pbt;
  }
}
