import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iap_app/part/hot_today.dart';

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
    super.build(context);

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
  bool get wantKeepAlive => true;
}
