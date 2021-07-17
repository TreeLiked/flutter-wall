part of 'msg_bloc.dart';

abstract class MsgState {}

class MsgInitial extends MsgState {
  int sysCnt;
  int tweetInterCnt;

  int cirInterCnt;
  int cirSysCnt;

  MsgInitial({this.sysCnt = 0, this.tweetInterCnt = 0, this.cirInterCnt = 0, this.cirSysCnt = 0});
}
