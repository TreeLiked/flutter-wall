import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/common-widget/v_empty_view.dart';
import 'package:iap_app/component/hot_app_bar.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/page/create_page.dart';
import 'package:iap_app/part/hot_today.dart';
import 'package:iap_app/part/recom.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HotPage extends StatefulWidget {
  HotPage();
  @override
  State<StatefulWidget> createState() {
    return HotPageState();
  }
}

class HotPageState extends State<HotPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  TabController _tabController;

  double sw;

  int orgId = 1;

  HotPageState() {
    print('HotPageState state construct');
  }
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    sw = MediaQuery.of(context).size.width;

    // return Scaffold(
    //   backgroundColor: ColorConstant.DEFAULT_BAR_BACK_COLOR,
    //   body: NestedScrollView(
    //     headerSliverBuilder: (context, innerBoxIsScrolled) =>
    //         _sliverBuilder(context, innerBoxIsScrolled),
    //     body: SingleChildScrollView(
    //         child: Container(
    //       decoration: BoxDecoration(
    //           color: Colors.white,
    //           borderRadius: BorderRadius.all(Radius.circular(15))),
    //       padding: EdgeInsets.symmetric(horizontal: 15),
    //       child: Column(
    //         children: <Widget>[],
    //       ),
    //     )),
    //   ),
    // );
    return Scaffold(
        appBar: PreferredSize(
            child: AppBar(
              elevation: 0,
            ),
            preferredSize: Size.fromHeight(1)),
        // Size.fromHeight(MediaQuery.of(context).size.height * 0.05)),
        backgroundColor: Colors.black,
        // body: SafeArea(
        //   bottom: false,
        //   child: Column(
        //     children: <Widget>[
        //       Stack(
        //         children: <Widget>[
        //           Padding(
        //             padding: EdgeInsets.symmetric(
        //                 horizontal: ScreenUtil().setWidth(150)),
        //             child: TabBar(
        //               labelStyle: TextStyle(
        //                   fontSize: 20,
        //                   fontWeight: FontWeight.bold,
        //                   color: Colors.white),
        //               unselectedLabelStyle: TextStyle(fontSize: 14),
        //               indicator: UnderlineTabIndicator(),
        //               controller: _tabController,
        //               tabs: [
        //                 Tab(
        //                   text: '今日热门',
        //                 ),
        //                 Tab(
        //                   text: '往期',
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ],
        //       ),
        //       // VEmptyView(20),
        //       Expanded(
        //         child: TabBarView(
        //           controller: _tabController,
        //           children: [
        //             HotToday(),
        //             // CreatePage(),
        //             CreatePage(),
        //           ],
        //         ),
        //       ),
        //     ],
        //   )),
        body: HotToday());
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
