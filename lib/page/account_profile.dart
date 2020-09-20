import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/api/unlike.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/component/flexible_detail_bar.dart';
import 'package:iap_app/component/tweet/tweet_card.dart';
import 'package:iap_app/component/tweet_delete_bottom_sheet.dart';
import 'package:iap_app/component/widget_sliver_future_builder.dart';
import 'package:iap_app/global/oss_canstant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/account_display_info.dart';
import 'package:iap_app/model/account/account_profile.dart';
import 'package:iap_app/model/account/account_setting.dart';
import 'package:iap_app/model/gender.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/page/common/avatar_origin.dart';
import 'package:iap_app/page/common/report_page.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/resources.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:provider/provider.dart';

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
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => _sliverBuilder(context, innerBoxIsScrolled),
      body: AccountProfileTweetPageView(),
    );
    return Stack(
      children: <Widget>[
        DefaultTabController(
            length: 2,
            child: Scaffold(
                body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) =>
                  _sliverBuilder(context, innerBoxIsScrolled),
              body: TabBar(

                  // onPageChanged: _onPageChanged,
                  controller: _tabController,
                  tabs: _pageList),
            ))),
      ],
    );
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
          centerTitle: false,
          // 标题居中
          elevation: 0.3,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.more_horiz,
                color: Colors.white,
              ),
              onPressed: () {
                List<BottomSheetItem> items = List();
                items.add(BottomSheetItem(
                    Icon(
                      Icons.warning,
                      color: Colors.grey,
                    ),
                    '举报', () {
                  Navigator.pop(context);
                  NavigatorUtils.goReportPage(context, ReportPage.REPORT_ACCOUNT, widget.accountId, "账户举报");
                }));
                if (Application.getAccountId != null && Application.getAccountId != widget.accountId) {
                  items.add(BottomSheetItem(Icon(Icons.do_not_disturb_on, color: Colors.red), '屏蔽此人', () {
                    Navigator.pop(context);
                    _showShieldedAccountBottomSheet();
                  }));
                }
                BottomSheetUtil.showBottomSheetView(context, items);
              },
            ),
          ],
          leading: IconButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.maybePop(context);
            },
            icon: Image.asset(PathConstant.ICON_GO_BACK_ARROW, color: Colors.white, width: 20),
          ),
          expandedHeight: 200,
          floating: false,
          pinned: true,
          snap: false,
          // bottom: new TabBar(
          //     labelColor: Colors.white,
          //     unselectedLabelColor: Colors.white70,
          //     isScrollable: false,
          //     indicatorSize: TabBarIndicatorSize.label,
          //
          //     // indicatorColor: Colors.black87,
          //     controller: _tabController,
          //     labelPadding: const EdgeInsets.all(0.0),
          //     tabs: [
          //       const Tab(child: Text('个人资料', style: TextStyle(color: null))),
          //       const Tab(child: Text('历史发布', style: TextStyle(color: null)))
          //     ]),

        flexibleSpace: Container(
          child: Text("123"),
        ),
          // flexibleSpace: FlexibleDetailBar(
          //     content: Padding(
          //       padding: EdgeInsets.only(top: ScreenUtil().setHeight(100)),
          //       child: Center(
          //           child: Hero(
          //               tag: 'avatar',
          //               child: AccountAvatar(
          //                   avatarUrl: widget.avatarUrl + OssConstant.THUMBNAIL_SUFFIX,
          //                   whitePadding: true,
          //                   size: SizeConstant.TWEET_PROFILE_SIZE * 1.6,
          //                   cache: true,
          //                   onTap: () {
          //                     Navigator.push(context, PageRouteBuilder(pageBuilder:
          //                         (BuildContext context, Animation animation, Animation secondaryAnimation) {
          //                       return new FadeTransition(
          //                           opacity: animation, child: AvatarOriginPage(widget.avatarUrl));
          //                     }));
          //                   }))),
          //     ),
          //     background: Container(
          //         decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(25))),
          //         child: Stack(children: <Widget>[
          //           Utils.showNetImage(
          //             widget.avatarUrl,
          //             width: double.infinity,
          //             height: double.infinity,
          //             fit: BoxFit.cover,
          //           ),
          //           BackdropFilter(
          //             filter: ImageFilter.blur(
          //               sigmaY: 5,
          //               sigmaX: 5,
          //             ),
          //             child: Container(
          //               color: Colors.black38,
          //               width: double.infinity,
          //               height: double.infinity,
          //             ),
          //           ),
          //         ])))

      )
    ];
  }

  _showShieldedAccountBottomSheet() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleConfirmBottomSheet(
            tip: "您确认屏蔽此用户，屏蔽后此用户的内容将对您不可见",
            onTapDelete: () async {
              Utils.showDefaultLoading(Application.context);
              Result r = await UnlikeAPI.unlikeAccount(widget.accountId.toString());
              NavigatorUtils.goBack(Application.context);
              if (r == null) {
                ToastUtil.showToast(Application.context, TextConstant.TEXT_SERVICE_ERROR);
              } else {
                if (r.isSuccess) {
                  final _tweetProvider = Provider.of<TweetProvider>(Application.context);
                  _tweetProvider.deleteByAccount(widget.accountId);
                  ToastUtil.showToast(Application.context, '屏蔽成功，您将不会在看到此用户的内容');
                  NavigatorUtils.goBack(Application.context);
                } else {
                  ToastUtil.showToast(Application.context, "用户屏蔽失败");
                }
              }
            });
      },
    );
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
  String _nullText = "用户未设置";
  double _iconSize = 25;
  Function _getProfileTask;
  bool isDark;

  Future<AccountDisplayInfo> getProfileInfo(BuildContext context) async {
    AccountDisplayInfo account = await MemberApi.getAccountDisplayProfile(widget.accountId);
    return account;
  }

  @override
  void initState() {
    super.initState();
    _getProfileTask = getProfileInfo;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    isDark = ThemeUtils.isDark(context);
    return CustomSliverFutureBuilder(
      futureFunc: (context) => _getProfileTask(context),
      builder: (context, data) => _buildBody(data),
    );
  }

  Widget _buildBody(AccountDisplayInfo account) {
    if (account == null) {
      return Center(child: Text('用户信息获取失败'));
    }
    return Scaffold(
      // backgroundColor: Color(0xff191970),
      // 设置没有高度的 appbar，目的是为了设置状态栏的颜色
      body: SingleChildScrollView(
          child: Container(
        padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            // _buildAvatarItem(account.avatarUrl),
            _titleItem('基础信息'),
            _buildNick(account),
            _buildSig(account.signature),

            Gaps.vGap30,
            _titleItem('个人档案'),
            _buildPersonInfo('line_in_circle', Colors.brown, account.name, account.displayName,
                fallbackText: "姓名不可见"),
            _buildPersonInfo(
                'voice', Colors.lightBlue, account.age > 0 ? "${account.age}岁" : null, account.displayAge,
                fallbackText: "年龄不可见"),
            _buildPersonInfo('search', Colors.green, _getRegionText(account), account.displayRegion,
                fallbackText: "地区不可见"),
            _buildPersonInfo(
                'count',
                Colors.green,
                _getCampusInfoText(account),
                account.displayInstitute ||
                    account.displayCla ||
                    account.displayMajor ||
                    account.displayGrade,
                fallbackText: "学院信息未设置"),

            Gaps.vGap30,
            _titleItem('社交信息'),
            _buildContactItem('phone', Colors.brown, account.mobile, account.displayPhone),
            _buildContactItem('qq25', Colors.lightBlue, account.qq, account.displayQQ),
            _buildContactItem('wechat', Colors.green, account.wechat, account.displayWeChat),

            // _buildItem('姓名', account.profile.name),
          ],
        ),
      )),
    );
  }

  Widget _buildNick(AccountDisplayInfo account) {
    String male;
    if (account.displaySex) {
      if (account.gender != null) {
        male = account.gender.toUpperCase();
      }
    }
    return Container(
      margin: EdgeInsets.only(top: 15),
      alignment: Alignment.centerLeft,
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          _wrapIcon(LoadAssetSvg(
            'people_nick',
            width: _iconSize - 5,
            height: _iconSize - 5,
            color: Colors.lightBlue,
          )),
          Gaps.hGap10,
          Flexible(
            flex: 8,
            child: Text(account.nick ?? TextConstant.TEXT_UN_CATCH_ERROR,
                softWrap: true,
                style: MyDefaultTextStyle.getTweetNickStyle(Dimens.font_sp14, context: context, bold: false)),
          ),
          Gaps.hGap10,
          (male == null || male == "UNKNOWN")
              ? Gaps.empty
              : (male == "MALE"
                  ? Flexible(
                      flex: 1,
                      child: LoadAssetSvg('male', width: _iconSize, height: _iconSize, color: Colors.blue))
                  : Flexible(
                      flex: 1,
                      child: LoadAssetSvg('female',
                          width: _iconSize, height: _iconSize, color: Colors.pinkAccent)))
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
          _wrapIcon(LoadAssetSvg(
            'wenjian',
            width: _iconSize,
            height: _iconSize,
            color: Colors.lightBlue,
          )),
          Gaps.hGap10,
          Flexible(
            flex: 1,
            child: Text(sig ?? '签名未设置',
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(color: Colors.grey, fontSize: Dimens.font_sp14, fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }

  _titleItem(String title) {
    return Container(child: Text(title, style: TextStyle(color: Colors.grey)));
  }

  _buildPersonInfo(String svgName, Color color, String value, bool display, {String fallbackText = "不可见"}) {
    bool hasVal = value != null && value.trim().length > 0;

    return Container(
      // margin: EdgeInsets.only(top: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _wrapIcon(LoadAssetSvg(svgName, width: _iconSize, height: _iconSize, color: color)),
          Gaps.hGap10,
          Flexible(
            flex: 1,
            child: Text(display ? (hasVal ? value : '用户未设置') : fallbackText,
                softWrap: true,
                style: TextStyle(
                    color: !hasVal || !display ? Colors.grey : null,
                    fontSize: hasVal && display ? Dimens.font_sp15 : Dimens.font_sp14,
                    fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }

  String _getRegionText(AccountDisplayInfo profile) {
    if (StringUtil.isEmpty(profile.province)) {
      return null;
    } else {
      if (StringUtil.isEmpty(profile.city)) {
        return profile.province;
      } else {
        if (StringUtil.isEmpty(profile.district)) {
          return profile.province + "，" + profile.city;
        } else {
          return profile.province + "，" + profile.city + "，" + profile.district;
        }
      }
    }
  }

  String _getCampusInfoText(AccountDisplayInfo profile) {
    StringBuffer sb = StringBuffer();
    bool writeBefore = false;
    if (profile.displayInstitute) {
      if (!StringUtil.isEmpty(profile.instituteName)) {
        sb.write(_writeSomething(writeBefore, profile.instituteName));
        writeBefore = true;
      }
    }
    if (profile.displayMajor) {
      if (!StringUtil.isEmpty(profile.major)) {
        sb.write(_writeSomething(writeBefore, profile.major));

        writeBefore = true;
      }
    }
    if (profile.displayCla) {
      if (!StringUtil.isEmpty(profile.cla)) {
        sb.write(_writeSomething(writeBefore, profile.cla));

        writeBefore = true;
      }
    }
    if (profile.displayGrade) {
      if (!StringUtil.isEmpty(profile.grade)) {
        sb.write(_writeSomething(writeBefore, profile.grade));
      }
    }
    return sb.toString();
  }

  _writeSomething(bool writeBefore, String value) {
    return writeBefore ? "，$value" : "$value";
  }

  _buildContactItem(String svgName, Color color, String value, bool display) {
    bool isNull = StringUtil.isEmpty(value);
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // direction: Axis.horizontal,
        children: <Widget>[
          _wrapIcon(LoadAssetSvg(
            '$svgName',
            width: _iconSize,
            height: _iconSize,
            color: color,
          )),
          Gaps.hGap10,
          Flexible(
            flex: 1,
            child: Text(!display ? '用户未开放' : (value ?? _nullText),
                softWrap: true,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: isNull ? Colors.grey : null,
                    fontSize: isNull ? Dimens.font_sp14 : Dimens.font_sp15,
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
  Function _onLoad;

  int _currentPage = 1;

  bool display = false;
  bool initialing = true;
  List<BaseTweet> _accountTweets = List();

  EasyRefreshController _easyRefreshController;

  Future<List<BaseTweet>> _getTweets() async {
    List<BaseTweet> tweets =
        await TweetApi.queryOtherTweets(PageParam(_currentPage, pageSize: 5), widget.accountId);

    return tweets;
  }

  Future<void> _initRefresh() async {
    setState(() {
      _currentPage = 1;
    });
    List<BaseTweet> tweets = await _getTweets();
    if (!CollectionUtil.isListEmpty(tweets)) {
      _currentPage++;
      setState(() {
        this.initialing = false;
        this._accountTweets.addAll(tweets);
      });
      _easyRefreshController.finishRefresh(success: true, noMore: false);
    } else {
      setState(() {
        this.initialing = false;
      });
      _easyRefreshController.finishRefresh(success: true, noMore: true);
    }
  }

  void _loadMoreData() async {
    print("loadmore---------$_currentPage");
    List<BaseTweet> tweets = await _getTweets();
    print("${tweets.length}");
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
    _initRefresh();
    _easyRefreshController = EasyRefreshController();
    _onLoad = _loadMoreData;
  }

  @override
  void dispose() {
    _easyRefreshController.dispose();
    _accountTweets.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (initialing) {
      return WidgetUtil.getLoadingAnimation();
    }
    if (_accountTweets == null || _accountTweets.length == 0) {
      return Container(
          margin: EdgeInsets.only(top: 50),
          alignment: Alignment.topCenter,
          constraints: BoxConstraints(maxHeight: 100),
          color: Colors.white,
          child: Text(
            '用户关闭历史或未发布过内容',
            style: const TextStyle(fontSize: Dimens.font_sp14),
          ));
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
        onLoad: () => _onLoad(),
        child: _accountTweets == null || _accountTweets.length == 0
            ? Container(
                margin: EdgeInsets.only(top: 50),
                alignment: Alignment.topCenter,
                constraints: BoxConstraints(maxHeight: 100),
                child: Text('该用户暂未发布过内容'))
            : ListView.builder(
                primary: false,
                shrinkWrap: true,
                itemCount: _accountTweets.length,
                itemBuilder: (context, index) {
                  return TweetCard2(_accountTweets[index],
                      displayLink: false, upClickable: false, downClickable: false, displayPraise: true);
                }));
  }

  @override
  bool get wantKeepAlive => true;
}
