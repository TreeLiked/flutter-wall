import 'dart:async';
import 'dart:convert';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/api/message.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/bloc/count_bloc.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/im_dto.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:provider/provider.dart';

class SingleMessageControl extends BaseBloc {
  static final String _TAG = "SingleMessageControl";

  StreamController<int> _controller;

  /// 维护一个本地计数器，三种状态，-1初始｜0没有消息｜x(x>0)显示小红点数目
  int _localCount = 0;

  SingleMessageControl() {
    this._controller = new StreamController<int>.broadcast();
  }

  void clear() {
    _localCount = 0;
    _controller.sink.add(0);
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

  static int interactionCnt = 0;
  static int notificationCnt = 0;
  static int tabIndexTweetCnt = 0;

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
    notificationCnt = 0;
    _notificationStreamCntCtrl.sink.add(0);
  }

  static void setTabIndexTweetCnt(int count) {
    if (tabIndexTweetCnt != count && _tabIndexTweetStreamCntCtrl != null) {
      tabIndexTweetCnt = count;
      _tabIndexTweetStreamCntCtrl.sink.add(count);
    }
  }

  static void clearTabIndexTweetCnt() {
    tabIndexTweetCnt =0;
    _tabIndexTweetStreamCntCtrl.sink.add(0);
  }

  static void clearInteractionCnt() {
    notificationCnt = 0;
    _interactionStreamCntCtrl.sink.add(0);
  }

  static void setInteractionCnt(int count) {
    _interactionStreamCntCtrl.sink.add(count);
  }

  static void showSystemRedPoint() {
    _notificationStreamCntCtrl.sink.add(1);
  }

  static void hideSystemRedPoint() {
    _notificationStreamCntCtrl.sink.add(0);
  }

  static void close() {
    _notificationStreamCntCtrl?.close();
    _interactionStreamCntCtrl?.close();
    _systemStreamCntCtrl?.close();
    _tabIndexTweetStreamCntCtrl?.close();
  }

  static void handleInstantMessage(ImDTO instruction, {BuildContext context}) async {
    if (instruction == null) {
      return;
    }
    if (context == null) {
      context = Application.context;
    }
    int command = instruction.command;

    LogUtil.e("Received Command: ${command.toString()}, Data: ${instruction.data.toString()}",
        tag: SingleMessageControl._TAG);
    switch (command) {
      case 200: // 有新推文内容，data: BaseTweet
        setTabIndexTweetCnt(tabIndexTweetCnt + 1);
        ToastUtil.showToast(context, "有新的内容，刷新试试 ～", gravity: ToastGravity.BOTTOM);
        break;
      case 201: // 用户推文被点赞了，data: 点赞的账户模型
        setNotificationCnt(notificationCnt + 1);
        Account praiseAcc = Account.fromJson(instruction.data);
        if (praiseAcc != null) {
          ToastUtil.showToast(context, "${praiseAcc.nick} 刚刚赞了你 ～",
              gravity: ToastGravity.BOTTOM, length: Toast.LENGTH_LONG);
        }

        break;
      case 202: // 用户被评论，data: 评论的内容
        // Result<dynamic> r = Result.fromJson(Api.convertResponse((instruction.data)));
        // print(r.toJson());
        setNotificationCnt(notificationCnt + 1);
        TweetReply tr = TweetReply.fromJson(instruction.data);
        if (tr != null) {
          String displayReply =
              StringUtil.isEmpty(tr.body) ? null : (tr.body.length > 6 ? tr.body.substring(0, 6) : tr.body);
          String displayContent = (tr.anonymous || tr.account == null || StringUtil.isEmpty(tr.account.nick))
              ? "有位童鞋默默回复了你 ～"
              : "${tr.account.nick} 刚刚回复了你${displayReply == null ? ' ～ ' : '：$displayReply'}";
          ToastUtil.showToast(context, '$displayContent', gravity: ToastGravity.BOTTOM);
        }
        break;
      case 203: // 推文被删除，data: 删除的推文id
        int detTweetId = instruction.data;
        Provider.of<TweetProvider>(context).delete(detTweetId);
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _notificationStreamCntCtrl?.close();
  }
}
