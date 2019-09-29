import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/widgets.dart' as prefix0;
import 'package:iap_app/component/tweet_card.dart';
import 'package:iap_app/model/tweet.dart';

class Recommendation extends StatefulWidget {
  List<BaseTweet> _tweetList;

  Recommendation(List<BaseTweet> tweets) {
    this._tweetList = tweets;
  }

  @override
  State<StatefulWidget> createState() {
    return new _RecommendationState();
  }
}

class _RecommendationState extends State<Recommendation> {
  BaseTweet t = new BaseTweet(
      '在三体中，罗辑为什么会把控制权交给程心，难道他没有推测过后果吗？,因为罗辑遵守了人类伦理。这个伦理大概就叫民主。 大刘其实是个典型的精英主义者，在他笔下...',
      'OFFESSION_LOVE',
      true);
  @override
  Widget build(BuildContext context) {
    return new SingleChildScrollView(
      child: new Container(
        child: new Column(
          children: <Widget>[
            new TweetCard(t),
            Divider(
              height: 1.0,
              indent: 0.0,
              color: prefix0.Color(0xffF5F5F5),
            ),
            new TweetCard(t),
            new TweetCard(t),
            new TweetCard(t),
          ],
        ),
      ),
    );
  }
}
