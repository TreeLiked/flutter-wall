import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iap_app/api/dict.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/component/RoundContainer.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:provider/provider.dart';

class TweetIndexCommentWrapper extends StatefulWidget {
  int replyType;
  bool showAnonymous;
  String hintText;
  final int tweetId;
  final Function onSend;

  TweetIndexCommentWrapper(
      {Key key,
      this.replyType,
      this.showAnonymous = false,
      this.hintText = "发表我的看法",
      @required this.onSend,
      @required this.tweetId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TweetIndexCommentWrapperState();
  }
}

class _TweetIndexCommentWrapperState extends State<TweetIndexCommentWrapper> {
  double _replyContainerWidth = 0;

  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();

  String destAccountId;

  bool _anonymous = false;

  bool _displayChangeTalk = false;

  List<String> speaks = [];
  int speakLastIndex = -1;

  @override
  void initState() {
    _focusNode.requestFocus();
    loadSpeaks(true);
    _controller.addListener(() {
      String c = _controller.text;
      bool next = !StringUtil.isEmpty(c) && c.startsWith("\“") && c.endsWith("\”") && c.length > 2;
      if (_displayChangeTalk != next) {
        setState(() {
          _displayChangeTalk = next;
        });
      }
    });
  }

  void loadSpeaks(bool init) async {
    if (!init) {
      Utils.showDefaultLoadingWithBounds(context);
    }
    await DictApi.queryTweetCommentSpeaks(widget.tweetId).then((value) {
      if (value != null || value.length > 0) {
        setState(() {
          this.speaks = value;
        });
      } else {
        if (!init) {
          ToastUtil.showToast(context, '╮(╯▽╰)╭ ');
        }
      }
    });
    if (!init) {
      NavigatorUtils.goBack(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeUtils.isDark(context);
    double accContainerWidth = SizeConstant.TWEET_PROFILE_SIZE * 0.85;
    return Container(
        decoration: BoxDecoration(
          color: isDark ? Color(0xff363636) : ColorConstant.TWEET_RICH_BG_2,
        ),
        padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 15.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  Container(
                    width: accContainerWidth,
                    child: Consumer<AccountLocalProvider>(builder: (_, provider, __) {
                      return AccountAvatar(
                        cache: true,
                        whitePadding: isDark,
                        avatarUrl: _anonymous ? PathConstant.ANONYMOUS_PROFILE : provider.account.avatarUrl,
                        size: SizeConstant.TWEET_PROFILE_SIZE * 0.85,
                      );
                    }),
                  ),
                  Gaps.hGap10,
                  Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13.0),
                          color: ThemeUtils.isDark(context) ? Color(0xff363636) : ColorConstant.TWEET_RICH_BG,
                        ),
                        child: TextField(
                          autofocus: true,
                          controller: _controller,
                          focusNode: _focusNode,
                          maxLength: 512,
                          maxLines: 1,
                          maxLengthEnforced: false,
                          keyboardAppearance: Theme.of(context).brightness,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 10.0, top: 1.0),
                              fillColor: isDark ? ColorConstant.MAIN_BG_DARK : ColorConstant.MAIN_BG,
                              filled: true,
                              alignLabelWithHint: true,
                              counterText: '',
                              hintText: widget.hintText,
                              border: InputBorder.none,
                              // disabledBorder: InputBorder.none,
                              // enabledBorder: OutlineInputBorder(
                              //   /*边角*/
                              //   borderRadius: BorderRadius.all(
                              //     Radius.circular(5), //边角为5
                              //   ),
                              //
                              // ),
                              // focusedErrorBorder: InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                // borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: Colors.amber[100], //边线颜色为白色
                                  width: 1, //边线宽度为2
                                ),
                              ),
                              hintStyle: pfStyle.copyWith(
                                  color: ColorConstant.TWEET_TIME_COLOR,
                                  fontSize: Dimens.font_sp14,
                                  letterSpacing: 1.0)),
                          textInputAction: TextInputAction.send,
                          cursorColor: Colors.amber,
                          autocorrect: false,
                          style: pfStyle.copyWith(fontSize: Dimens.font_sp14, letterSpacing: 1.0),
                          onSubmitted: (value) {
                            _sendReply(value);
                          },
                        )),
                  ),
                ],
              ),
              Gaps.vGap10,
              Container(
                margin: EdgeInsets.only(left: accContainerWidth + 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.showAnonymous
                        ? OptionItem(
                            "匿名回复 ",
                            _anonymous
                                ? Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 15.0,
                                  )
                                : Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.grey,
                                    size: 15.0,
                                  ),
                            () {
                              setState(() {
                                _anonymous = !_anonymous;
                                if (_anonymous) {
                                  ToastUtil.showToast(context, '此条评论将匿名回复');
                                }
                              });
                            },
                            leftMargin: 0.0,
                            rightMargin: 0.0,
                            radius: 5.0,
                          )
                        : Gaps.empty,
                    OptionItem(
                      '\“${_displayChangeTalk ? '换一个' : '说个梗'}\” ',
                      Icon(Icons.auto_awesome, size: 15.0, color: isDark ? Colors.grey : Colors.amber[400]),
                      () {
                        if (speaks.isNotEmpty) {
                          int i = getUnrepeatIndex();
                          setState(() {
                            speakLastIndex = i;
                            _controller.text = speaks[i];
                          });
                        } else {
                          ToastUtil.showToast(context, '╮(╯▽╰)╭ ');
                        }
                      },
                      radius: 5.0,
                      rightMargin: 0,
                    ),
                  ],
                ),
              ),
            ]));
  }

  int getUnrepeatIndex() {
    int i = Random().nextInt(speaks.length);
    if (speakLastIndex != -1) {
      // 尝试重新选一次
      if (speakLastIndex == i) {
        return getUnrepeatIndex();
      }
    }
    return i;
  }

  _sendReply(String value) async {
    if (StringUtil.isEmpty(value) || value.trim().length == 0) {
      ToastUtil.showToast(context, '回复内容不能为空');
      return;
    }
    if (widget.onSend != null) {
      widget.onSend(value, _anonymous);
    }
  }

