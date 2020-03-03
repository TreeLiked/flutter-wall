import 'dart:async';

abstract class BaseBloc {
  void dispose();
}

class NotificationCounter extends BaseBloc {
  final _controller = StreamController<int>();

  get _counter => _controller.sink;

  get counter => _controller.stream;

  @override
  void dispose() {
    _controller?.close();
  }
}
