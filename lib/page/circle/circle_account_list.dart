import 'dart:async';
import 'dart:math';

import 'package:flustars/flustars.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iap_app/api/circle.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/api/univer.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/my_flat_button.dart';
import 'package:iap_app/component/simgple_tag.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/circle_account.dart';
import 'package:iap_app/model/gender.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/result_code.dart';
import 'package:iap_app/model/university.dart';
import 'package:iap_app/page/login/reg_temp.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/login_router.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/http_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CircleAccountListPage extends StatefulWidget {
  final int circleId;

  CircleAccountListPage(this.circleId);

  @override
  State<StatefulWidget> createState() {
    return _CircleAccountListPageState();
  }
}

class _CircleAccountListPageState extends State<CircleAccountListPage> {
  List<CircleAccount> filterList;

  TextEditingController _controller;

  Future _queryAccTask;

  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController = RefreshController(initialRefresh: true);

  int _currentPage = 1;
  int _pageSize = 20;

  String nickLike = '';

  Duration durationTime = Duration(seconds: 1);

  // 防抖函数
  Timer timer;

  bool isDark = false;
  BuildContext context;

  @override
  void initState() {
    super.initState();
    queryMyAccount();
    _controller = TextEditingController();
  }

  void queryMyAccount() async {
    CircleApi.querySingleCircleAccount(widget.circleId, Application.getAccountId).then((myAcc) {
      if (myAcc != null) {
        setState(() {
          this.curLogUser = myAcc;
        });
      }
    });
  }

  Future<List<CircleAccount>> queryCircleAccounts(int currentPage) async {
    // await Future.delayed(Duration(seconds: 3));

    return await CircleApi.queryCircleAccounts(
        widget.circleId, nickLike, PageParam(currentPage, pageSize: _pageSize));
  }

  CircleAccount curLogUser;
  bool curRoleEditMode = false;

  @override
  Widget build(BuildContext context) {
    isDark = ThemeUtils.isDark(context);
    this.context = context;
    return Scaffold(
        appBar: MyAppBar(
          centerTitle: '圈内用户',
          actionName: isCreatorOrAdmin(curLogUser) ? '编辑用户角色' : '',
          onPressed: isCreatorOrAdmin(curLogUser)
              ? () {
                  setState(() {
                    curRoleEditMode = !curRoleEditMode;
                  });
                  if (curRoleEditMode) {
                    ToastUtil.showToast(context, '用户角色编辑模式已打开，点击某一个用户以修改其角色');
                  } else {
                    ToastUtil.showToast(context, '用户角色编辑模式已关闭');
                  }
                }
              : null,
          actionColor: curRoleEditMode ? Colors.orange : Colors.grey,
          isBack: true,
        ),
        body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [],
            body: SmartRefresher(
              enablePullUp: true,
              enablePullDown: true,
              primary: false,
              scrollController: _scrollController,
              controller: _refreshController,
              cacheExtent: 20,
              header: WaterDropHeader(
                  waterDropColor: Colors.lightGreen, complete: const Text('刷新完成', style: pfStyle)),
              footer: ClassicFooter(
                loadingText: '正在加载...',
                canLoadingText: '释放以加载更多',
                noDataText: '到底了哦',
                idleText: '继续上滑',
              ),
              child: filterList == null
                  ? Gaps.empty
                  : filterList.length == 0
                      ? Container(
                          alignment: Alignment.topCenter,
                          margin: const EdgeInsets.only(top: 50),
                          child: Text('未查询到账户'),
                        )
                      : ListView.builder(
                          itemCount: filterList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return _buildAccLineItem(filterList[index]);
                          }),
              onRefresh: () => _fetchMessages(),
              onLoading: _onLoading,
            )));