//  void showReplyContainer(TweetReply tr, String destAccountNick, String destAccountId) {
//    if (StringUtil.isEmpty(destAccountNick)) {
//      setState(() {
//        if (tr.type == 1) {
//          showAnonymous = true;
//        } else {
//          showAnonymous = false;
//        }
//        _hintText = "评论";
//        curReply = tr;
//        _replyContainerWidth = MediaQuery.of(context).size.width;
//        this.destAccountId = destAccountId;
//      });
//    } else {
//      setState(() {
//        if (tr.type == 1) {
//          showAnonymous = true;
//        } else {
//          showAnonymous = false;
//        }
//        _hintText = "回复 $destAccountNick";
//        curReply = tr;
//        _replyContainerWidth = MediaQuery.of(context).size.width;
//        this.destAccountId = destAccountId;
//      });
//    }
//    _focusNode.requestFocus();
//  }

  void hideReplyContainer() {
    if (_replyContainerWidth != 0) {
      setState(() {
        _replyContainerWidth = 0;
        _controller.clear();
        _focusNode.unfocus();
      });
    }
  }
}

class OptionItem extends StatelessWidget {
  final String text;
  final Icon icon;
  final Function onTap;

  final double leftMargin;
  final double rightMargin;

  final double radius;

  OptionItem(this.text, this.icon, this.onTap,
      {this.leftMargin = 0.0, this.rightMargin = 5.0, this.radius = 12.0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: RoundContainer(
          radius: radius,
          margin: EdgeInsets.only(left: leftMargin, right: rightMargin),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
          backgroundColor: ThemeUtils.isDark(context) ? ColorConstant.MAIN_BG_DARK : Color(0xffebebeb),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "$text",
                style: const TextStyle(fontSize: Dimens.font_sp12),
              ),
              icon
            ],
          ),
        ));
  }
}
