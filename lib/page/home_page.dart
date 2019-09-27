import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/widgets.dart' as prefix0;
import 'package:iap_app/component/tweet_card.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/part/recom.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        centerTitle: true, //标题居中
        title: Text(
          '南京工程学院',
          style: TextStyle(fontSize: 18),
        ),

        expandedHeight: 200.0, //展开高度200
        backgroundColor: GlobalConfig.DEFAULT_BAR_BACK_COLOR,
        floating: true, //不随着滑动隐藏标题
        pinned: false, //不固定在顶部
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          background: Image.network(
            "https://tva1.sinaimg.cn/large/006y8mN6gy1g7e2n5udwoj30zk0nogrk.jpg",
            fit: BoxFit.cover,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) =>
          _sliverBuilder(context, innerBoxIsScrolled),
      body: Recommendation(null),
    ));
  }
}
