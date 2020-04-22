import 'dart:async';

import 'package:iap_app/api/message.dart';
import 'package:iap_app/bloc/count_bloc.dart';
import 'package:iap_app/page/notification/index.dart';

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

  static int interactionCnt = -1;
  static int notificationCnt = -1;

  static final SingleMessageControl interactionMsgControl = new SingleMessageControl();
  static final SingleMessageControl systemMsgControl = new SingleMessageControl();

  static final StreamController<int> _notificationStreamCntCtrl = new StreamController<int>.broadcast();
  static final StreamController<int> _interactionStreamCntCtrl = new StreamController<int>.broadcast();
  static final StreamController<int> _systemStreamCntCtrl = new StreamController<int>.broadcast();

  static get notificationStreamCntCtrl => _notificationStreamCntCtrl;

  static get interactionStreamCntCtrl => _interactionStreamCntCtrl;

  static get systemStreamCntCtrl => _systemStreamCntCtrl;

  static void setNotificationCnt(int count) {
    if (notificationCnt != count && _notificationStreamCntCtrl != null) {
      notificationCnt = count;
//      NotificationIndexPage
      _notificationStreamCntCtrl.sink.add(count);
    }
  }

  static void clearNotificationCnt() {
    notificationCnt = -1;
    _notificationStreamCntCtrl.sink.add(-1);
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
  }

  @override
  void dispose() {
    _notificationStreamCntCtrl?.close();
  }
}
