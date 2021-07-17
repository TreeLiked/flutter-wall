import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iap_app/res/gaps.dart';

class MyCustomHeader extends StatefulWidget {
  final LinkHeaderNotifier linkNotifier;

  const MyCustomHeader(this.linkNotifier, {Key key}) : super(key: key);

  @override
  CustomHeaderState createState() {
    return CustomHeaderState();
  }
}

class CustomHeaderState extends State<MyCustomHeader> {
  // 指示器值
  double _indicatorValue = 0.0;

  RefreshMode get _refreshState => widget.linkNotifier.refreshState;

  double get _pulledExtent => widget.linkNotifier.pulledExtent;

  @override
  void initState() {
    super.initState();
    widget.linkNotifier.addListener(onLinkNotify);
  }

  void onLinkNotify() {
    setState(() {
      _indicatorValue = null;
      if (_refreshState == RefreshMode.armed || _refreshState == RefreshMode.refresh) {
        _indicatorValue = null;
      } else if (_refreshState == RefreshMode.refreshed || _refreshState == RefreshMode.done) {
        _indicatorValue = 1.0;
      } else {
        if (_refreshState == RefreshMode.inactive) {
          _indicatorValue = 0.0;
        } else {
          double indicatorValue = _pulledExtent / 70.0 * 0.8;
          _indicatorValue = indicatorValue < 0.8 ? indicatorValue : 0.8;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double size = (_indicatorValue == null || _indicatorValue < 1) ? 20 : 28;
    return Center(
        child: Container(
      alignment: Alignment.center,
      // margin: EdgeInsets.only(
      //   right: 20.0,
      // ),
      width: size,
      height: size,
      child: (_indicatorValue == null || _indicatorValue == 0)
          ? Gaps.empty
          : _indicatorValue >= 1
              ? SpinKitFadingCircle(
                  color: Colors.white,
                  size: size,
                )
              : CircularProgressIndicator(
                  value: _indicatorValue,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 2.0,
                ),
    ));
  }
}
