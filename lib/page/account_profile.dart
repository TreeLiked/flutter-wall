import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/component/flexible_detail_bar.dart';
import 'package:iap_app/component/tweet/tweet_card.dart';
import 'package:iap_app/component/widget_sliver_future_builder.dart';
import 'package:iap_app/global/oss_canstant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/account_profile.dart';
import 'package:iap_app/model/account/account_setting.dart';
import 'package:iap_app/model/gender.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/page/common/avatar_origin.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/resources.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart';

class AccountProfilePage extends StatefulWidget {
  final String nick;
  final String avatarUrl;
  final String accountId;

  AccountProfilePage(this.accountId, this.nick, this.avatarUrl);

  @override
  State<StatefulWidget> createState() {
    return _AccountProfilePageState();
  }
}

class _AccountProfilePageState extends State<AccountProfilePage> with SingleTickerProviderStateMixin {
  TabController _tabController;

  var _pageList;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);

    _pageList = <StatefulWidget>[
      AccountProfileInfoPageView(
        accountId: widget.accountId,
        loadFinishCallback: () {},
      ),
      AccountProfileTweetPageView(
        accountId: widget.accountId,
      )
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        DefaultTabController(
            length: 2,
            child: Scaffold(
                body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) =>
                  _sliverBuilder(context, innerBoxIsScrolled),
              body: TabBarView(
                  // onPageChanged: _onPageChanged,
                  controller: _tabController,
                  children: _pageList),
            ))),
      ],
    );
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
          centerTitle: false,
          //标题居中
          elevation: 0.3,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.more_horiz,
                color: Colors.white,
              ),
              onPressed: () {
                BottomSheetUtil.showBottomSheetView(context, [
                  BottomSheetItem(
                      Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                      ),
                      '关注', () async {
                    ToastUtil.showToast(context, '关注成功');
                    Navigator.pop(context);
                  }),
                  BottomSheetItem(
                      Icon(
                        Icons.warning,
                        color: Colors.grey,
                      ),
                      '举报', () {
                    ToastUtil.showToast(context, '举报成功');
                    Navigator.pop(context);
                  }),
                ]);
              },
            ),
          ],
          leading: IconButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.maybePop(context);
            },
            tooltip: '返回',
            padding: const EdgeInsets.all(12.0),
            icon: Image.asset(PathConstant.ICON_GO_BACK_ARROW, color: Colors.white, width: 20),
          ),
          expandedHeight: 200,
          floating: false,
          pinned: true,
          snap: false,
          bottom: new TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              isScrollable: false,
              // indicatorColor: Colors.black87,
              controller: _tabController,
              tabs: [
                const Tab(child: Text('个人资料', style: TextStyle(color: null))),
                const Tab(child: Text('历史发布', style: TextStyle(color: null)))
              ]),
          flexibleSpace: FlexibleDetailBar(
              content: Padding(
                padding: EdgeInsets.only(top: ScreenUtil().setHeight(100)),
                child: Center(
                    child: Hero(
                        tag: 'avatar',
                        child: AccountAvatar(
                            avatarUrl: widget.avatarUrl + OssConstant.THUMBNAIL_SUFFIX,
                            whitePadding: true,
                            size: SizeConstant.TWEET_PROFILE_SIZE * 1.6,
                            onTap: () {
                              Navigator.push(context, PageRouteBuilder(pageBuilder:
                                  (BuildContext context, Animation animation, Animation secondaryAnimation) {
                                return new FadeTransition(
                                  opacity: animation,
                                  child: AvatarOriginPage(widget.avatarUrl),
                                );
                              }));
                            }))),
              ),
              background: Container(
                  decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(25))),
                  child: Stack(children: <Widget>[
                    Utils.showNetImage(
                      widget.avatarUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaY: 5,
                        sigmaX: 5,
                      ),
                      child: Container(
                        color: Colors.black38,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ]))))
    ];
  }
}

class AccountProfileInfoPageView extends StatefulWidget {
  final String accountId;
  final loadFinishCallback;

  AccountProfileInfoPageView({this.accountId, this.loadFinishCallback});

  @override
  _AccountProfileInfoPageView createState() => _AccountProfileInfoPageView();
}

class _AccountProfileInfoPageView extends State<AccountProfileInfoPageView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<AccountProfileInfoPageView> {
  String _nullText = "未知";
  double _iconSize = 17;
  Function _getProfileTask;

  Future<Account> getProfileInfo(BuildContext context) async {
    Account account = await MemberApi.getAccountDisplayProfile(widget.accountId);
    return account;
  }

  @override
  void initState() {
    super.initState();
    _getProfileTask = getProfileInfo;
  }

