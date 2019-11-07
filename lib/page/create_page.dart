import 'dart:core';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/asset_image.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/page/tweet_type_sel.dart';
import 'package:iap_app/provider.dart/theme_provider.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/oss_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:photo/photo.dart';
import 'package:photo_manager/photo_manager.dart';

class CreatePage extends StatefulWidget {
  final String title = "发布内容";
  @override
  State<StatefulWidget> createState() {
    return _CreatePageState();
  }
}

class _CreatePageState extends State<CreatePage>
    with AutomaticKeepAliveClientMixin {
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();

  // 开启回复
  bool _enbaleReply = true;
  // 是否匿名
  bool _anonymous = false;

  String _typeText = "选择标签";
  String _typeName = "";

  int _textCountText = 0;

  // 是否禁用发布按钮
  bool _isPushBtnEnabled = false;

  // 选中的图片
  List<AssetEntity> pics = List();

  // 选中图片的路径
  List<File> picFiles = List();

  // 是否正在发布状态
  bool _publishing = false;

  // 屏幕宽度
  double sw;
  // 去除边距剩余宽度
  double remain;

  double spacing = 2;

  File file;

  void _updateTypeText(String text, String typeName) {
    setState(() {
      this._typeText = text;
      this._typeName = typeName;
    });
  }

  void _updatePushBtnState() {
    setState(() {
      this._textCountText = 10;
      this._isPushBtnEnabled = !StringUtil.isEmpty(this._typeName) &&
          (_controller.text.length > 0 ||
              !CollectionUtil.isListEmpty(this.pics));
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void _assembleAndPushTweet() async {
    _focusNode.unfocus();
    setState(() {
      this._isPushBtnEnabled = false;
      this._publishing = true;
    });
    BaseTweet _baseTweet = BaseTweet();
    bool hasError = false;
    if (!CollectionUtil.isListEmpty(this.pics)) {
      for (int i = 0; i < this.pics.length; i++) {
        File f = await this.pics[i].file;
        String name = f.path.substring(f.path.lastIndexOf("/") + 1);
        try {
          String result = await OssUtil.uploadImage(name, f);
          print(result);
          if (result != "-1") {
            if (_baseTweet.picUrls == null) {
              _baseTweet.picUrls = List();
            }
            _baseTweet.picUrls.add(result);
          } else {
            hasError = true;
            break;
          }
        } catch (exp) {
          hasError = true;
          print(exp);
        } finally {
          // print('第$i张图片上传完成');
        }
      }
    }
    if (!hasError) {
      print('开始pus=============================');
      _baseTweet.type = _typeName;
      _baseTweet.body = _controller.text;
      _baseTweet.account = Application.getAccount;
      _baseTweet.enableReply = _enbaleReply;
      _baseTweet.anonymous = _anonymous;
      _baseTweet.orgId = Application.getOrgId;
      print(_baseTweet.toJson());
      TweetApi.pushTweet(_baseTweet).then((result) {
        print(result.toString());
        Navigator.pop(context);
      });
    } else {
      ToastUtil.showToast('发布出错，请稍后重试');
    }
    _updatePushBtnState();
    setState(() {
      this._publishing = false;
    });
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

  void _forwardSelPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TweetTypeSelect(
                  title: "选择内容类型",
                  multi: false,
                  finishText: "完成",
                  needVisible: false,
                  initNames:
                      !StringUtil.isEmpty(_typeName) ? [_typeName] : null,
                  callback: (typeNames) => _selectTypeCallback(typeNames),
                )));
    // showModalBottomSheet(
    //     isScrollControlled: true,
    //     context: context,
    //     builder: (builder) {
    //       return StatefulBuilder(builder: (context1, state) {
    //         return Stack(
    //           children: <Widget>[
    //             Container(
    //               height: 30.0,
    //               width: double.infinity,
    //               color: Colors.black54,
    //             ),
    //             Container(
    //                 // height: 350,
    //                 // constraints: BoxConstraints(maxHeight: 500),
    //                 decoration: BoxDecoration(
    //                     color: Colors.white,
    //                     borderRadius:
    //                         BorderRadius.vertical(top: Radius.circular(16))),
    //                 child: FractionallySizedBox(
    //                     heightFactor: 0.46,
    //                     child: Container(
    //                       padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
    //                       child: Column(
    //                         children: <Widget>[
    //                           Row(
    //                             mainAxisAlignment: MainAxisAlignment.center,
    //                             children: <Widget>[
    //                               Text(
    //                                 '- 请选择内容类型 -',
    //                                 style: TextStyle(
    //                                     color: Colors.black, fontSize: 18),
    //                               ),
    //                             ],
    //                           ),
    //                           Expanded(
    //                             child: Container(
    //                                 child: Wrap(
    //                               spacing: 2,
    //                               alignment: WrapAlignment.start,
    //                               runAlignment: WrapAlignment.spaceEvenly,
    //                               runSpacing: 5,
    //                               children: <Widget>[
    //                               ],
    //                             )),
    //                           )
    //                         ],
    //                       ),
    //                     ))),
    //           ],
    //         );
    //       });
    //     });
  }

  void pickImage(PickType type) async {
    // File image =
    //     await ImagePicker.pickImage(source: prefix0.ImageSource.gallery);
    // setState(() {
    //   this.file = image;
    // });
    var assetPathList = await PhotoManager.getImageAsset();

    List<AssetEntity> imgList = await PhotoPicker.pickAsset(
      // BuildContext required
      context: context,

      /// The following are optional parameters.
      themeColor: Color(0xffF0F8FF),
      // the title color and bottom color

      textColor: Color(0xff696969),

      // text color
      padding: 1.0,
      // item padding
      dividerColor: Colors.grey,
      // divider color
      disableColor: Colors.grey.shade300,
      // the check box disable color
      itemRadio: 0.88,
      // the content item radio
      maxSelected: pics == null ? 9 : 9 - pics.length,
      // max picker image count
      // provider: I18nProvider.english,
      provider: I18nProvider.chinese,
      // i18n provider ,default is chinese. , you can custom I18nProvider or use ENProvider()
      rowCount: 4,
      // item row count

      thumbSize: 150,
      // preview thumb size , default is 64
      sortDelegate: SortDelegate.common,
      // default is common ,or you make custom delegate to sort your gallery
      checkBoxBuilderDelegate: DefaultCheckBoxBuilderDelegate(
        activeColor: Colors.white,
        unselectedColor: Colors.white,
        checkColor: Colors.green,
      ),
      // default is DefaultCheckBoxBuilderDelegate ,or you make custom delegate to create checkbox

      // loadingDelegate: this,
      // if you want to build custom loading widget,extends LoadingDelegate, [see example/lib/main.dart]

      badgeDelegate: const DurationBadgeDelegate(),
      // badgeDelegate to show badge widget

      pickType: type,
      // photoPathList: assetPathList
    );

    if (!CollectionUtil.isListEmpty(imgList)) {
      // imgList.forEach((f) async => this.picFiles.add(await f.file));
      setState(() {
        this.pics.addAll(imgList);
      });

      // Navigator.push(context,
      //     MaterialPageRoute(builder: (_) => PreviewPage(list: preview)));
    }
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
    super.build(context);

    print("create page build");
    sw = ScreenUtil.screenWidthDp;

    return new Scaffold(
        resizeToAvoidBottomPadding: true,
        appBar: new AppBar(
          title: Text(widget.title),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Text("取消",
                style: TextStyle(
                  color: Theme.of(context).textTheme.title.color,
                )),
          ),
          elevation: 0,
          toolbarOpacity: 0.8,
          actions: <Widget>[
            Container(
              height: 10,
              child: FlatButton(
                onPressed: _isPushBtnEnabled
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
        backgroundColor: ColorConstant.DEFAULT_BAR_BACK_COLOR,
        body: ModalProgressHUD(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () => _hideKeyB(),
                  onPanDown: (_) => _hideKeyB(),
                  child: new Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Container(
                        //   height: 10,
                        //   color: Colors.grey,
                        // ),
                        Container(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            cursorColor: Colors.blue,
                            maxLengthEnforced: true,
                            maxLength: GlobalConfig.TWEET_MAX_LENGTH,
                            keyboardType: TextInputType.multiline,
                            autocorrect: false,
                            maxLines: 8,
                            style: TextStyle(
                                fontSize: SizeConstant.TWEET_FONT_SIZE,
                                color: Colors.black),
                            decoration: new InputDecoration(
                                hintText: '分享新鲜事',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(5),
                                counter: Text(
                                  _textCountText < GlobalConfig.TWEET_MAX_LENGTH
                                      ? ""
                                      : "最大长度 ${GlobalConfig.TWEET_MAX_LENGTH}",
                                  style: TextStyle(color: Color(0xffb22222)),
                                )),
                            onChanged: (val) {
                              setState(() {
                                this._textCountText = val.length;
                              });
                              // _updatePushBtnState();
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
                          margin: EdgeInsets.only(top: 20),
                          child: Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () => _reverseEnableReply(),
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                      color: Color(0xffF5F5F5),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        _enbaleReply
                                            ? Icons.lock_open
                                            : Icons.lock,
                                        color: _enbaleReply
                                            ? Color(0xff87CEEB)
                                            : Colors.grey,
                                        size: 16,
                                      ),
                                      Text(
                                        " " +
                                            (_enbaleReply ? "允许评论 " : "禁止评论 "),
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _reverseAnonymous(),
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                      color: Color(0xffF5F5F5),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        _anonymous
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: _anonymous
                                            ? Color(0xff87CEEB)
                                            : Colors.grey,
                                        size: 16,
                                      ),
                                      Text(
                                        " " + (_anonymous ? "开启匿名" : "公开"),
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
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
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                          color: Color(0xffF5F5F5),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      child: Text(
                                        "# " + _typeText,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                !StringUtil.isEmpty(_typeName)
                                                    ? Colors.blue
                                                    : Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                              Divider(
                                height: 1.0,
                                indent: 0.0,
                                color: Color(0xffF5F5F5),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          inAsyncCall: _publishing,
          opacity: 0.15,
        ));
  }

  void _hideKeyB() {
    setState(() {
      _focusNode.unfocus();
    });
  }

  Widget getIamgeSelWidget() {
    double width = (sw - 25 - spacing * 2) / 3;

    return GestureDetector(
        onTap: () {
          pickImage(PickType.onlyImage);
        },
        child: Container(
          height: width,
          child: Image.asset("assets/images/pic_select.png", width: width),
        ));
  }

  @override
  bool get wantKeepAlive => true;

  List<Widget> getPicList() {
    double width = (sw - 25 - spacing * 3) / 3;
    List<Widget> widgets = List();

    if (!CollectionUtil.isListEmpty(pics)) {
      for (int j = 0; j < pics.length; j++) {
        widgets.add(GestureDetector(
          onLongPress: () {
            setState(() {
              BottomSheetUtil.showBottmSheetView(context, [
                BottomSheetItem(Icon(Icons.delete, color: Colors.red), '删除这张图片',
                    () {
                  setState(() {
                    this.pics.removeAt(j);
                    Navigator.pop(context);
                  });
                })
              ]);
            });
          },
          child: AssetImageWidget(
            assetEntity: pics[j],
            width: width,
            height: width,
            boxFit: BoxFit.cover,
          ),
          // child: Container(
          //   width: width,
          //   height: width,
          //   child: Image.file(picFiles[j]),
          // ),
        ));
      }
    }

    widgets.add(getIamgeSelWidget());
    // pics
    //     .map((f) => GestureDetector(
    //           onTap: () async {
    //             List<File> files = new List();
    //             for(int i = 0 ; i < files.length; i++) {
    //               files.add(await pics[i].file);
    //             }
    //             Utils.openPhotoView(context, , initialIndex),
    //           },
    //           child: AssetImageWidget(
    //             assetEntity: f,
    //             width: width,
    //             height: width,
    //             boxFit: BoxFit.cover,
    //           ),
    //         ))
    //     .forEach((imageWidget) => widgets.add(imageWidget));
    return widgets;
  }
}
