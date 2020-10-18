import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/style/text_style.dart';

typedef ValueWidgetBuilder<T> = Widget Function(
  BuildContext context,
  T value,
);

/// FutureBuilder 简单封装，除正确返回和错误外，其他返回 小菊花
/// 错误时返回定义好的错误 Widget，例如点击重新请求
class CustomSliverFutureBuilder<T> extends StatefulWidget {
  final ValueWidgetBuilder<T> builder;
  final Function futureFunc;
  final Map<String, dynamic> params;

  CustomSliverFutureBuilder({
    @required this.futureFunc,
    @required this.builder,
    this.params,
  });

  @override
  _CustomFutureBuilderState<T> createState() => _CustomFutureBuilderState<T>();
}

class _CustomFutureBuilderState<T> extends State<CustomSliverFutureBuilder<T>> {
  Future<T> _future;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((call) {
      _request();
    });
  }

  void _request() {
    setState(() {
      if (widget.params == null)
        _future = widget.futureFunc(context);
      else
        _future = widget.futureFunc(context, params: widget.params);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _future == null
        ? Align(
            child: Container(
              alignment: Alignment.center,
              height: ScreenUtil().setWidth(200),
              child: CupertinoActivityIndicator(),
            ),
          )
        : FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return Container(
                      alignment: Alignment.topCenter,
                      height: ScreenUtil().setHeight(300),
                      margin: EdgeInsets.only(top: ScreenUtil().setHeight(300)),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          CupertinoActivityIndicator(),
                          Gaps.vGap20,
                          Text('正在加载', style: MyDefaultTextStyle.getTweetTimeStyle(context))
                        ],
                      ));
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    return widget.builder(context, snapshot.data);
                  } else if (snapshot.hasError) {
                    print(snapshot.error);
                    return Container(
                        alignment: Alignment.topCenter,
                        height: ScreenUtil().setHeight(300),
                        margin: EdgeInsets.only(top: ScreenUtil().setHeight(300)),
                        child: Text("服务错误",
                            style: pfStyle.copyWith(color: Colors.grey, fontSize: Dimens.font_sp15)));
                  }
              }
              return Container();
            },
          );
  }
}
