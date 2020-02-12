import 'package:flutter/material.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:provider/provider.dart';

class HomeCommentWrapper extends StatefulWidget {
  final sendCallback;

  HomeCommentWrapper({Key key, this.sendCallback}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeCommentWrapperState();
  }
}

class HomeCommentWrapperState extends State<HomeCommentWrapper> {
  double _replyContainerHeight = 0;
  bool showAnonymous = false;

  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();
  String _hintText = "说点什么吧";

  TweetReply curReply;
  String destAccountId;

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountLocalProvider>(builder: (_, provider, __) {
      return Offstage(
          offstage: false,
          child: AnimatedOpacity(
              opacity: _replyContainerHeight != 0 ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: Container(
                  width: _replyContainerHeight,
                  decoration: BoxDecoration(
                    color: ThemeUtils.isDark(context) ? Color(0xff363636) : Color(0xfff2f3f4),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(7),
                      topRight: const Radius.circular(7),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(11, 7, 15, 7),
                  child: Row(
                    children: <Widget>[
                      AccountAvatar(
                        cache: true,
                        avatarUrl: provider.account.avatarUrl,
                        size: SizeConstant.TWEET_PROFILE_SIZE * 0.85,
                      ),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              keyboardAppearance: Theme.of(context).brightness,
                              decoration: InputDecoration(
                                  suffixIcon: curReply != null && curReply.type == 1
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              curReply.anonymous = !curReply.anonymous;
                                              if (curReply.anonymous) {
                                                ToastUtil.showToast(context, '此条评论将匿名回复');
                                              }
                                            });
                                          },
                                          child: Icon(
                                            curReply.anonymous ? Icons.visibility_off : Icons.visibility,
                                            size: SizeConstant.TWEET_PROFILE_SIZE * 0.5,
                                            color: curReply.anonymous ? Colors.blueAccent : Colors.grey,
                                          ),
                                        )
                                      : null,
                                  hintText: _hintText,
                                  border: InputBorder.none,
                                  hintStyle: const TextStyle(
                                    color: ColorConstant.TWEET_TIME_COLOR,
                                    fontSize: SizeConstant.TWEET_TIME_SIZE - 1,
                                  )),
                              textInputAction: TextInputAction.send,
                              cursorColor: Colors.grey,
                              style: const TextStyle(
                                fontSize: SizeConstant.TWEET_FONT_SIZE - 1,
                              ),
                              onSubmitted: (value) {
                                _sendReply(value);
                              },
                            )),
                      ),
                    ],
                  ))));
    });
  }

  _sendReply(String value) async {
    if (StringUtil.isEmpty(value) || value.trim().length == 0) {
      ToastUtil.showToast(context, '回复内容不能为空');
      return;
    }
    Utils.showDefaultLoadingWithBounds(context, text: '');
    curReply.body = value;
    Account acc = Account.fromId(Application.getAccountId);
    curReply.account = acc;

    await TweetApi.pushReply(curReply, curReply.tweetId).then((result) {
      print(result.data);
      if (result.isSuccess) {
        TweetReply newReply = TweetReply.fromJson(result.data);
        _controller.clear();
        hideReplyContainer();
        final _tweetProvider = Provider.of<TweetProvider>(context);
        _tweetProvider.updateReply(context, newReply);
//        widget.sendCallback(newReply);
      } else {
        _controller.clear();
        _hintText = "评论";
        ToastUtil.showToast(context, '回复失败');
      }
      NavigatorUtils.goBack(context);
    });
  }

  void showReplyContainer(TweetReply tr, String destAccountNick, String destAccountId) {
    print('home page 回调 =============== $destAccountNick----------------${tr.type}');
    if (StringUtil.isEmpty(destAccountNick)) {
      setState(() {
        if (tr.type == 1) {
          showAnonymous = true;
        } else {
          showAnonymous = false;
        }
        _hintText = "评论";
        curReply = tr;
        _replyContainerHeight = MediaQuery.of(context).size.width;
        this.destAccountId = destAccountId;
      });
    } else {
      setState(() {
        if (tr.type == 1) {
          showAnonymous = true;
        } else {
          showAnonymous = false;
        }
        _hintText = "回复 $destAccountNick";
        curReply = tr;
        _replyContainerHeight = MediaQuery.of(context).size.width;
        this.destAccountId = destAccountId;
      });
    }
    _focusNode.requestFocus();
  }

  void hideReplyContainer() {
    if (_replyContainerHeight != 0) {
      setState(() {
        _replyContainerHeight = 0;
        _controller.clear();
        _focusNode.unfocus();
      });
    }
  }
}
