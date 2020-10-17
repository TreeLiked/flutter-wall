import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/component/RoundContainer.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:provider/provider.dart';

class TweetIndexCommentWrapper extends StatefulWidget {
  int replyType;
  bool showAnonymous;
  String hintText;
  final Function onSend;

  TweetIndexCommentWrapper(
      {Key key, this.replyType, this.showAnonymous = false, this.hintText = "发表我的看法", @required this.onSend})
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

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeUtils.isDark(context);
    return Container(
        decoration: BoxDecoration(
          color: isDark ? Color(0xff363636) : ColorConstant.TWEET_RICH_BG_2,
        ),
        padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Consumer<AccountLocalProvider>(builder: (_, provider, __) {
            return AccountAvatar(
              cache: true,
              avatarUrl: _anonymous ? PathConstant.ANONYMOUS_PROFILE : provider.account.avatarUrl,
              size: SizeConstant.TWEET_PROFILE_SIZE * 0.85,
            );
          }),
          Gaps.hGap10,
          Expanded(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  child: TextField(
                autofocus: true,
                controller: _controller,
                focusNode: _focusNode,
                maxLength: 512,
                maxLines: 1,
                maxLengthEnforced: false,
                keyboardAppearance: Theme.of(context).brightness,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 10.0),
                    fillColor: isDark ? ColorConstant.MAIN_BG_DARK : ColorConstant.MAIN_BG,
                    filled: true,
                    alignLabelWithHint: true,
                    counterText: '',
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    hintStyle:
                        const TextStyle(color: ColorConstant.TWEET_TIME_COLOR, fontSize: Dimens.font_sp15)),
                textInputAction: TextInputAction.send,
                cursorColor: Colors.amber,
                autocorrect: false,
                style: const TextStyle(fontSize: Dimens.font_sp15, letterSpacing: 1.1),
                onSubmitted: (value) {
                  _sendReply(value);
                },
              )),
              Gaps.vGap8,
              widget.showAnonymous
                  ? OptionItem(
                      "匿名回复",
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
                            ), () {
                      setState(() {
                        _anonymous = !_anonymous;
                        if (_anonymous) {
                          ToastUtil.showToast(context, '此条评论将匿名回复');
                        }
                      });
                    })
                  : Gaps.empty
            ],
          )),
        ]));
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

  OptionItem(this.text, this.icon, this.onTap, {this.leftMargin = 0.0, this.rightMargin = 5.0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: RoundContainer(
          radius: 12.0,
          margin: EdgeInsets.only(left: leftMargin, right: rightMargin),
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
          backgroundColor: ThemeUtils.isDark(context) ? ColorConstant.TWEET_RICH_BG_DARK : Color(0xffeae9ea),
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
