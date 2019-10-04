import 'dart:core';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/component/InputSelect.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/util/api.dart';
import 'package:iap_app/util/http_util.dart';

class CreatePage extends StatefulWidget {
  final String title = "发布内容";
  @override
  State<StatefulWidget> createState() {
    return _CreatePageState();
  }
}

class _CreatePageState extends State<CreatePage> {
  TextEditingController _controller = TextEditingController();

  // 开启回复
  bool _enbaleReply = true;
  // 是否匿名
  bool _anonymous = false;

  String _typeText = "";
  String _typeName = "";

  String _textCountText = "";

  // 是否禁用发布按钮
  bool _isPushBtnEnabled = false;

  void _updateTypeText(String text, String typeName) {
    setState(() {
      this._typeText = text;
      this._typeName = typeName;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  BaseTweet _assembleTweet() {
    BaseTweet _baseTweet = BaseTweet();
    print(_baseTweet.toJson());
    return _baseTweet;
  }

  // Widget _bottomSheetItem(IconData leftIcon, String text) {
  //   print(text + " " + _typeText);
  //   return Material(
  //     color: Colors.transparent,
  //     child: Ink(
  //       child: InkWell(
  //         onTap: () {
  //           this._updateTypeText(text);
  //           Navigator.pop(context);
  //         },
  //         child: Container(
  //             alignment: Alignment.centerLeft,
  //             padding: EdgeInsets.symmetric(vertical: 5),
  //             child: Chip(
  //                 label: Text(text),
  //                 avatar: Icon(Icons.add_location, color: Colors.lightBlue))),
  //       ),
  //     ),
  //   );
  // }

  void _reverseAnonymous() {
    setState(() {
      this._anonymous = !this._anonymous;
    });
  }

  void _reverseEnableReply() {
    setState(() {
      this._enbaleReply = !this._enbaleReply;
    });
  }

  Widget _clipItemInSheet(
      String text, String typeName, IconData iconData, Color iconColor) {
    return GestureDetector(
        onTap: () {
          this._updateTypeText(text, typeName);
          Navigator.of(context).pop(this);
        },
        child: Chip(
          backgroundColor: GlobalConfig.DEFAULT_BAR_BACK_COLOR,
          label: Text(
            text,
            style: TextStyle(fontSize: 14),
          ),
          avatar: Icon(
            iconData,
            size: 15,
            color: iconColor,
          ),
        ));
  }

  void _modalBottomSheetMenu() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return StatefulBuilder(builder: (context1, state) {
            return Stack(
              children: <Widget>[
                Container(
                  height: 30.0,
                  width: double.infinity,
                  color: Colors.black54,
                ),
                Container(
                    // height: 350,
                    // constraints: BoxConstraints(maxHeight: 500),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16))),
                    child: FractionallySizedBox(
                        heightFactor: 0.46,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    '- 请选择内容类型 -',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 18),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                    child: Wrap(
                                  spacing: 2,
                                  alignment: WrapAlignment.start,
                                  runAlignment: WrapAlignment.spaceEvenly,
                                  runSpacing: 5,
                                  children: <Widget>[
                                    _clipItemInSheet(
                                        TweetTypeEntity.LOVE_CONFESSION.zhTag,
                                        TweetTypeEntity.LOVE_CONFESSION.name,
                                        Icons.favorite,
                                        Colors.red),
                                    _clipItemInSheet(
                                        TweetTypeEntity.ASK_FOR_MARRIAGE.zhTag,
                                        TweetTypeEntity.ASK_FOR_MARRIAGE.name,
                                        Icons.people,
                                        Colors.red),
                                    _clipItemInSheet(
                                        TweetTypeEntity.SOMEONE_FIND.zhTag,
                                        TweetTypeEntity.SOMEONE_FIND.name,
                                        Icons.face,
                                        Colors.blue),
                                    _clipItemInSheet(
                                        TweetTypeEntity.QUESTION_CONSULT.zhTag,
                                        TweetTypeEntity.QUESTION_CONSULT.name,
                                        Icons.help_outline,
                                        Colors.orange),
                                    _clipItemInSheet(
                                        TweetTypeEntity.GOSSIP.zhTag,
                                        TweetTypeEntity.GOSSIP.name,
                                        Icons.mic_none,
                                        Colors.blue),
                                    _clipItemInSheet(
                                        TweetTypeEntity.COMPLAINT.zhTag,
                                        TweetTypeEntity.COMPLAINT.name,
                                        Icons.mic,
                                        Colors.blue),
                                    _clipItemInSheet(
                                        TweetTypeEntity.HAVE_FUN.zhTag,
                                        TweetTypeEntity.HAVE_FUN.name,
                                        Icons.toys,
                                        Colors.lightGreen),
                                    _clipItemInSheet(
                                        TweetTypeEntity.LOST_AND_FOUND.zhTag,
                                        TweetTypeEntity.LOST_AND_FOUND.name,
                                        Icons.build,
                                        Colors.red),
                                    _clipItemInSheet(
                                        TweetTypeEntity.HELP_AND_REWARD.zhTag,
                                        TweetTypeEntity.HELP_AND_REWARD.name,
                                        Icons.fingerprint,
                                        Colors.lightGreen),
                                    _clipItemInSheet(
                                        TweetTypeEntity
                                            .SECOND_HAND_TRANSACTION.zhTag,
                                        TweetTypeEntity
                                            .SECOND_HAND_TRANSACTION.name,
                                        Icons.compare_arrows,
                                        Colors.red),
                                  ],
                                )),
                              )
                            ],
                          ),
                        ))),
              ],
            );
          });
        });
  }

  InkWell _rowItem(IconData iconData, String text, Function callback, bool show,
      IconData defaultIcon) {
    return InkWell(
      onTap: () {
        callback();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 13, horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(
              iconData,
              size: GlobalConfig.CREATE_ICON_SIZE,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                text,
                style: TextStyle(fontSize: GlobalConfig.CREATE_ICON_FONT_SIZE),
              ),
            ),
            Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Text(
                        defaultIcon == null ? "" : this._typeText,
                        style: TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                    ),
                    Icon(
                      defaultIcon == null ? Icons.done : defaultIcon,
                      color: defaultIcon != null
                          ? (this._typeText == ""
                              ? GlobalConfig.tweetTimeColor
                              : Colors.blue)
                          : Colors.blue,
                      size: show ? 23 : 0,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  void showSnackBarText(BuildContext context, String text, bool white) =>
      Scaffold.of(context).showSnackBar(new SnackBar(
        duration: Duration(seconds: 1),
        content: Text(
          text,
          style: TextStyle(color: white ? Colors.black : Colors.white),
        ),
        backgroundColor: white ? Colors.white : Colors.black,
      ));

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text(widget.title,
              style: TextStyle(fontSize: GlobalConfig.TEXT_TITLE_SIZE)),
          // backgroundColor: GlobalConfig.DEFAULT_BAR_BACK_COLOR,
          elevation: 0,
          toolbarOpacity: 1,
          actions: <Widget>[
            Container(
              height: 10,
              child: FlatButton(
                onPressed: _isPushBtnEnabled && this._typeName != ""
                    ? () {
                        this._assembleTweet();
                      }
                    : null,
                child: Text(
                  '发表',
                ),
                disabledTextColor: Colors.grey,
                textColor: Colors.blue,
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: Container(
          child: new Container(
            padding: EdgeInsets.all(10),
            child: new Column(
              children: <Widget>[
                Flexible(
                  child: Container(
                      child: PreferredSize(
                    preferredSize: Size.fromHeight(300),
                    child: TextField(
                      controller: _controller,
                      cursorColor: Colors.blue,
                      maxLengthEnforced: true,
                      maxLength: GlobalConfig.TWEET_MAX_LENGTH,
                      keyboardType: TextInputType.multiline,
                      maxLines: 10,
                      style: TextStyle(fontSize: 17),
                      decoration: new InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(5),
                          counterText: _textCountText),
                      onChanged: (val) {
                        setState(() {
                          this._isPushBtnEnabled = val.length > 0;
                          this._textCountText = (val.length == 0
                              ? ''
                              : val.length.toString() +
                                  ' /' +
                                  GlobalConfig.TWEET_MAX_LENGTH.toString());
                        });
                      },
                    ),
                  )),
                ),
                Divider(
                  height: 1.0,
                  indent: 0.0,
                  color: Color(0xffF5F5F5),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Column(
                    children: <Widget>[
                      _rowItem(
                          Icons.blur_on,
                          "内容类型",
                          this._modalBottomSheetMenu,
                          true,
                          Icons.chevron_right),
                      _rowItem(Icons.flare, "为我匿名", this._reverseAnonymous,
                          this._anonymous, null),
                      _rowItem(Icons.rss_feed, "开启评论", this._reverseEnableReply,
                          this._enbaleReply, null),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