//         body: Column(
//           children: <Widget>[
//             Gaps.vGap16,
//             Container(
// //                    height: ScreenUtil().setHeight(80),
//               padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 3.0),
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(13.0),
//                 color: ThemeUtils.isDark(context) ? Color(0xff363636) : ColorConstant.TWEET_RICH_BG,
//               ),
//               margin: EdgeInsets.symmetric(horizontal: Dimens.gap_dp5),
//               child: TextField(
//                 controller: _controller,
//                 textInputAction: TextInputAction.search,
//                 onSubmitted: (_) async {
//                   setState(() {
//                     _queryAccTask = queryCircleAccounts(_controller.text);
//                   });
//                 },
//                 onChanged: (val) async {
//                   setState(() {
//                     timer?.cancel();
//                     timer = new Timer(durationTime, () {
//                       setState(() {
//                         _queryAccTask = queryCircleAccounts(val);
//                       });
//                     });
//                   });
//                 },
//                 style: TextStyles.textSize14.copyWith(letterSpacing: 1.1, color: Colors.amber[800]),
//                 decoration: InputDecoration(
//                     hintText: '输入用户昵称以搜索',
//                     hintStyle: TextStyles.textGray14,
//                     prefixIcon: Icon(
//                       Icons.search,
//                       color: Colors.grey,
//                     ),
//                     suffixIcon: GestureDetector(
//                       child: Icon(
//                         Icons.clear,
//                         color: Colors.grey,
//                       ),
//                       onTap: () {
//                         _controller.clear();
//                         setState(() {
//                           _queryAccTask = queryCircleAccounts("");
//                         });
//                       },
//                     ),
//                     border: InputBorder.none),
//                 maxLines: 1,
//               ),
//             ),
//             Expanded(
//                 child: Container(
//                     margin: EdgeInsets.all(0),
//                     padding: EdgeInsets.all(0),
//                     child: FutureBuilder<List<CircleAccount>>(
//                         builder: (context, AsyncSnapshot<List<CircleAccount>> async) {
//                           //在这里根据快照的状态，返回相应的widget
//                           if (async.connectionState == ConnectionState.active ||
//                               async.connectionState == ConnectionState.waiting) {
//                             return Container(
//                               margin: EdgeInsets.only(bottom: 500
// //                                    ScreenUtil().setHeight(500)
//                                   ),
//                               child: new SpinKitThreeBounce(
//                                 color: Colors.lightGreen,
//                                 size: 18,
//                               ),
//                             );
//                           }
//                           if (async.connectionState == ConnectionState.done) {
//                             if (async.hasError) {
//                               return new Center(
//                                 child: new Text("${async.error}"),
//                               );
//                             } else if (async.hasData) {
//                               List<University> list = async.data;
//                               // setState(() {
//                               //   filterList = list;
//                               // });
//                               if (list == null || list.length == 0) {
//                                 return Padding(
// //                                          alignment: Alignment.center,
//                                     padding: const EdgeInsets.only(top: 37),
//                                     child: Text('没有满足条件的数据', style: TextStyles.textGray14));
//                               }
//
//                               list.forEach((element) {
//                                 print(element.toJson());
//                               });
//                               return ListView.builder(
//                                   itemCount: list.length,
//                                   itemBuilder: (context, index) {
//                                     return new ListTile(
//                                       onTap: () {
//                                         University un = list[index];
//                                         if (un == null) {
//                                           return;
//                                         }
//                                         if (un.status != 1) {
//                                           if (un.status == 0) {
//                                             ToastUtil.showToast(context, "抱歉，您的学校暂时未开放");
//                                           }
//                                           if (un.status == 2) {
//                                             ToastUtil.showToast(context, "抱歉，您的学校正在灰度测试中，感谢您的支持");
//                                           }
//                                           return;
//                                         }
//                                         setState(() {});
//                                       },
//                                       title: new Text(list[index].name, style: TextStyles.textSize14),
//                                       subtitle: StringUtil.isEmpty(list[index].enAbbr)
//                                           ? null
//                                           : new Text(list[index].enAbbr.toUpperCase() ?? "",
//                                               style: TextStyles.textSize12),
//                                     );
//                                   });
//                             }
//                           }
//                           return Gaps.empty;
//                         },
//                         future: _queryAccTask)))
//           ],
//         ));
  }

  Widget _buildAccLineItem(CircleAccount acc) {
    Color creatorBgColor = Color(0xffFDF5E6);
    Color adminBgColor = Color(0xffF0FFF0);
    if (isDark) {
      creatorBgColor = creatorBgColor.withAlpha(30);
      adminBgColor = adminBgColor.withAlpha(30);
    }
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!curRoleEditMode) {
            return;
          }
          if (acc.role == CircleAccountRole.CREATOR) {
            return;
          }
          if (isCreatorOrAdmin(curLogUser)) {
            _forwardRoleSet(acc);
          }
        },
        child: Container(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: acc.role == CircleAccountRole.CREATOR
                    ? creatorBgColor
                    : acc.role == CircleAccountRole.ADMIN
                        ? adminBgColor
                        : null),
            margin: const EdgeInsets.only(left: 15.0, bottom: 4.0, right: 15.0, top: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                        margin: const EdgeInsets.only(right: 10.0),
                        child: AccountAvatar(
                            cache: true,
                            size: 40.0,
                            avatarUrl: acc.avatarUrl,
                            gender: Gender.parseGender(acc.gender),
                            onTap: () => NavigatorUtils.goAccountProfile3(context, acc)))
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _buildHead(acc),
                      Gaps.vGap4,
                      _buildBody(acc),
                      // Gaps.vGap5,
                      // _buildOptions(acc)
                      Gaps.vGap10,
                      Gaps.line
                    ],
                  ),
                ),
              ],
            )));
  }

  Widget _buildHead(CircleAccount acc) {
    bool myself = acc.id == Application.getAccountId;
    return GestureDetector(
        onTap: () => NavigatorUtils.goAccountProfile3(context, acc),
        child: Text('${(myself ? '(我)' : '') + acc.nick}',
            style: MyDefaultTextStyle.getTweetNickStyle(Dimens.font_sp15, context: context, bold: true)
                .copyWith(color: isDark ? Colors.grey : Color(0xff6C7B8B))));
  }

  _buildBody(CircleAccount acc) {
    Widget t;
    if (acc.role == CircleAccountRole.CREATOR) {
      t = SimpleTag(
        '圈主',
        textColor: Colors.white,
        bgColor: Colors.amber,
        radius: 3.0,
        horizontalPadding: 10.0,
        verticalPadding: 2.0,
      );
    } else if (acc.role == CircleAccountRole.ADMIN) {
      t = SimpleTag(
        '管理员',
        textColor: Colors.white,
        bgColor: Colors.green,
        radius: 3.0,
        horizontalPadding: 10.0,
        verticalPadding: 2.0,
      );
    } else {
      t = Gaps.empty;
    }
    String sig = StringUtil.isEmpty(acc.signature) ? "这个人很懒，什么都没有留下" : acc.signature;
    List<Widget> tags = [];
    tags.add(t);
    if (!CollectionUtil.isListEmpty(acc.tags)) {
      tags.addAll(acc.tags
          .map((e) => SimpleTag(
                e,
                leftMargin: 5.0,
                horizontalPadding: 8.0,
                verticalPadding: 2.0,
                radius: 3.0,
                textColor: Colors.green[700],
                bgColor: ColorConstant.TWEET_RICH_BG_2,
              ))
          .toList());
    }
    if (acc.role == CircleAccountRole.GUEST) {
      // 当前被操作为删除
      tags.add(SimpleTag(
        '已移出',
        leftMargin: 5.0,
        horizontalPadding: 8.0,
        verticalPadding: 2.0,
        radius: 3.0,
        textColor: Colors.white,
        bgColor: Colors.grey,
      ));
    }
    return Wrap(
      runSpacing: 5.0,
      children: [
        Row(
          children: [
            Flexible(
              child: Text('$sig',
                  style: MyDefaultTextStyle.getTweetSigStyle(context, fontSize: Dimens.font_sp13p5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true),
            ),
          ],
        ),
        Wrap(runSpacing: 5.0, children: tags)
      ],
    );
  }

  _buildOptions(CircleAccount acc) {
    bool meCreator = false;
    bool meAdmin = false;
    CircleAccount curLoginAcc = filterList.firstWhere((element) => element.id == Application.getAccountId);
    if (curLoginAcc == null) {
      return Gaps.empty;
    }
    if (curLoginAcc.role == CircleAccountRole.CREATOR) {}
    return Gaps.empty;
  }

  void _forwardRoleSet(CircleAccount targetAcc) {
    BottomSheetUtil.showBottomSheet(context, 0.3, _buildTypeSelection(targetAcc),
        topLine: false, topWidget: _buildTopWidget(targetAcc));
  }

  _buildTopWidget(CircleAccount targetAcc) {
    return Container(
      height: 50.0,
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      alignment: Alignment.center,
      child: Text("设置用户(${targetAcc.nick})角色",
          style: pfStyle.copyWith(fontSize: Dimens.font_sp15, fontWeight: FontWeight.bold)),
    );
  }

  _buildTypeSelection(CircleAccount targetAcc) {
    bool curCreator = curLogUser.role == CircleAccountRole.CREATOR;
    bool curAdmin = curLogUser.role == CircleAccountRole.ADMIN;
    return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            curCreator
                ? targetAcc.role != CircleAccountRole.ADMIN
                    ? MyFlatButton(
                        '设为管理员',
                        Colors.white,
                        fillColor: Colors.green,
                        horizontalPadding: 20.0,
                        onTap: () => _updateUserRole(targetAcc, CircleAccountRole.ADMIN),
                      )
                    : MyFlatButton('取消管理员', Colors.red,
                        fillColor: Colors.white,
                        horizontalPadding: 20.0,
                        onTap: () => _updateUserRole(targetAcc, CircleAccountRole.USER))
                : Gaps.empty,
            Gaps.vGap20,
            (curCreator) || (curAdmin && targetAcc.role != CircleAccountRole.ADMIN)
                ? TextButton(
                    child: Text(
                      '移出此圈子',
                      style: pfStyle.copyWith(color: Colors.orange),
                    ),
                    onPressed: () => _updateUserRole(targetAcc, CircleAccountRole.GUEST))
                : Gaps.empty,
          ],
        ));
  }

  void _fetchMessages() async {
    _currentPage = 1;
    List<CircleAccount> accs = await queryCircleAccounts(1);
    if (CollectionUtil.isListEmpty(accs)) {
      setState(() {
        this.filterList = [];
      });
      _refreshController.refreshCompleted();
      return;
    }
    setState(() {
      this.filterList = accs;
    });
    _refreshController.refreshCompleted(resetFooterState: true);
  }

  Future<void> _onLoading() async {
    List<CircleAccount> accs = await queryCircleAccounts(++_currentPage);
    if (CollectionUtil.isListEmpty(accs)) {
      _refreshController.loadNoData();
      return;
    }
    setState(() {
      if (this.filterList == null) {
        this.filterList = [];
      }
      this.filterList.addAll(accs);
    });
    _refreshController.loadComplete();
  }

  bool isCreatorOrAdmin(CircleAccount acc) {
    return acc != null && (acc.role == CircleAccountRole.CREATOR || acc.role == CircleAccountRole.ADMIN);
  }

  void _updateUserRole(CircleAccount targetAcc, CircleAccountRole role) {
    Utils.showDefaultLoadingWithBounds(context, text: "正在处理");

    CircleApi.updateUserRole(widget.circleId, targetAcc.id, role).then((res) {
      if (res.isSuccess) {
        setState(() {
          targetAcc = CircleAccount.fromJson(res.data);
        });
      } else {
        ToastUtil.showToast(context, res.message);
      }
      Utils.closeLoading(context);
    });
  }
}
