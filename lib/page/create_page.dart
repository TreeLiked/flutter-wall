import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/common-widget/asset_image.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/page/tweet_type_sel.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/string.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
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

  List<AssetPathEntity> paths = List();

  // 屏幕宽度
  double sw;
  // 去除边距剩余宽度
  double remain;

  double spacing = 2;

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
    Account account = new Account();
    account.id = "eec6a9c3f57045b7b2b9ed255cb4e273";
    print(account.toJson());
    _baseTweet.type = _typeName;
    _baseTweet.body = _controller.text;
    _baseTweet.account = account;
    _baseTweet.enableReply = _enbaleReply;
    _baseTweet.anonymous = _anonymous;
    _baseTweet.unId = 1;
    print(_baseTweet.toJson());
    TweetApi.pushTweet(_baseTweet).then((result) {
      print(result.toString());
    });
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

  void _selectTypeCallback(List<String> typeNames) {
    if (!CollectionUtil.isListEmpty(typeNames)) {
      this._typeName = typeNames[0];
      this._typeText = tweetTypeMap[typeNames[0]].zhTag;
    }
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
      maxSelected: 9,
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
      // List<String> r = [];
      // for (var e in imgList) {
      //   var file = await e.file;
      //   r.add(file.absolute.path);
      // }
      // currentSelected = r.join("\n\n");

      List<AssetEntity> preview = [];
      preview.addAll(imgList);

      setState(() {
        this.pics.clear();
        this.pics.addAll(imgList);
      });

      // Navigator.push(context,
      //     MaterialPageRoute(builder: (_) => PreviewPage(list: preview)));
    }
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

  Widget _singlePicItem() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    sw = MediaQuery.of(context).size.width;

    return new Scaffold(
        resizeToAvoidBottomPadding: true,
        appBar: new AppBar(
          title: Text(widget.title),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Text("取消"),
          ),
          elevation: 0,
          toolbarOpacity: 0.8,
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
        body: SingleChildScrollView(
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
                              this._isPushBtnEnabled = val.length > 0;
                              this._textCountText = val.length;
                            });
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
                            children: CollectionUtil.isListEmpty(pics)
                                ? <Widget>[getIamgeSelWidget()]
                                : getPicList(),
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
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
                                      " " + (_enbaleReply ? "允许评论 " : "禁止评论 "),
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
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
                                          color: !StringUtil.isEmpty(_typeName)
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

    pics
        .map((f) => AssetImageWidget(
              assetEntity: f,
              width: width,
              height: width,
              boxFit: BoxFit.cover,
            ))
        .forEach((imageWidget) => widgets.add(imageWidget));
    widgets.add(getIamgeSelWidget());
    return widgets;
  }
}
