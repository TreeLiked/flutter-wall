import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iap_app/api/message.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/bloc/count_bloc.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/page/notification/index.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/util/collection.dart';
import 'package:provider/provider.dart';

class SingleMessageControl extends BaseBloc {
  StreamController<int> _controller;

  /// 维护一个本地计数器，三种状态，-1初始｜0没有消息｜x(x>0)显示小红点数目
  int _localCount = -1;

  SingleMessageControl() {
    this._controller = new StreamController<int>.broadcast();
  }

  void clear() {
    _localCount = 0;
    _controller.sink.add(-1);
  }

  set streamCount(int count) {
    _controller.sink.add(count);
  }

  set localCount(int count) {
    this._localCount = count;
  }

  get localCount => _localCount;

  get controller => _controller;

  @override
  void dispose() {
    _controller?.close();
  }
}

class MessageUtil extends BaseBloc {
  static bool _loopQueryNotification = true;

  static void startLoopQueryNotification() {
    _loopQueryNotification = true;
    loopRefreshMessage();
  }

  static void stopLoopQueryNotification() {
    _loopQueryNotification = false;
  }

  static loopRefreshMessage() async {
    if (_loopQueryNotification) {
      Future.delayed(Duration(seconds: 60)).then((_) {
        MessageAPI.queryInteractionMessageCount().then((cnt) {
          MessageUtil.setNotificationCnt(cnt);
        }).whenComplete(() {
          if (_loopQueryNotification) {
            loopRefreshMessage();
          }
        });
      });
    }
  }

  static loopRefreshNewTweet(BuildContext context) async {
    final _tweetProvider = Provider.of<TweetProvider>(context);
    List<BaseTweet> tweets = _tweetProvider.displayTweets;

    if (CollectionUtil.isListEmpty(tweets)) {
      await Future.delayed(Duration(seconds: 60)).then((value) => loopRefreshNewTweet(context));
      return;
    }

    Future.delayed(Duration(seconds: 60)).then((_) {
      final _tweetProvider = Provider.of<TweetProvider>(context);
      List<BaseTweet> tweets = _tweetProvider.displayTweets;
      MessageAPI.queryNewTweetCount(Application.getOrgId, tweets[0].id, null).then((cnt) {
        MessageUtil.setTabIndexTweetCnt(cnt);
      }).whenComplete(() {
        loopRefreshNewTweet(context);
      });
    });
  }

  static int interactionCnt = -1;
  static int notificationCnt = -1;
  static int taIndexTweetCnt = -1;

  static final SingleMessageControl interactionMsgControl = new SingleMessageControl();
  static final SingleMessageControl systemMsgControl = new SingleMessageControl();

  // 消息红点
  static final StreamController<int> _notificationStreamCntCtrl = new StreamController<int>.broadcast();

  // 首页 tab红点
  static final StreamController<int> _tabIndexTweetStreamCntCtrl = new StreamController<int>.broadcast();

  static final StreamController<int> _interactionStreamCntCtrl = new StreamController<int>.broadcast();
  static final StreamController<int> _systemStreamCntCtrl = new StreamController<int>.broadcast();

  static StreamController<int> get notificationStreamCntCtrl => _notificationStreamCntCtrl;

  static StreamController<int> get interactionStreamCntCtrl => _interactionStreamCntCtrl;

  static StreamController<int> get systemStreamCntCtrl => _systemStreamCntCtrl;

  static StreamController<int> get tabIndexStreamCntCtrl => _tabIndexTweetStreamCntCtrl;

  static void setNotificationCnt(int count) {
    if (notificationCnt != count && _notificationStreamCntCtrl != null) {
      notificationCnt = count;
      _notificationStreamCntCtrl.sink.add(count);
    }
  }

  static void clearNotificationCnt() {
    notificationCnt = -1;
    _notificationStreamCntCtrl.sink.add(-1);
  }

  static void setTabIndexTweetCnt(int count) {
    if (taIndexTweetCnt != count && _tabIndexTweetStreamCntCtrl != null) {
      taIndexTweetCnt = count;
      _tabIndexTweetStreamCntCtrl.sink.add(count);
    }
  }

  static void clearTabIndexTweetCnt() {
    taIndexTweetCnt = -1;
    _tabIndexTweetStreamCntCtrl.sink.add(-1);
  }

  static void clearInteractionCnt() {
    notificationCnt = -1;
    _interactionStreamCntCtrl.sink.add(-1);
  }

  static void setInteractionCnt(int count) {
    _interactionStreamCntCtrl.sink.add(count);
  }

  static void showSystemRedPoint() {
    _notificationStreamCntCtrl.sink.add(1);
  }

  static void hideSystemRedPoint() {
    _notificationStreamCntCtrl.sink.add(-1);
  }

  static void close() {
    _notificationStreamCntCtrl?.close();
    _interactionStreamCntCtrl?.close();
    _systemStreamCntCtrl?.close();
    _tabIndexTweetStreamCntCtrl?.close();
  }

  @override
  void dispose() {
    _notificationStreamCntCtrl?.close();
  }
}
