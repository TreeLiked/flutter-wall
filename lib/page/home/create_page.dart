import 'dart:core';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/asset_image.dart';
import 'package:iap_app/component/bottom_sheet_confirm.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/tweet_account.dart';
import 'package:iap_app/model/media.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/page/common/image_origin.dart';
import 'package:iap_app/page/tweet_type_sel.dart';
import 'package:iap_app/part/stateless.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/oss_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:photo/photo.dart';
import 'package:photo_manager/photo_manager.dart';

class CreatePage extends StatefulWidget {
  final String title = "发布内容";

  @override
  State<StatefulWidget> createState() {
    return _CreatePageState();
  }
}

class _CreatePageState extends State<CreatePage> {
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();

  // 开启回复
  bool _enableReply = true;

  // 是否匿名
  bool _anonymous = false;

  String _typeText = "选择标签";

  // 标签tag
  String _typeName = "";

  int _textCountText = 0;

  // 是否禁用发布按钮
  bool _isPushBtnEnabled = false;
  bool _publishing = false;

  // 选中的图片
  List<Asset> pics = List();

  int _maxImageCount = 9;

  // 屏幕宽度
  double sw;

  // 去除边距剩余宽度
  double remain;

  double spacing = 2;

  void _updatePushBtnState() {
    if (((_controller.text.length > 0 && _controller.text.length < 256) ||
            !CollectionUtil.isListEmpty(this.pics)) &&
        !StringUtil.isEmpty(this._typeName)) {
      if (this._isPushBtnEnabled == false) {
        setState(() {
          this._isPushBtnEnabled = true;
        });
      }
    } else {
      if (this._isPushBtnEnabled == true) {
        setState(() {
          this._isPushBtnEnabled = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void _assembleAndPushTweet() async {
    if (_controller.text.length >= GlobalConfig.TWEET_MAX_LENGTH) {
      ToastUtil.showToast(context, '内容超出最大字符限制');
      return;
    }
    if (_typeName == null) {
      ToastUtil.showToast(context, '请选择内容类型');
      return;
    }

    _focusNode?.unfocus();
    setState(() {
      this._isPushBtnEnabled = false;
      this._publishing = true;
    });
    BaseTweet _baseTweet = BaseTweet();
    _baseTweet.sentTime = DateTime.now();
    bool hasError = false;
    if (!CollectionUtil.isListEmpty(this.pics)) {
      Utils.showDefaultLoadingWithBounds(context, text: '上传媒体');
      for (int i = 0; i < this.pics.length; i++) {
        ByteData bd = await this.pics[i].getByteData();
        if (bd == null) {
          NavigatorUtils.goBack(context);
          ToastUtil.showToast(context, '图片上传失败');
          return;
        }
        try {
          String result =
              await OssUtil.uploadImage(this.pics[i].name, bd.buffer.asUint8List(), OssUtil.DEST_TWEET);
          print(result);
          if (result != "-1") {
            if (_baseTweet.medias == null) {
              _baseTweet.medias = List();
            }
            // TODO MEDIA
            Media m = new Media();
            m.module = Media.MODULE_TWEET;
            m.name = this.pics[i].name;
            m.mediaType = Media.TYPE_IMAGE;
            m.url = result;
            m.index = i;
            _baseTweet.medias.add(m);
          } else {
            hasError = true;
            break;
          }
        } catch (exp) {
          hasError = true;
          print(exp);
        } finally {
          print('第$i张图片上传完成');
        }
      }
      Navigator.pop(context);
    }
    Utils.showDefaultLoadingWithBounds(context, text: '正在发布');
    if (!hasError) {
      _baseTweet.type = _typeName;
      _baseTweet.body = _controller.text;
      TweetAccount ta = TweetAccount();
      Account temp = Application.getAccount;
      ta.id = temp.id ?? "";
      _baseTweet.account = ta;
      _baseTweet.enableReply = _enableReply;
      _baseTweet.anonymous = _anonymous;
      _baseTweet.orgId = Application.getOrgId;
      print(_baseTweet.toJson());
      TweetApi.pushTweet(_baseTweet).then((result) {
        Navigator.of(context).pop();
        Result r = Result.fromJson(result);
        print(r.isSuccess);
        if (r.isSuccess) {
          NavigatorUtils.goBack(context);
        } else {
          ToastUtil.showToast(context, r.message);
        }
      });
    } else {
      Navigator.pop(context);
      ToastUtil.showToast(context, '发布出错，请稍后重试');
    }
    setState(() {
      this._publishing = false;
    });
    _updatePushBtnState();
  }

  void _selectTypeCallback(List<String> typeNames) {
    if (!CollectionUtil.isListEmpty(typeNames)) {
      this._typeName = typeNames[0];
      this._typeText = tweetTypeMap[typeNames[0]].zhTag;
    }
    _updatePushBtnState();
  }

  void _reverseAnonymous() {
    setState(() {
      this._anonymous = !this._anonymous;
    });
  }

  void _reverseEnableReply() {
    setState(() {
      this._enableReply = !this._enableReply;
    });
  }

  void _forwardSelPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TweetTypeSelect(
                  title: "选择内容类型",
                  finishText: "完成",
                  needVisible: false,
                  initNames: !StringUtil.isEmpty(_typeName) ? [_typeName] : null,
                  callback: (typeNames) => _selectTypeCallback(typeNames),
                )));
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: _maxImageCount,
        enableCamera: true,
        selectedAssets: pics,
        cupertinoOptions: CupertinoOptions(
          takePhotoIcon: "chat",
        ),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "选择图片",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      debugPrint("$e");
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      pics = resultList;
    });
  }

