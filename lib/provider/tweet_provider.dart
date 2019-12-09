import 'package:flutter/material.dart';
import 'package:iap_app/model/tweet.dart';

class TweetProvider extends ChangeNotifier {
  List<BaseTweet> _displayTweets;

  List<BaseTweet> get displayTweets => _displayTweets;

  void refresh() {
    print('------------NOTIFY--------------');
    notifyListeners();
  }

  void update(List<BaseTweet> tweets,
      {bool append = true, bool clear = false}) {
    if (append && clear) {
      throw 'append and clear must have different value';
    }
    if (tweets == null) {
      _displayTweets = null;
    } else {
      if (clear) {
        _displayTweets = List();
        _displayTweets.addAll(tweets);
        print('----------------');
        print(_displayTweets);
      } else {
        if (append) {
          if (_displayTweets == null) {
            _displayTweets = List();
          }
          _displayTweets.addAll(tweets);
        }
      }
    }
    refresh();
  }
}
