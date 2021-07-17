import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'msg_event.dart';

part 'msg_state.dart';

class MsgBloc extends Bloc<MsgEvent, MsgState> {
  MsgBloc() : super(MsgInitial());

  @override
  Stream<MsgState> mapEventToState(MsgEvent event) async* {
    // TODO: implement mapEventToState
  }
}
