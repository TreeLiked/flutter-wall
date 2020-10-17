
import 'package:flutter/material.dart';
import 'package:iap_app/model/tweet.dart';

class TweetBloc with ChangeNotifier {
  // StreamController<List<BaseTweet>> _streamController;
  // Stream<List<BaseTweet>> _stream;
  List<BaseTweet> tweets;

  TweetBloc() {
    tweets = [];
    // _streamController = StreamController.broadcast();
    // _stream = _streamController.stream;
  }

  // Stream<List<BaseTweet>> get stream => _stream;
  List<BaseTweet> get count => tweets;

  addCounter(List<BaseTweet> tweets) {
    // _streamController.sink.add(tweets);
    this.tweets = [];
    this.tweets.addAll(tweets);
    notifyListeners();
  }

  // dispose() {
  //   _streamController.close();
  // }
}
