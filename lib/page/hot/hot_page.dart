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

    return Scaffold(
        appBar: PreferredSize(
            child: AppBar(
              elevation: 0,
            ),
            preferredSize: Size.fromHeight(1)),
        // Size.fromHeight(MediaQuery.of(context).size.height * 0.05)),
        backgroundColor: Colors.black,

        body: HotToday());
  }

  @override
  bool get wantKeepAlive => true;
}