  void pickImage(PickType type) async {
    await loadAssets();
    _updatePushBtnState();
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
    print("create page build");
    sw = ScreenUtil.screenWidthDp;
    return new Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: new AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Text("取消",
              style: TextStyle(
                color: Theme.of(context).textTheme.subhead.color,
              )),
        ),
        elevation: 0,
        toolbarOpacity: 0.8,
        actions: <Widget>[
          Container(
            height: 10,
            child: FlatButton(
              onPressed: _isPushBtnEnabled && !_publishing
                  ? () {
                      this._assembleAndPushTweet();
                    }
                  : null,
              child: Text(
                '发表',
                style: TextStyle(
                  color: _isPushBtnEnabled ? Colors.blue : Colors.grey,
                ),
              ),
              disabledTextColor: Colors.grey,
              textColor: Colors.blue,
            ),
          )
        ],
      ),
      backgroundColor: Color(0xfff7f8f9),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () => _hideKeyB(),
              onPanDown: (_) => _hideKeyB(),
              child: new Container(
                color: Colors.white,
                padding: const EdgeInsets.only(left: 5, right: 10, bottom: 10),
                margin: const EdgeInsets.only(bottom: 20),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(right: 3.0, top: 5.0),
                      child: TextField(
                        keyboardAppearance: Theme.of(context).brightness,
                        controller: _controller,
                        focusNode: _focusNode,
                        cursorColor: Colors.blue,
                        maxLengthEnforced: true,
                        maxLength: GlobalConfig.TWEET_MAX_LENGTH,
                        keyboardType: TextInputType.multiline,
                        autocorrect: false,
                        maxLines: 8,
                        style: TextStyle(
                            height: 1.5, fontSize: SizeConstant.TWEET_FONT_SIZE, color: Colors.black),
                        decoration: new InputDecoration(
                            hintText: '分享校园新鲜事',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(5),
                            counter: Text(
                              _textCountText < GlobalConfig.TWEET_MAX_LENGTH
                                  ? ""
                                  : "最大长度 ${GlobalConfig.TWEET_MAX_LENGTH}",
                              style: TextStyle(color: Color(0xffb22222)),
                            )),
                        onChanged: (val) {
                          _updatePushBtnState();
                        },
                      ),
                    ),

                    Wrap(
                      alignment: WrapAlignment.start,
                      children: <Widget>[
                        Wrap(
                          runSpacing: spacing,
                          spacing: spacing,
                          alignment: WrapAlignment.start,
                          children: getPicList(),
                        ),
                      ],
                    ),

                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => _reverseEnableReply(),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: const BoxDecoration(
                                  color: Color(0xffF5F5F5),
                                  borderRadius: BorderRadius.all(Radius.circular(15))),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    _enableReply ? Icons.lock_open : Icons.lock,
                                    color: _enableReply ? Color(0xff87CEEB) : Colors.grey,
                                    size: 16,
                                  ),
                                  Text(
                                    " " + (_enableReply ? "允许评论 " : "禁止评论 "),
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _reverseAnonymous(),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: const BoxDecoration(
                                  color: Color(0xffF5F5F5),
                                  borderRadius: BorderRadius.all(Radius.circular(15))),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    _anonymous ? Icons.visibility_off : Icons.visibility,
                                    color: _anonymous ? Color(0xff87CEEB) : Colors.grey,
                                    size: 16,
                                  ),
                                  Text(
                                    " " + (_anonymous ? "匿名" : "公开"),
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () => _forwardSelPage(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: const BoxDecoration(
                                      color: Color(0xffF5F5F5),
                                      borderRadius: BorderRadius.all(Radius.circular(15))),
                                  child: Text(
                                    "# " + _typeText,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: !StringUtil.isEmpty(_typeName) ? Colors.blue : Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          )),
                        ],
                      ),
                    ),

                    // StatelessWdigetWrapper(Text('hello')),
                  ],
                ),
              ),
            ),
            // Container(
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.end,
            //     mainAxisSize: MainAxisSize.max,
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: <Widget>[
            //       Padding(
            //         padding: EdgeInsets.only(top: 2, left: 4),
            //         child: Text(
            //           '请勿发布广告等标签无关内容，\n否则您的账号可能会被永久封禁',
            //           style: TextStyles.textGray12,
            //           softWrap: true,
            //         ),
            //       )
            //     ],
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  void _hideKeyB() {
    setState(() {
      _focusNode.unfocus();
    });
  }

  Widget getImageSelWidget() {
    double width = (sw - 18 - spacing * 2) / 3;

    return GestureDetector(
        onTap: () {
          pickImage(PickType.onlyImage);
        },
        child: Container(
          height: width,
          child: Image.asset("assets/images/pic_select.png", width: width),
        ));
  }

  List<Widget> getPicList() {
    double width = (sw - 25 - spacing * 3) / 3;
    List<Widget> widgets = List();

    if (!CollectionUtil.isListEmpty(pics)) {
      for (int j = 0; j < pics.length; j++) {
        widgets.add(GestureDetector(
            onLongPress: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return BottomSheetConfirm(
                    title: '确认删除这张图片吗',
                    optChoice: '删除',
                    onTapOpt: () async {
                      setState(() {
                        this.pics.removeAt(j);
                        _updatePushBtnState();
                      });
                    },
                  );
                },
              );
            },
            onTap: () async {
              ByteData bd = await this.pics[j].getByteData();
              Utils.displayDialog(
                  context,
                  Center(
                    child: GestureDetector(
                        child: Image.memory(bd.buffer.asUint8List(), fit: BoxFit.fitWidth),
                        onTap: () => NavigatorUtils.goBack(context)),
                  ),
                  barrierDismissible: true);
            },
            child: AssetThumb(
              asset: pics[j],
              width: width.toInt(),
              height: width.toInt(),
            )));
      }
    }

    if (pics.length < _maxImageCount) {
      widgets.add(getImageSelWidget());
    }
    return widgets;
  }
}
