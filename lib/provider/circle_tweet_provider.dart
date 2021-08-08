import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/circle/circle_tweet.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/util/toast_util.dart';

class CircleTweetProvider extends ChangeNotifier {
  List<CircleTweet> _displayTweets;

  List<CircleTweet> get displayTweets => _displayTweets;

  void refresh() {
    print('------------CircleTweetProvider NOTIFY--------------');
    notifyListeners();
  }

  void delete(int tweetId) {
    _displayTweets.removeWhere((t) => t != null && t.id == tweetId);
    refresh();
  }

  void clear() {
    _displayTweets = null;
    refresh();
  }

  // void deleteReply(int tweetId, int parentId, int replyId, int type) {
  //   if (displayTweets == null) {
  //     return;
  //   }
  //   BaseTweet t = _displayTweets.firstWhere((t) => t.id == tweetId, orElse: () => null);
  //   if (t != null) {
  //     List<TweetReply> trs = t.dirReplies;
  //     if (trs != null && trs.length > 0) {
  //       if (type == 1) {
  //         // 删除直接回复
  //         trs.removeWhere((dirReply) => dirReply.id == replyId);
  //       } else if (type == 2) {
  //         TweetReply parentReply = trs.firstWhere((dirReply) => dirReply.id == parentId,orElse: () => null);
  //         if (parentReply != null) {
  //           List<TweetReply> subTrs = parentReply.children;
  //           if (subTrs != null && subTrs.length > 0) {
  //             subTrs.removeWhere((subReply) => subReply.id == replyId);
  //           }
  //         }
  //       }
  //     }
  //   }
  //   refresh();
  // }
  //
  // void deleteByAccount(String accountId) {
  //   _displayTweets.removeWhere((t) => t != null && !t.anonymous && t.account.id == accountId);
  //   refresh();
  // }

  // void updateReply(BuildContext context, TweetReply tr) {
  //   BaseTweet targetTweet = displayTweets.firstWhere((tweet) => tweet.id == tr.tweetId);
  //   if (tr == null) {
  //     ToastUtil.showToast(
  //       context,
  //       '回复失败，请稍后重试',
  //       gravity: ToastGravity.TOP,
  //     );
  //     return;
  //   } else {
  //     targetTweet.replyCount++;
  //     if (tr.type == 1) {
  //       // 设置到直接回复
  //       if (targetTweet.dirReplies == null) {
  //         targetTweet.dirReplies = List();
  //       }
  //       targetTweet.dirReplies.add(tr);
  //     } else {
  //       // 子回复
  //       int parentId = tr.parentId;
  //       TweetReply tr2 = targetTweet.dirReplies.where((dirReply) => dirReply.id == parentId).first;
  //       if (tr2.children == null) {
  //         tr2.children = List();
  //       }
  //       tr2.children.add(tr);
  //     }
  //     notifyListeners();
  //   }
  // }

  // void updatePraise(BuildContext context, Account account, int tweetId, bool praise) {
  //   BaseTweet targetTweet = displayTweets.firstWhere((tweet) => tweet.id == tweetId);
  //   if (targetTweet == null) {
  //     ToastUtil.showToast(
  //       context,
  //       '内容不存在，请刷新后重试',
  //       gravity: ToastGravity.TOP,
  //     );
  //     return;
  //   } else {
  //     targetTweet.loved = praise;
  //
  //     if (praise) {
  //       targetTweet.praise++;
  //       if (targetTweet.latestPraise == null) {
  //         targetTweet.latestPraise = List();
  //       }
  //       targetTweet.latestPraise.add(account);
  //     } else {
  //       targetTweet.praise--;
  //       if (targetTweet.latestPraise != null) {
  //         targetTweet.latestPraise.removeWhere((acc) => acc.id == account.id);
  //       }
  //     }
  //     notifyListeners();
  //   }
  // }

  void update(List<CircleTweet> tweets, {bool append = true, bool clear = false}) {
    if (append && clear) {
      throw 'append and clear must have different value';
    }
    if (tweets == null) {
      // _displayTweets = null;
    } else {
      List<String> unlikes = SpUtil.getStringList(SharedConstant.MY_UN_LIKED);
      if (unlikes != null && unlikes.length > 0) {
        tweets.removeWhere((tweet) => unlikes.indexOf(tweet.id.toString()) != -1);
      }
      if (clear) {
        _displayTweets = [];
        _displayTweets.addAll(tweets);
      } else {
        if (append) {
          if (_displayTweets == null) {
            _displayTweets = [];
          }
          _displayTweets.addAll(tweets);
        }
      }
    }
    refresh();
  }
}
