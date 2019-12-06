import 'package:flutter/material.dart';

class FutureBuilderWidget<T> extends StatefulWidget {
  final Widget loadingWidget;
  final Widget errorWidget;
  final NetNormalWidget<T> commonWidget;

  final LoadDataFuture<T> loadData;

  FutureBuilderWidget(
      {@required this.commonWidget,
      @required this.loadData,
      this.loadingWidget,
      this.errorWidget});

  @override
  State<StatefulWidget> createState() => _FutureBuilderWidgetState<T>();
}

///实现State方法并mixins网络出错点击回调
class _FutureBuilderWidgetState<T> extends State<FutureBuilderWidget<T>> {
  @override
  void initState() {
    super.initState();
    widget.loadData(context);
  }

  ///默认加载界面
  final defaultLoading = Center(
    child: CircularProgressIndicator(),
  );

  ///默认出错界面
  Widget _defaultError(dynamic error) {
    return Center(
      child: Text(error.toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.loadData(context),
        builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              break;
            case ConnectionState.waiting:
            case ConnectionState.active:
              return widget.loadingWidget ?? defaultLoading;
            case ConnectionState.done:
              if (snapshot.hasError) {
                ///网络出错
                return Container();
              }
              return widget.commonWidget.buildContainer(snapshot.data);
          }
        });
  }

  @override
  void retryCall() {
    widget.loadData(context);
    setState(() {
      ///通知State重新构建界面需要
    });
  }
}

typedef LoadDataFuture<T> = Future<T> Function(BuildContext context);

abstract class NetNormalWidget<T> extends StatelessWidget {
  final T bean; //通用数据类

  NetNormalWidget({this.bean});

  @override
  Widget build(BuildContext context) {
    return buildContainer(bean);
  }

  ///给定义Widget赋值
  Widget buildContainer(T t);
}
