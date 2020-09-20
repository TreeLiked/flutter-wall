import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/api/unlike.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/component/flexible_detail_bar.dart';
import 'package:iap_app/component/tweet/tweet_card.dart';
import 'package:iap_app/component/tweet_delete_bottom_sheet.dart';
import 'package:iap_app/component/widget_sliver_future_builder.dart';
import 'package:iap_app/global/oss_canstant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account/account_display_info.dart';
import 'package:iap_app/model/gender.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/page/common/avatar_origin.dart';
import 'package:iap_app/page/common/report_page.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/color_style.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:provider/provider.dart';

import '../../application.dart';

class AccountProfile extends StatefulWidget {
  final String nick;
  final String avatarUrl;
  final String accountId;

  AccountProfile(this.accountId, this.nick, this.avatarUrl);

  @override
  State<StatefulWidget> createState() {
    return _AccountProfileState();
  }
}

class _AccountProfileState extends State<AccountProfile> {
  Function _getProfileTask;

  AccountDisplayInfo account;

  EasyRefreshController _hisTweetController;
  Function _onLoadHisTweet;
  bool display = false;
  bool initialing = true;
  List<BaseTweet> _accountTweets = List();
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadProfileInfo();
    _initRefresh();
    _hisTweetController = EasyRefreshController();
    _onLoadHisTweet = _loadMoreData;
  }

  void _loadProfileInfo() async {
    AccountDisplayInfo account = await MemberApi.getAccountDisplayProfile(widget.accountId);
    setState(() {
      this.account = account;
    });
  }

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
      _hisTweetController.finishRefresh(success: true, noMore: false);
    } else {
      setState(() {
        this.initialing = false;
      });
      _hisTweetController.finishRefresh(success: true, noMore: true);
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
      _hisTweetController.finishLoad(success: true, noMore: false);
    } else {
      _hisTweetController.finishLoad(success: true, noMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: EasyRefresh(
            controller: _hisTweetController,
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
            onLoad: () => _onLoadHisTweet(),
            child: CustomScrollView(slivers: <Widget>[
              SliverAppBar(
                  pinned: true,
                  snap: false,
                  floating: false,
                  expandedHeight: ScreenUtil().setHeight(350),
                  elevation: 0.5,
                  titleSpacing: 1.2,
                  // title: Text(widget.nick, style: const TextStyle(fontSize: Dimens.font_sp16,color: Colors.white)),
                  centerTitle: true,
                  leading: IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Navigator.maybePop(context);
                    },
                    icon: Image.asset(PathConstant.ICON_GO_BACK_ARROW, color: Colors.white, width: 20),
                  ),
                  actions: [
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
                          NavigatorUtils.goReportPage(
                              context, ReportPage.REPORT_ACCOUNT, widget.accountId, "账户举报");
                        }));
                        if (Application.getAccountId != null &&
                            Application.getAccountId != widget.accountId) {
                          items.add(
                              BottomSheetItem(Icon(Icons.do_not_disturb_on, color: Colors.red), '屏蔽此人', () {
                            Navigator.pop(context);
                            _showShieldedAccountBottomSheet();
                          }));
                        }
                        BottomSheetUtil.showBottomSheetView(context, items);
                      },
                    ),
                  ],
                  flexibleSpace: ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: const Radius.circular(5.0), bottomRight: const Radius.circular(5.0)),
                    child: FlexibleDetailBar(
                        content: Container(
                          padding: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
                          child: Center(
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Hero(
                                  tag: 'avatar',
                                  child: AccountAvatar(
                                      avatarUrl: widget.avatarUrl + OssConstant.THUMBNAIL_SUFFIX,
                                      whitePadding: true,
                                      size: SizeConstant.TWEET_PROFILE_SIZE * 1.8,
                                      cache: true,
                                      gender: calGender(account),
                                      onTap: () {
                                        Navigator.push(context, PageRouteBuilder(pageBuilder:
                                            (BuildContext context, Animation animation,
                                                Animation secondaryAnimation) {
                                          return new FadeTransition(
                                              opacity: animation, child: AvatarOriginPage(widget.avatarUrl));
                                        }));
                                      })),
                              Gaps.vGap8,
                              Text(
                                widget.nick,
                                style: const TextStyle(fontSize: Dimens.font_sp16),
                              ),
                              Gaps.vGap10,
                              Text(
                                account == null ? "" : account.signature ?? "",
                                style: const TextStyle(fontSize: Dimens.font_sp13p5, color: Colors.white70),
                              ),
                            ],
                          )),
                        ),
                        background: Stack(children: <Widget>[
                          Utils.showNetImage(
                            widget.avatarUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaY: 4,
                              sigmaX: 4,
                            ),
                            child: Container(
                              decoration: BoxDecoration(color: Colors.black12),
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ])),
                  )),
              SliverToBoxAdapter(
                child: Container(
                    margin: EdgeInsets.only(top: 20, left: 15.0, right: 20.0, bottom: 10),
                    child: account == null
                        ? SpinKitThreeBounce(
                            color: Colors.amber,
                            size: 20,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                  flex: 3,
                                  fit: FlexFit.loose,
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(children: [
                                      WidgetSpan(
                                          child: _wrapIcon(LoadAssetSvg("count",
                                              width: 19, height: 19, color: Colors.green))),
                                      TextSpan(
                                          text: _getCampusInfoText(),
                                          style: TextStyle(
                                              fontSize: Dimens.font_sp15,
                                              color: MyColorStyle.getTweetReplyBodyColor(context: context)))
                                    ]),
                                  )),
                              Flexible(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () {
                                      BottomSheetUtil.showBottomSheet(
                                          context, 0.5, _buildDetailProfileInfo());
                                    },
                                    child: Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      alignment: WrapAlignment.center,
                                      children: [
                                        Text(
                                          "查看更多",
                                          style:
                                              const TextStyle(color: Colors.grey, fontSize: Dimens.font_sp14),
                                        ),
                                        Icon(Icons.arrow_right, color: Colors.grey)
                                      ],
                                    ),
                                  )),
                            ],
                          )),
              ),
              CollectionUtil.isListEmpty(_accountTweets)
                  ? SliverToBoxAdapter(
                      child: Container(
                          margin: EdgeInsets.only(top: 50),
                          height: 800,
                          alignment: Alignment.topCenter,
                          constraints: BoxConstraints(maxHeight: 100),
                          child: Text(
                            '该用户暂未发布过内容',
                            style: TextStyle(fontSize: Dimens.font_sp15, letterSpacing: 1.3),
                          )),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return TweetCard2(_accountTweets[index],
                              displayLink: false,
                              upClickable: false,
                              downClickable: false,
                              myNickClickable: false,
                              needLeftProfile: false,
                              displayPraise: true);
                        },
                        childCount: _accountTweets.length,
                      ),
                    ),
            ])));
  }

  calGender(AccountDisplayInfo acc) {
    int gender = -1;
    if (acc == null) {
      return gender;
    }
    if (acc.displaySex) {
      if (!StringUtil.isEmpty(acc.gender)) {
        String s = acc.gender.toUpperCase();
        if (s == "MALE") {
          gender = 0;
        } else if (s == "FEMALE") {
          gender = 1;
        }
      }
    }
    return gender;
  }

  String _getCampusInfoText() {
    StringBuffer sb = StringBuffer();
    bool writeBefore = false;
    if (account.displayInstitute) {
      if (!StringUtil.isEmpty(account.instituteName)) {
        sb.write(_writeSomething(writeBefore, account.instituteName));
        writeBefore = true;
      }
    }
    if (account.displayMajor) {
      if (!StringUtil.isEmpty(account.major)) {
        sb.write(_writeSomething(writeBefore, account.major));

        writeBefore = true;
      }
    }
    if (account.displayCla) {
      if (!StringUtil.isEmpty(account.cla)) {
        sb.write(_writeSomething(writeBefore, account.cla));

        writeBefore = true;
      }
    }
    if (account.displayGrade) {
      if (!StringUtil.isEmpty(account.grade)) {
        sb.write(_writeSomething(writeBefore, account.grade));
      }
    }
    if (sb.length == 0) {
      sb.write("无专业信息");
    }
    return sb.toString();
  }

  String _buildRegionText() {
    if (StringUtil.isEmpty(account.province)) {
      return "地区不可见";
    } else {
      if (StringUtil.isEmpty(account.city)) {
        return account.province;
      } else {
        if (StringUtil.isEmpty(account.district)) {
          return account.province + "，" + account.city;
        } else {
          return account.province + "，" + account.city + "，" + account.district;
        }
      }
    }
  }

  _wrapIcon(Widget icon) {
    return Container(
      width: 25,
      child: icon,
    );
  }

  _writeSomething(bool writeBefore, String value) {
    return writeBefore ? "，$value" : "$value";
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

  _buildDetailProfileInfo() {
    if (account == null) {
      return Center(
        child: Text("暂无可用信息"),
      );
    }
    return Container(
      margin: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0, bottom: 20.0),
      child: Column(
        children: [
          _buildSingleContainer(
              Icon(
                Icons.ac_unit,
                color: Colors.green,
              ),
              "基础资料",
              {
                "昵称": _buildSingleTextValue(account.nick),
                "签名": _buildSingleTextValue(account.signature ?? "未设置"),
              }),
          _buildSingleContainer(Icon(Icons.dashboard, color: Colors.blueAccent), "个人档案", {
            "姓名": _buildSingleTextValue(account.displayName ? account.name : "姓名不可见"),
            "性别": _buildGenderWidget(),
            "年龄": _buildSingleTextValue(
                account.displayAge && account.age > 0 ? account.age.toString() : "年龄不可见"),
            "地区": _buildSingleTextValue(_buildRegionText()),
            "专业": _buildSingleTextValue(_getCampusInfoText()),
          }),
          _buildSingleContainer(
              Icon(
                Icons.contacts,
                color: Colors.amber,
              ),
              "联系资料",
              {
                "手机": _buildSingleTextValue(account.displayPhone ? account.mobile : "未知"),
                "Q  Q": _buildSingleTextValue(account.displayQQ ? account.qq : "未知"),
                "微信": _buildSingleTextValue(account.displayWeChat ? account.wechat : "未知"),
              }),
        ],
      ),
    );
  }

  _buildSingleContainer(Icon icon, String title, Map<String, Widget> items) {
    Widget genItems(Map<String, Widget> items) {
      List<Widget> ws = new List();
      items.forEach((key, value) {
        ws.add(Container(
          margin: const EdgeInsets.only(bottom: 5.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 10.0),
                child: Text(
                  key,
                  style: TextStyle(fontSize: Dimens.font_sp15, color: Colors.grey),
                ),
              ),
              value,
            ],
          ),
        ));
      });
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ws,
      );
    }

    return Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon.icon, size: 20, color: icon.color),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(title, style: TextStyle(fontSize: Dimens.font_sp16)),
                )
              ],
            ),
            Gaps.vGap10,
            Gaps.line,
            genItems(items),
          ],
        ));
  }

  Widget _buildSingleTextValue(String text) {
    if (text == null || text.trim().length == 0) {
      text = "不可见";
    }
    return Text(text);
  }

  Widget _buildGenderWidget() {
    if (account.displaySex) {
      if (!StringUtil.isEmpty(account.gender)) {
        String t = account.gender.toUpperCase();
        if (t == Gender.FEMALE.name) {
          return Container(
            padding: const EdgeInsets.all(3.0),
            width: 20,
            height: 20,
            child: CircleAvatar(
              backgroundColor: Colors.pinkAccent,
              child: LoadAssetSvg(
                'female',
                width: 20,
                height: 20,
                color: Colors.white,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
        if (t == Gender.MALE.name) {
          return Container(
            padding: const EdgeInsets.all(3.0),
            width: 20,
            height: 20,
            child: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: LoadAssetSvg(
                'male',
                width: 20,
                height: 20,
                color: Colors.white,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
      }
    }
    return _buildSingleTextValue("未知");
  }
}
