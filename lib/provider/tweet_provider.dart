import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/util/toast_util.dart';

class TweetProvider extends ChangeNotifier {
  List<BaseTweet> _displayTweets;

  List<BaseTweet> get displayTweets => _displayTweets;

  void refresh() {
    print('------------NOTIFY--------------');
    notifyListeners();
  }

  void delete(int tweetId) {
    _displayTweets.removeWhere((t) => t.id == tweetId);
  }

  void updateReply(BuildContext context, TweetReply tr) {
    BaseTweet targetTweet = displayTweets.firstWhere((tweet) => tweet.id == tr.tweetId);
    if (tr == null) {
      ToastUtil.showToast(
        context,
        '回复失败，请稍后重试',
        gravity: ToastGravity.TOP,
      );
      return;
    } else {
      targetTweet.replyCount++;
      if (tr.type == 1) {
        // 设置到直接回复
        if (targetTweet.dirReplies == null) {
          targetTweet.dirReplies = List();
        }
        targetTweet.dirReplies.add(tr);
      } else {
        // 子回复
        int parentId = tr.parentId;
        TweetReply tr2 = targetTweet.dirReplies.where((dirReply) => dirReply.id == parentId).first;
        if (tr2.children == null) {
          tr2.children = List();
        }
        tr2.children.add(tr);
      }
      notifyListeners();
    }
  }

  void update(List<BaseTweet> tweets, {bool append = true, bool clear = false}) {
    if (append && clear) {
      throw 'append and clear must have different value';
    }
    if (tweets == null) {
      _displayTweets = null;
    } else {
      if (clear) {
        _displayTweets = List();
        _displayTweets.addAll(tweets);
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
