import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/widgets.dart' as prefix0;
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/component/divider.dart';
import 'package:iap_app/component/tweet_card.dart';
import 'package:iap_app/global/shared_data.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/util/collection.dart';
import 'package:provider/provider.dart';

class Recommendation extends StatefulWidget {
  Recommendation({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    print('reco create state');
    return RecommendationState();
  }
}

class RecommendationState extends State<Recommendation> {
  List<BaseTweet> children = [];

  RecommendationState() {
    print('reco state construct');
  }
  @override
  void initState() {
    super.initState();
  }

  void updateTweetList(List<BaseTweet> tweets,
      {bool add = false, bool start = false}) {
    if (!CollectionUtil.isListEmpty(tweets)) {
      if (add) {
        setState(() {
          if (start) {
            children.insertAll(0, tweets);
          } else {
            children.addAll(tweets);
          }
        });
      } else {
        children.clear();
        setState(() {
          this.children = tweets;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('recom buildd');
    return Scrollbar(
        child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        color: Color(0xfff7f7f7),
        // padding: EdgeInsets.only(top: 5),
        child: Column(
            // children: children,
            children: children.map((f) => TweetCard(f)).toList()),
      ),
    ));
  }
}
