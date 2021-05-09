import 'dart:core';
import 'dart:math';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/topic.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/component/bottom_sheet_confirm.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/media.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/topic/add_topic.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/oss_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class TopicCreatePage extends StatefulWidget {
  final String title = "创建话题";

  @override
  State<StatefulWidget> createState() {
    return _TopicCreatePageState();
  }
}

class _TopicCreatePageState extends State<TopicCreatePage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _extraController;
  TextEditingController _tagController;

  FocusNode _focusNode = FocusNode();
  FocusNode _extraFocusNode;
  FocusNode _tagFocusNode;

  int _textCountText = 0;

  // 是否禁用发布按钮
  bool _isPushBtnEnabled = false;
  bool _publishing = false;

  // 选中的图片
  List<Asset> pics = List();

  List<String> tags;

  int _maxImageCount = 3;

  // 屏幕宽度
  double sw;

  // 去除边距剩余宽度
  double remain;

  double spacing = 2;

  bool _showAddExtra = false;
  bool _showAddTags = false;

  var _colors = [Colors.blue, Colors.green, Colors.teal, Colors.indigoAccent, Colors.purple];

  void _updatePushBtnState() {
    if (((_titleController.text.length > 0 && _titleController.text.length < 256))) {
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

  void _assembleAndCreateTopic() async {
    if (_titleController.text.length >= 256) {
      ToastUtil.showToast(context, '内容超出最大字符限制');
      return;
    }

    Utils.showDefaultLoadingWithBounds(context, text: '正在创建话题');
    _focusNode?.unfocus();
    _tagFocusNode?.unfocus();
    _extraFocusNode?.unfocus();

    setState(() {
      this._isPushBtnEnabled = false;
      this._publishing = true;
    });
    bool hasError = false;
    // 创建参数
    AddTopic _addParam = AddTopic();

    if (!CollectionUtil.isListEmpty(this.pics)) {
      // 上传图像
      List<Media> pics = List();
      for (int i = 0; i < this.pics.length; i++) {
        ByteData bd = await this.pics[i].getByteData();
        if (bd == null) {
          NavigatorUtils.goBack(context);
          ToastUtil.showToast(context, '图片上传失败');
          return;
        }
        try {
          String result =
              await OssUtil.uploadImage(this.pics[i].name, bd.buffer.asUint8List(), OssUtil.DEST_TOPIC);
          if (result != "-1") {
            Media m = new Media();
            m.index = i + 1;
            m.name = this.pics[i].name;
            m.url = result;
            m.mediaType = Media.TYPE_IMAGE;
            m.module = Media.MODULE_TOPIC;
            pics.add(m);
          } else {
            hasError = true;
            break;
          }
        } catch (exp) {
          hasError = true;
          print(exp);
          return;
        } finally {
          print('第$i张图片上传完成');
        }
      }
      _addParam.medias = pics;
    }
//    Utils.showDefaultLoadingWithBounds(context, text: '正在发布');

    if (!hasError) {
      _addParam.orgId = Application.getOrgId;
      _addParam.title = _titleController.text;
      _addParam.sentTime = DateUtil.formatDate(DateTime.now());
      if (_extraController != null && !StringUtil.isEmpty(_extraController.text)) {
        _addParam.body = _extraController.text;
      }
      if (tags != null && tags.length > 0) {
        _addParam.tags = List()..addAll(tags);
      }
      print(_addParam.toJson());
      TopicApi.createTopic(_addParam).then((result) {
        Result r = result;
        print(r.isSuccess);
        NavigatorUtils.goBack(context);
        if (r.isSuccess) {
          ToastUtil.showToast(context, "发布成功");
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

  void _reverseShowExtra() {
    if (!this._showAddExtra) {
      this._extraController = TextEditingController();
      this._extraFocusNode = FocusNode();
    }
    setState(() {
      this._showAddExtra = !this._showAddExtra;
    });
  }

  void _reverseShowTags() {
    if (!this._showAddTags) {
      this._tagController = TextEditingController();
      this._tagFocusNode = FocusNode();
    }
    setState(() {
      this._showAddTags = !this._showAddTags;
    });
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: _maxImageCount,
        enableCamera: false,
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

  void pickImage() async {
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
    sw = ScreenUtil.screenWidthPx;
    return new Scaffold(
      resizeToAvoidBottomInset: true,
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
                      this._assembleAndCreateTopic();
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
                margin: const EdgeInsets.only(bottom: 2),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: ScreenUtil().setHeight(249),
                      padding: const EdgeInsets.only(right: 3.0, top: 5.0),
                      child: TextField(
                        keyboardAppearance: Theme.of(context).brightness,
                        controller: _titleController,
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
                            hintText: '创建话题让大家一起来讨论吧',
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
                            onTap: () => _reverseShowExtra(),
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
                                    _showAddExtra ? Icons.remove : Icons.add,
                                    color: _showAddExtra ? Colors.redAccent : Colors.blue,
                                    size: 16,
                                  ),
                                  Text(
                                    " " + (_showAddExtra ? "移除说明 " : "添加话题说明"),
                                    style: TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _reverseShowTags(),
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
                                    _showAddTags ? Icons.remove : Icons.add,
                                    color: _showAddTags ? Colors.redAccent : Colors.blue,
                                    size: 16,
                                  ),
                                  Text(
                                    " " + (_showAddTags ? "移除标签" : "添加话题标签"),
                                    style: TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // StatelessWdigetWrapper(Text('hello')),
                  ],
                ),
              ),
            ),
            _showAddExtra
                ? Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(right: 3.0, top: 5.0),
                    child: TextField(
                      keyboardAppearance: Theme.of(context).brightness,
                      controller: _extraController,
                      focusNode: _extraFocusNode,
                      cursorColor: Colors.blue,
                      maxLengthEnforced: true,
                      maxLength: GlobalConfig.TWEET_MAX_LENGTH,
                      keyboardType: TextInputType.multiline,
                      autocorrect: false,
                      maxLines: 2,
                      style: TextStyle(
                          height: 1.5, fontSize: SizeConstant.TWEET_FONT_SIZE - 1, color: Colors.black54),
                      decoration: new InputDecoration(
                          hintText: '添加话题的说明（这些信息将显示在话题标题的下方）',
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
                  )
                : Gaps.empty,
            _showAddTags && _showAddExtra ? Gaps.vGap2 : Gaps.empty,
            _showAddTags && _tagController != null && _tagController.text.trim().length > 0
                ? Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Wrap(
                      runSpacing: 5,
                      spacing: 10,
                      children: (tags == null || tags.length == 0)
                          ? []
                          : tags.map((tagStr) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    color: Colors.blue.withAlpha(50),
                                    borderRadius: BorderRadius.all(Radius.circular(14))),
                                child: Text(
                                  '$tagStr',
                                  style: TextStyle(color: _colors[Random().nextInt(_colors.length - 1)]),
                                ),
                              );
                            }).toList(),
                    ))
                : Gaps.empty,
            _showAddTags
                ? Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(right: 3.0, top: 5.0),
                    child: TextField(
                      keyboardAppearance: Theme.of(context).brightness,
                      controller: _tagController,
                      focusNode: _tagFocusNode,
                      cursorColor: Colors.blue,
                      maxLengthEnforced: true,
                      maxLength: GlobalConfig.TWEET_MAX_LENGTH,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.done,
                      autocorrect: false,
                      maxLines: 1,
                      style:
                          TextStyle(height: 1.5, fontSize: SizeConstant.TWEET_FONT_SIZE, color: Colors.black),
                      decoration: new InputDecoration(
                          hintText: '话题相关的标签，可自定义，以空格分隔，但不得超过5个',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(5),
                          counter: Text(
                            _textCountText < GlobalConfig.TWEET_MAX_LENGTH
                                ? ""
                                : "最大长度 ${GlobalConfig.TWEET_MAX_LENGTH}",
                            style: TextStyle(color: Color(0xffb22222)),
                          )),
                      onSubmitted: (val) {
                        _renderTags();
                      },
//                      onChanged: (val) {},
                    ),
                  )
                : Gaps.empty,
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

  void _renderTags() {
    if (_tagController != null) {
      String text = _tagController.text.trim();
      if (text.length > 0) {
//        List<String> temp = _exp.allMatches(text).map((f) => print(f.input)).toList();
        List<String> temp = text.split(" ").map((f) => f.trim()).toList()..retainWhere((f) => f.trim() != "");
        if (temp != null && temp.length > 5) {
          temp = temp.sublist(0,5);
        }
        setState(() {
          if (this.tags == null) {
            this.tags = List();
          } else {
            this.tags.clear();
          }
          this.tags.addAll(temp);
        });
      } else {
        setState(() {
          if (this.tags != null) {
            this.tags.clear();
          }
        });
      }
    }
  }

  void _hideKeyB() {
    setState(() {
      _focusNode.unfocus();
      if (_extraFocusNode != null) {
        _extraFocusNode.unfocus();
      }
      if (_tagFocusNode != null) {
        _tagFocusNode.unfocus();
      }
    });
  }

  Widget getImageSelWidget() {
    double width = (sw - 18 - spacing * 2) / 3;

    return GestureDetector(
        onTap: () {
          pickImage();
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
