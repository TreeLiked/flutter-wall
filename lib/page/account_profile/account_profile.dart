import 'dart:ui';

import 'package:extended_text/extended_text.dart';
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
import 'package:iap_app/global/color_constant.dart';
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
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/color_style.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/umeng_util.dart';
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
  bool _initAccount = true;
  bool _initTweet = true;

  EasyRefreshController _hisTweetController;
  Function _onLoadHisTweet;
  bool display = false;
  List<BaseTweet> _accountTweets;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadProfileInfo();
    _initRefresh();
    _hisTweetController = EasyRefreshController();
    _onLoadHisTweet = _loadMoreData;
    UMengUtil.userGoPage(UMengUtil.PAGE_ACCOUNT_PROFILE);
  }

  void _loadProfileInfo() async {
    AccountDisplayInfo account =
        await MemberApi.getAccountDisplayProfile(widget.accountId);
    setState(() {
      _initAccount = false;
      this.account = account;
    });
  }

  Future<List<BaseTweet>> _getTweets() async {
    List<BaseTweet> tweets = await TweetApi.queryOtherTweets(
        PageParam(_currentPage, pageSize: 5), widget.accountId);
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
        if (_accountTweets == null) {
          _accountTweets = List();
        }
        this._initTweet = false;
        this._accountTweets.addAll(tweets);
      });
      _hisTweetController.finishRefresh(success: true, noMore: false);
    } else {
      setState(() {
        // if (_accountTweets == null) {
        //   _accountTweets = List();
        // }
        this._initTweet = false;
      });
      _hisTweetController.finishRefresh(success: true, noMore: true);
    }
  }

  void _loadMoreData() async {
    List<BaseTweet> tweets = await _getTweets();
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
    bool isDark = ThemeUtils.isDark(context);
    return Scaffold(
        backgroundColor: ThemeUtils.getBackColor(context),
        body: Stack(
          children: [
            EasyRefresh(
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
                      expandedHeight: ScreenUtil().setWidth(580),
                      elevation: 0.5,
                      titleSpacing: 1.2,
                      title: Text(
                        "${widget.nick ?? ''}的资料",
                        style: pfStyle.copyWith(fontSize: Dimens.font_sp16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      centerTitle: true,
                      leading: IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          Navigator.maybePop(context);
                        },
                        icon: Image.asset(
                          PathConstant.ICON_GO_BACK_ARROW,
                          width: 20,
                          color: isDark ? Colors.grey : Colors.black54,
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(
                            Icons.more_horiz,
                            color: isDark ? Colors.grey : Colors.black54,
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
                                  context,
                                  ReportPage.REPORT_ACCOUNT,
                                  widget.accountId,
                                  "账户举报");
                            }));
                            if (Application.getAccountId != null &&
                                Application.getAccountId != widget.accountId) {
                              items.add(BottomSheetItem(
                                  Icon(Icons.do_not_disturb_on,
                                      color: Colors.orangeAccent),
                                  '屏蔽此人', () {
                                Navigator.pop(context);
                                _showShieldedAccountBottomSheet();
                              }));
                            }
                            BottomSheetUtil.showBottomSheetView(context, items);
                          },
                        ),
                      ],
                      flexibleSpace: ClipRRect(
                        child: FlexibleDetailBar(
                            content: Container(
                              // color: Colors.blueGrey,
                              alignment: Alignment.bottomCenter,
                              margin: EdgeInsets.only(
                                  top: ScreenUtil.statusBarHeight,
                                  left: 30.0,
                                  right: 30.0,
                                  bottom: 10.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Hero(
                                      tag: 'avatar',
                                      child: AccountAvatar(
                                          avatarUrl: widget.avatarUrl +
                                              OssConstant.THUMBNAIL_SUFFIX,
                                          whitePadding: true,
                                          size:
                                              SizeConstant.TWEET_PROFILE_SIZE *
                                                  1.5,
                                          cache: true,
                                          gender: calGender(account),
                                          onTap: () {
                                            Navigator.push(context,
                                                PageRouteBuilder(pageBuilder:
                                                    (BuildContext context,
                                                        Animation animation,
                                                        Animation
                                                            secondaryAnimation) {
                                              return new FadeTransition(
                                                  opacity: animation,
                                                  child: AvatarOriginPage(
                                                      widget.avatarUrl));
                                            }));
                                          })),
                                  Gaps.vGap8,
                                  Text(
                                    widget.nick ?? "",
                                    style: pfStyle.copyWith(
                                        fontSize: Dimens.font_sp15,
                                        color: !isDark
                                            ? Colors.black
                                            : Colors.white70),
                                  ),
                                  Gaps.vGap10,
                                  Text(
                                    account == null
                                        ? ""
                                        : account.signature ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: pfStyle.copyWith(
                                        fontSize: Dimens.font_sp13p5,
                                        color: isDark
                                            ? Colors.grey
                                            : Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            // background: Container(
                            //     child: Gaps.empty, color: isDark ? ColorConstant.MAIN_BG_DARK : Colors.white),
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
                                  decoration: BoxDecoration(
                                      color: isDark
                                          ? ColorConstant.MAIN_BG_DARK
                                          : Colors.transparent),
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ])),
                      )),
                  SliverToBoxAdapter(
                      child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colours.dark_bg_color : Color(0xfffffeff),
                      // borderRadius:
                      //     BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                    ),
                    padding: const EdgeInsets.only(
                        top: 20, left: 15.0, right: 15.0, bottom: 10),
                    child: account == null && _initAccount
                        ? SpinKitThreeBounce(
                            color: Colors.lightGreen,
                            size: 20,
                          )
                        : account == null
                            ? Gaps.empty
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                      flex: 3,
                                      fit: FlexFit.loose,
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(children: [
                                          WidgetSpan(
                                              child: Icon(Icons.school,
                                                  size: 16,
                                                  color: isDark
                                                      ? Colors.white60
                                                      : Colors.black87)),
                                          // WidgetSpan(
                                          //     child: _wrapIcon(LoadAssetSvg("count",
                                          //         width: 19, height: 19, color: Colors.green))),
                                          TextSpan(
                                              text: "  ${_getCampusInfoText()}",
                                              style: TextStyle(
                                                  fontSize: Dimens.font_sp15,
                                                  fontFamily: TextConstant
                                                      .PING_FANG_FONT,
                                                  color: MyColorStyle
                                                      .getTweetReplyBodyColor(
                                                          context: context)))
                                        ]),
                                      )),
                                  Flexible(
                                      flex: 1,
                                      child: GestureDetector(
                                        onTap: () {
                                          BottomSheetUtil.showBottomSheet(
                                              context,
                                              0.55,
                                              _buildDetailProfileInfo());
                                        },
                                        child: Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              "查看更多",
                                              style: pfStyle.copyWith(
                                                  color: Colors.grey,
                                                  fontSize: Dimens.font_sp14),
                                            ),
                                            Icon(Icons.arrow_right,
                                                color: Colors.grey)
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                  )),
                  CollectionUtil.isListEmpty(_accountTweets) || _initTweet
                      ? (!_initTweet
                          ? SliverToBoxAdapter(
                              child: Container(
                                  color: isDark
                                      ? Colours.dark_bg_color
                                      : Color(0xfffffeff),
                                  padding: EdgeInsets.only(top: 50),
                                  height: 800,
                                  alignment: Alignment.topCenter,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                          // width: ScreenUtil().setWidth(600),
                                          height: ScreenUtil().setHeight(400),
                                          child: LoadAssetImage(
                                            ThemeUtils.isDark(context)
                                                ? 'no_data_dark'
                                                : 'no_data',
                                            fit: BoxFit.cover,
                                          )),
                                      Gaps.vGap16,
                                      Text('该用户暂未发布过内容~',
                                          style: pfStyle.copyWith(
                                              color: Colors.grey,
                                              fontSize: Dimens.font_sp14)),
                                    ],
                                  )),
                            )
                          : SliverToBoxAdapter(
                              child: Container(
                              margin: const EdgeInsets.only(top: 30),
                              child: SpinKitThreeBounce(
                                  color: Colors.lightGreen, size: 20),
                            )))
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
                ]))
          ],
        ));
  }

  calGender(AccountDisplayInfo acc) {
    if (acc != null) {
      if (acc.displaySex) {
        return Gender.parseGender(acc.gender);
      }
    }
    return Gender.UNKNOWN;
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
      return "未知";
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
            tip: "您确认屏蔽此用户，屏蔽后此用户的内容将对您不可见，此操作不可恢复",
            onTapDelete: () async {
              Utils.showDefaultLoading(Application.context);
              Result r =
                  await UnlikeAPI.unlikeAccount(widget.accountId.toString());
              NavigatorUtils.goBack(Application.context);
              if (r == null) {
                ToastUtil.showToast(
                    Application.context, TextConstant.TEXT_SERVICE_ERROR);
              } else {
                if (r.isSuccess) {
                  final _tweetProvider =
                      Provider.of<TweetProvider>(Application.context);
                  _tweetProvider.deleteByAccount(widget.accountId);
                  ToastUtil.showToast(
                      Application.context, '屏蔽成功，您将不会在看到此用户的内容');
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
    if (account == null || _initAccount) {
      return Center(
        child: Text("暂无可用信息", style: pfStyle),
      );
    }
    String genderText = "未知";
    if (account.displaySex && !StringUtil.isEmpty(account.gender)) {
      String gender = account.gender.toUpperCase();
      if (gender == Gender.FEMALE.name) {
        genderText = "女";
      } else if (gender == Gender.MALE.name) {
        genderText = "男";
      }
    }
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(
          top: 29.0, left: 20.0, right: 20.0, bottom: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSingleContainer(
              Icon(
                Icons.perm_contact_calendar,
                color: Colors.green,
              ),
              "基础资料",
              {
                "昵称": _buildSingleTextValue(account.nick),
                "签名": _buildSingleTextValue(account.signature ?? " — "),
              }),
          _buildSingleContainer(
              Icon(Icons.add_a_photo, color: Colors.blueAccent), "个人档案", {
            "姓名": _buildSingleTextValue(
                account.displayName ? account.name : " — "),
            "性别": _buildSingleTextValue(genderText),
            // "性别": _buildGenderWidget(),
            "年龄": _buildSingleTextValue(account.displayAge && account.age > 0
                ? account.age.toString()
                : " — "),
            "地区": _buildSingleTextValue(_buildRegionText()),
            "专业": _buildSingleTextValue(_getCampusInfoText()),
          }),
          _buildSingleContainer(
              Icon(
                Icons.contact_phone,
                color: Colors.amber,
              ),
              "联系资料",
              {
                "手机": _buildSingleTextValue(
                    account.displayPhone ? account.mobile : " — "),
                "Q Q": _buildSingleTextValue(
                    account.displayQQ && account.qq != null
                        ? account.qq
                        : " — "),
                "微信": _buildSingleTextValue(
                    account.displayWeChat ? account.wechat : " — "),
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
          child: Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 10.0),
                child: Text(
                  key,
                  style: pfStyle.copyWith(
                      fontSize: Dimens.font_sp15,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
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
                // Icon(icon.icon, size: 20, color: icon.color),
                Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: Text(title,
                      style: pfStyle.copyWith(
                          fontSize: Dimens.font_sp15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                          color: Colors.grey)),
                )
              ],
            ),
            Gaps.vGap10,
            genItems(items),
          ],
        ));
  }

  Widget _buildSingleTextValue(String text) {
    if (text == null || text.trim().length == 0) {
      text = "";
    }
    return Text(text, style: pfStyle.copyWith(fontWeight: FontWeight.w400));
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
            child: Text(
              "女",
              style: pfStyle,
            ),
            // child: CircleAvatar(
            //   backgroundColor: Colors.pink[200],
            //   child: LoadAssetSvg(
            //     'female',
            //     width: 20,
            //     height: 20,
            //     color: Colors.white,
            //     fit: BoxFit.cover,
            //   ),
            // ),
          );
        }
        if (t == Gender.MALE.name) {
          return Container(
            padding: const EdgeInsets.all(3.0),
            width: 20,
            height: 20,
            child: Text(
              "女",
              style: pfStyle,
            ),
            // child: CircleAvatar(
            //   backgroundColor: Colors.blueAccent,
            //   child: LoadAssetSvg(
            //     'male',
            //     width: 20,
            //     height: 20,
            //     color: Colors.white,
            //     fit: BoxFit.cover,
            //   ),
            // ),
          );
        }
      }
    }
    return _buildSingleTextValue("未知");
  }
}