  @override
  Widget build(BuildContext context) {
    return CustomSliverFutureBuilder(
      futureFunc: (context) => _getProfileTask(context),
      builder: (context, data) => _buildBody(data),
    );
  }

  Widget _buildBody(Account account) {
    return Scaffold(
      // backgroundColor: Color(0xff191970),
      body: SingleChildScrollView(
          child: Container(
        padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            // _buildAvatarItem(account.avatarUrl),

            _titleItem('基础信息'),
            _buildNick(account.nick, account.profile.gender),
            Gaps.line,
            _buildSig(account.signature),

            Gaps.vGap30,
            _titleItem('个人档案'),
            _buildPersonInfo('name', account.profile.name, '姓名不可见'),
            Gaps.line,
            _buildPersonInfo('age', account.profile.age > 0 ? account.profile.age.toString() : null, '年龄不可见'),
            Gaps.line,
            _buildPersonInfo('region', _getRegionText(account.profile), '地区不可见'),

            Gaps.vGap30,
            _titleItem('社交信息'),
            _buildContactItem('phone', account.profile.mobile),
            Gaps.line,
            _buildContactItem('qq', account.profile.qq),
            Gaps.line,
            _buildContactItem('wechat', account.profile.wechat),

            // _buildItem('姓名', account.profile.name),
          ],
        ),
      )),
    );
  }

  Widget _buildNick(String nick, String male) {
    if (male != null) {
      male = male.toUpperCase();
      if (genderMap[male] == null) {
        male = null;
      }
    }
    return Container(
      margin: EdgeInsets.only(top: 15),
      alignment: Alignment.centerLeft,
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          _wrapIcon(LoadAssetIcon('profile/nick', width: _iconSize, height: _iconSize)),
          Gaps.hGap10,
          Flexible(
            flex: 8,
            child: Text(nick ?? TextConstant.TEXT_UNCATCH_ERROR,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: Dimens.font_sp14, fontWeight: FontWeight.w400)),
          ),
          Gaps.hGap10,
          (male == null || male == "UNKNOWN")
              ? Container(
                  height: 0,
                )
              : (male == "MALE"
                  ? Flexible(
                      flex: 1, child: LoadAssetIcon('profile/male', width: _iconSize, height: _iconSize))
                  : Flexible(
                      flex: 1, child: LoadAssetIcon('profile/female', width: _iconSize, height: _iconSize)))
        ],
      ),
    );
  }

  Widget _buildSig(String sig) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _wrapIcon(LoadAssetIcon('profile/sig', width: _iconSize, height: _iconSize)),
          Gaps.hGap10,
          Flexible(
            flex: 1,
            child: Text(sig ?? '未设置',
                softWrap: true,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: Dimens.font_sp14, fontWeight: FontWeight.w400)),
          ),
          _getCopyWidget(sig)
        ],
      ),
    );
  }

  _titleItem(String title) {
    return Container(child: Text(title, style: TextStyle(color: Colors.grey)));
  }

  _buildPersonInfo(String iconName, String value, String nullText) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        // direction: Axis.horizontal,
        children: <Widget>[
          _wrapIcon(LoadAssetIcon('profile/$iconName', width: _iconSize, height: _iconSize)),
          Gaps.hGap10,
          Flexible(
            flex: 1,
            child: Text(value ?? nullText,
                softWrap: true,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: value == null ? Colors.grey : null,
                    fontSize: value != null ? Dimens.font_sp14 : Dimens.font_sp13p5,
                    fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }

  String _getRegionText(AccountProfile profile) {
    if (StringUtil.isEmpty(profile.province)) {
      return null;
    } else {
      if (StringUtil.isEmpty(profile.city)) {
        return profile.province;
      } else {
        if (StringUtil.isEmpty(profile.district)) {
          return profile.province + " " + profile.city;
        } else {
          return profile.province + " " + profile.city + " " + profile.district;
        }
      }
    }
  }

  _buildContactItem(String iconName, String value) {
    bool isNull = StringUtil.isEmpty(value);
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        // direction: Axis.horizontal,
        children: <Widget>[
          _wrapIcon(LoadAssetIcon('profile/$iconName', width: _iconSize, height: _iconSize)),
          Gaps.hGap10,
          Flexible(
            flex: 1,
            child: Text(value ?? _nullText,
                softWrap: true,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: isNull ? Colors.grey : null,
                    fontSize: isNull ? Dimens.font_sp13p5 : Dimens.font_sp14,
                    fontWeight: FontWeight.w400)),
          ),
          _getCopyWidget(value)
        ],
      ),
    );
  }

  _wrapIcon(Widget icon) {
    return Container(
      width: 20,
      child: icon,
    );
  }

  _getCopyWidget(String value) {
    if (StringUtil.isEmpty(value)) {
      return Container(height: 0);
    } else {
      return GestureDetector(
        child: Padding(padding: EdgeInsets.only(left: 5), child: Images.copy),
        onTap: () {
          Utils.copyTextToClipBoard(value);
          ToastUtil.showToast(context, '复制成功');
        },
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class AccountProfileTweetPageView extends StatefulWidget {
  final String accountId;

  AccountProfileTweetPageView({Key key, this.accountId});

  @override
  _AccountProfileTweetPageView createState() => _AccountProfileTweetPageView();
}

class _AccountProfileTweetPageView extends State<AccountProfileTweetPageView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<AccountProfileTweetPageView> {
  Function _getSettingTask;

  int _currentPage = 1;

  List<BaseTweet> _accountTweets;

  EasyRefreshController _easyRefreshController;

  Future<Map<String, dynamic>> _getAccountSettingOrTweets(BuildContext context) async {
    Map<String, dynamic> settings = await MemberApi.getAccountSetting(passiveAccountId: widget.accountId);
    if (settings == null) {
      return null;
    } else {
      bool display = settings[AccountSettingKeys.displayHistoryTweet];
      if (display == null || display != true) {
        return {
          'displayHistoryTweet': false,
        };
      } else {
        List<BaseTweet> tweets = await _getTweets();
        if (!CollectionUtil.isListEmpty(tweets)) {
          _currentPage++;
          setState(() {
            this._accountTweets.addAll(tweets);
          });
          return {'displayHistoryTweet': true, 'tweets': tweets};
        }
        return {'displayHistoryTweet': true, 'tweets': []};
      }
    }
  }

  Future<List<BaseTweet>> _getTweets() async {
    List<BaseTweet> tweets = await TweetApi.queryAccountTweets(
        PageParam(_currentPage, pageSize: 6), widget.accountId,
        needAnonymous: false);

    return tweets;
  }

  Future<void> _loadMoreData() async {
    List<BaseTweet> tweets = await _getTweets();
    if (!CollectionUtil.isListEmpty(tweets)) {
      _currentPage++;
      setState(() {
        this._accountTweets.addAll(tweets);
      });
      _easyRefreshController.finishLoad(success: true, noMore: false);
    } else {
      _easyRefreshController.finishLoad(success: true, noMore: true);
    }
  }

  @override
  void initState() {
    super.initState();
    _accountTweets = new List();
    _easyRefreshController = EasyRefreshController();
    _getSettingTask = _getAccountSettingOrTweets;
  }

  @override
  void dispose() {
    _easyRefreshController.dispose();
    _accountTweets.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSliverFutureBuilder(
        futureFunc: _getSettingTask, builder: (context, data) => _buildBody(data));
  }

  _buildBody(Map<String, dynamic> dataMap) {
    bool displayHistoryTweet = dataMap[AccountSettingKeys.displayHistoryTweet];
    if (!displayHistoryTweet) {
      return Container(
          margin: EdgeInsets.only(top: 50),
          alignment: Alignment.topCenter,
          constraints: BoxConstraints(maxHeight: 100),
          child: Text('该用户关闭了显示历史内容'));
    }
    List<BaseTweet> tweets = dataMap['tweets'];
    if (tweets == null || tweets.length == 0) {
      return Container(
          margin: EdgeInsets.only(top: 50),
          alignment: Alignment.topCenter,
          constraints: BoxConstraints(maxHeight: 100),
          child: Text('该用户暂未发布过内容'));
    }

    return EasyRefresh(
      controller: _easyRefreshController,
      enableControlFinishLoad: true,
      footer: ClassicalFooter(
          textColor: Colors.grey,
          extent: 40.0,
          noMoreText: '没有更多了～',
          loadedText: '加载完成',
          loadFailedText: '加载失败',
          loadingText: '正在加载',
          loadText: '上滑加载',
          loadReadyText: '释放加载',
          showInfo: false,
          enableHapticFeedback: true,
          enableInfiniteLoad: true),
      onLoad: _loadMoreData,
      child: SingleChildScrollView(
        child: Column(
          children:
              _accountTweets.map((f) => TweetCard2(f, upClickable: false, downClickable: true)).toList(),
        ),
      ),
    );
    // return SingleChildScrollView(
    //     // child: EasyRefresh(
    //     //     footer: MaterialFooter(),
    //     //     onLoad: () => _getTweets(true),
    //     //     child:
    //     child:
    // )
    //     // ),
    //     );
  }

  @override
  bool get wantKeepAlive => true;
}
