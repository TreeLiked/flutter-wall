import 'dart:core';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/my_button.dart';
import 'package:iap_app/component/bottom_sheet_confirm.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/global/oss_canstant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/tweet_account.dart';
import 'package:iap_app/model/media.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/page/tweet_type_sel.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/PermissionUtil.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/image_utils.dart';
import 'package:iap_app/util/oss_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/umeng_util.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:nine_grid_view/nine_grid_view.dart';
import 'package:photo/photo.dart';

class CreatePage extends StatefulWidget {
  final String title = "发布内容";

  @override
  State<StatefulWidget> createState() {
    return _CreatePageState();
  }
}

class _CreatePageState extends State<CreatePage> {
  static const String _TAG = "_CreatePageState";
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

  double singleImageWidth;

  // 九宫格所有图片
  List<MyAssetDragBean> picDragBeans = List();

  // 移动事件类型
  int moveAction = MotionEvent.actionUp;

  // 是否当前拖拽的图片是否可以删除
  bool _canDelete = false;

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
    UMengUtil.userGoPage(UMengUtil.PAGE_TWEET_INDEX_CREATE);
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

    double totalSize = 0;
    if (CollectionUtil.isListNotEmpty(this.pics)) {
      Utils.showDefaultLoadingWithBounds(context);
      for (int i = 0; i < this.pics.length; i++) {
        ByteData bd = await this.pics[i].getByteData();
        if (bd != null) {
          int byte = bd.lengthInBytes;
          double mb = byte / 1024 / 1024;
          totalSize += mb;
        }
      }
      NavigatorUtils.goBack(context);
    }

    if (totalSize > OssConstant.TWEET_MAX_SIZE_ONCE) {
      ToastUtil.showToast(context, '图片过大');
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

    if (CollectionUtil.isListNotEmpty(this.picDragBeans)) {
      Utils.showDefaultLoadingWithBounds(context, text: '上传媒体');
      for (int i = 0; i < this.picDragBeans.length; i++) {
        ByteData bd = await this.picDragBeans[i].getByteData();
        if (bd == null) {
          NavigatorUtils.goBack(context);
          ToastUtil.showToast(context, '图片上传失败');
          return;
        }
        try {
          String result =
              await OssUtil.uploadImage(this.pics[i].name, bd.buffer.asUint8List(), OssUtil.DEST_TWEET);
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
          LogUtil.e("$exp", tag: _TAG);
        } finally {
          LogUtil.e("第$i张图片上传完成", tag: _TAG);
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
      LogUtil.e("Tweet to push: ${_baseTweet.toJson()}", tag: _TAG);

      TweetApi.pushTweet(_baseTweet).then((result) {
        Navigator.of(context).pop();
        Result r = Result.fromJson(result);
        LogUtil.e("Tweet push result: ${r.toJson()}", tag: _TAG);

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

  void _selectTypeCallback(String typeName) {
    if (!StringUtil.isEmpty(typeName)) {
      setState(() {
        this._typeName = typeName;
        this._typeText = tweetTypeMap[typeName].zhTag;
        _updatePushBtnState();
      });
    }
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
    BottomSheetUtil.showBottomSheet(context, 0.7, _buildTypeSelection(),
        topLine: false, topWidget: _buildTopWidget());
  }

  _buildTopWidget() {
    return Container(
      height: 50.0,
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      alignment: Alignment.center,
      child: Text("请选择内容标签", style: pfStyle.copyWith(fontSize: Dimens.font_sp15,color: Colors.grey)),
    );
  }

  _buildTypeSelection() {
    List<TweetTypeEntity> entities = TweetTypeUtil.getPushableTweetTypeMap().values.toList();
    return Container(
      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0, bottom: 20.0),
      // padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, //每行三列
              // childAspectRatio: 1.0, //显示区域宽高相等
              crossAxisSpacing: 15.0,
              mainAxisSpacing: 15.0),
          itemCount: entities.length,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            //如果显示到最后一个并且Icon总数小于200时继续获取数据
            return _buildSingleTypeItem(
                entities[index], !StringUtil.isEmpty(_typeName) && _typeName == entities[index].name);
          }),
    );
  }

  _buildSingleTypeItem(TweetTypeEntity entity, bool selected) {
    bool isDark = ThemeUtils.isDark(context);
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _selectTypeCallback(entity.name);
            NavigatorUtils.goBack(context);
          });
        },
        child: Container(
          margin: const EdgeInsets.all(1.5),
          padding: const EdgeInsets.only(top: 12.0, left: 8.0, right: 8.0),
          height: double.minPositive,
          alignment: Alignment.topLeft,
          decoration: selected
              ? BoxDecoration(
                  // color: ThemeUtils.isDark(context) ? Colors.black : Color(0xffdcdcdc),
                  color: isDark ? entity.color.withAlpha(30) : entity.color.withAlpha(79),
                  borderRadius: BorderRadius.circular(14.0),
                  border: new Border.all(color: isDark ? entity.color : Color(0xffdcdcdc), width: 0.5),
                )
              : BoxDecoration(
                  color: isDark ? Color(0xff303030) : Color(0xffEDEDED),
                  borderRadius: BorderRadius.circular(14.0),
                  boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.transparent : Color(0xffDCDCDC),
                        blurRadius: 3.0,
                      ),
                    ]
                  // border: new Border.all(
                  //     color: ThemeUtils.isDark(context) ? Color(0xff303030) : Color(0xffdcdcdc), width: 0.5),
                  ),
          child: Row(
            children: [
              Flexible(
                  flex: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${entity.zhTag}", style: pfStyle.copyWith(fontSize: Dimens.font_sp14)),
                      Gaps.vGap5,
                      Text("${entity.intro}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 5,
                          style: pfStyle.copyWith(fontSize: Dimens.font_sp12, color: Colors.grey)),
                    ],
                  )),
              Flexible(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Icon(
                          entity.iconData,
                          size: 30,
                          color: entity.iconColor,
                        ),
                      )
                    ],
                  )),
            ],
          ),
        ));
  }

  // _buildSingleTypeItem(TweetTypeEntity entity, bool selected) {
  //   return GestureDetector(
  //       behavior: HitTestBehavior.opaque,
  //       onTap: () {
  //         setState(() {
  //           _selectTypeCallback(entity.name);
  //           NavigatorUtils.goBack(context);
  //         });
  //       },
  //       child: Container(
  //         width: double.infinity,
  //         margin: const EdgeInsets.only(bottom: 5.0),
  //         padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 8.0),
  //         alignment: Alignment.centerLeft,
  //         decoration: selected
  //             ? BoxDecoration(
  //                 color: ThemeUtils.isDark(context) ? Colors.black : Color(0xffdcdcdc),
  //                 borderRadius: const BorderRadius.all(Radius.circular(7.9)),
  //                 border: new Border.all(
  //                     color: ThemeUtils.isDark(context) ? Colors.black : Color(0xffdcdcdc), width: 0.5),
  //               )
  //             : null,
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: <Widget>[
  //             Container(
  //               margin: const EdgeInsets.only(right: 5.0),
  //               child: Icon(
  //                 entity.iconData,
  //                 size: 40,
  //                 color: entity.iconColor,
  //               ),
  //             ),
  //             Expanded(
  //                 child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: [
  //                 Text(entity.zhTag,
  //                     style: pfStyle.copyWith(
  //                         fontSize: Dimens.font_sp15, color: selected ? entity.color : null)),
  //                 Text(entity.intro,
  //                     style: pfStyle.copyWith(
  //                         fontSize: Dimens.font_sp13p5, color: selected ? entity.color : Colors.grey)),
  //                 Gaps.vGap5,
  //               ],
  //             ))
  //           ],
  //         ),
  //       ));
  // }

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
      LogUtil.e("$e", tag: _TAG);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      pics = resultList;
      picDragBeans = getDragBeans();
    });
  }

  void pickImage(BuildContext context, PickType type) async {
    bool hasP = await PermissionUtil.checkAndRequestPhotos(context, needCamera: true);
    if (!hasP) {
      return;
    }

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
    LogUtil.e("create page build", tag: _TAG);

    sw = Application.screenWidth;

    singleImageWidth = (sw - 10 - spacing * 3) / 3;
    bool isDark = ThemeUtils.isDark(context);

    // 0.3 + 0.1 + 0.15
    // double limit = (Application.screenHeight * 0.3 - 10) / 3;
    // singleImageWidth = singleImageWidth > limit ? limit : singleImageWidth;

    return new Scaffold(
      backgroundColor: ColorConstant.MAIN_BG,
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
        title: Text(widget.title,
            style: TextStyle(fontSize: Dimens.font_sp16, fontWeight: FontWeight.w400, letterSpacing: 1.2)),
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
            height: 5.0,
            width: 69.0,
            margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: _isPushBtnEnabled && !_publishing ? Colors.amber : null,
            ),
            child: FlatButton(
              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
              onPressed: _isPushBtnEnabled && !_publishing
                  ? () {
                      this._assembleAndPushTweet();
                    }
                  : () {
                      if (StringUtil.isEmpty(_typeName)) {
                        ToastUtil.showToast(context, "请选择内容标签");
                        return;
                      }
                      if (StringUtil.isEmpty(_controller.text) && CollectionUtil.isListEmpty(pics)) {
                        ToastUtil.showToast(context, "请输入内容或至少选择一张图片");
                        return;
                      }
                      ToastUtil.showToast(context, "正在上传内容，请稍后");
                    },
              child: Text(
                '发表',
                style: TextStyle(
                  color: _isPushBtnEnabled ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              disabledTextColor: Colors.grey,
              textColor: Colors.blue,
            ),
          )
        ],
      ),
//      backgroundColor: Color(0xfff7f8f9),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
              bottom: true,
              child: SingleChildScrollView(
                child: GestureDetector(
                  onTap: () => _hideKeyB(),
                  onPanDown: (_) => _hideKeyB(),
                  child: new Container(
                    // color: ColorConstant.MAIN_BG,
                    margin: const EdgeInsets.only(bottom: 5.0),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(
                            right: 5.0,
                            top: 5.0,
                            left: 5.0,
                          ),
                          constraints: BoxConstraints(
                            maxHeight: Application.screenHeight * 0.3,
                          ),
                          child: TextField(
                            keyboardAppearance: Theme.of(context).brightness,
                            controller: _controller,
                            focusNode: _focusNode,
                            cursorColor: Colors.blue,
                            maxLengthEnforced: true,
                            maxLength: GlobalConfig.TWEET_MAX_LENGTH,
                            keyboardType: TextInputType.multiline,
                            autocorrect: false,
                            maxLines: 5,
                            style: pfStyle.copyWith(
                                height: 1.5,
                                fontSize: SizeConstant.TWEET_FONT_SIZE,
                                color: Colors.black,
                                letterSpacing: 1.1),
                            decoration: new InputDecoration(
                                hintText: '分享校园新鲜事',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(5),
                                counter: Text(
                                  _textCountText < GlobalConfig.TWEET_MAX_LENGTH
                                      ? ""
                                      : "最大长度 ${GlobalConfig.TWEET_MAX_LENGTH}",
                                  style: pfStyle.copyWith(color: Color(0xffb22222)),
                                )),
                            onChanged: (val) {
                              _updatePushBtnState();
                            },
                          ),
                        ),
                        // GridView.builder(
                        //   shrinkWrap: true,
                        //   itemCount: picWidgets.length,
                        //   physics: NeverScrollableScrollPhysics(),
                        //   padding: EdgeInsets.all(0),
                        //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        //     crossAxisCount: 3,
                        //     mainAxisSpacing: 3,
                        //     crossAxisSpacing: 3,
                        //     childAspectRatio: 1,
                        //   ),
                        //   itemBuilder: (context, index) {
                        //     return picWidgets[index];
                        //   },
                        // ),

                        Container(
                          // margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: DragSortView(
                            picDragBeans,
                            space: 5.0,
                            padding: const EdgeInsets.all(5.0),
                            itemBuilder: (BuildContext context, int index) {
                              return _renderSingleDragBean(picDragBeans[index], index);
                            },
                            initBuilder: (BuildContext context) {
                              return _getPhotoAddWidget();
                            },
                            onDragListener: (MotionEvent event, double itemWidth) {
                              switch (event.action) {
                                case MotionEvent.actionDown:
                                  moveAction = event.action;
                                  setState(() {});
                                  break;
                                case MotionEvent.actionMove:
                                  double x = event.globalX + itemWidth;
                                  double y = event.globalY + itemWidth;
                                  // double maxX = MediaQuery.of(context).size.width - 1 * 100;
                                  double maxX = 0;
                                  double maxY = MediaQuery.of(context).size.height - 1 * 100;
                                  if (_canDelete && (x < maxX || y < maxY)) {
                                    setState(() {
                                      _canDelete = false;
                                    });
                                  } else if (!_canDelete && x > maxX && y > maxY) {
                                    setState(() {
                                      _canDelete = true;
                                    });
                                  }
                                  break;
                                  break;
                                case MotionEvent.actionUp:
                                  moveAction = event.action;
                                  if (_canDelete) {
                                    setState(() {
                                      _canDelete = false;
                                      _deleteDraggedPic(picDragBeans[event.dragIndex].identifier);
                                    });
                                    return true;
                                  } else {
                                    setState(() {});
                                  }
                                  break;
                              }
                              return false;

                              /// Judge to drag to the specified position to delete
                              /// return true;
                              // if (event.globalY > 600) {
                              //   return true;
                              // }
                              // return false;
                            },
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.only(top: 20.0),
                          constraints: BoxConstraints(
                            maxHeight: Application.screenHeight * 0.1,
                          ),
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
                                      Text(" ${_enableReply ? '允许评论' : '禁止评论'}",
                                          style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                                        " ${_anonymous ? '匿名' : '公开'}",
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
                                        "# $_typeText",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                !StringUtil.isEmpty(_typeName) ? Colors.blue : Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ),
                        // Container(
                        //   margin: EdgeInsets.only(
                        //       top: picWidgets.length < 4
                        //           ? tipMargin
                        //           : picWidgets.length < 7
                        //               ? tipMargin - singleImageWidth
                        //               : tipMargin - singleImageWidth * 2),
                        //   width: sw,
                        //   alignment: Alignment.bottomCenter,
                        //   child: Text('请勿发布广告、色情、政治等标签无关或违法内容\n否则您的账号会被永久封禁',
                        //       textAlign: TextAlign.center, style: TextStyles.textGray12, softWrap: true),
                        // ),
                      ],
                    ),
                  ),
                ),

                //                 FloatingActionButton(
                //             onPressed: () {},
                //   backgroundColor: _canDelete ? Colors.red : Colors.white,
                //   child: Icon(_canDelete ? Icons.delete : Icons.delete_outline,
                //       color: _canDelete ? Colors.white : Colors.grey),
                // )
                // Positioned(
                //   bottom: 0,
                //   left: 0,
                //   child: Container(
                //     width: sw,
                //     alignment: Alignment.bottomCenter,
                //     child: Text('请勿发布广告、色情、政治等标签无关或违法内容\n否则您的账号会被永久封禁',
                //         textAlign: TextAlign.center, style: TextStyles.textGray12, softWrap: true),
                //   ),
                // )
              )),
          moveAction == MotionEvent.actionUp
              ? Gaps.empty
              : Positioned(
                  bottom: 20,
                  left: 0,
                  child: Container(
                    width: Application.screenWidth,
                    height: 100,
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: _canDelete? null: Border.all(color: Colors.black26),
                        color: _canDelete ? Colors.redAccent : Colors.transparent,
                      ),
                      child: Text("删 除",
                          style: pfStyle.copyWith(
                              color: _canDelete ? Colors.white : Colors.grey,
                              letterSpacing: 2,
                              fontSize: Dimens.font_sp15)),
                    ),
                  ))
        ],
      ),
    );
  }

  void _hideKeyB() {
    setState(() {
      _focusNode.unfocus();
    });
  }

  Widget getImageSelWidget() {
    return GestureDetector(
        onTap: () async {
          pickImage(Application.context, PickType.onlyImage);
        },
        child: Container(
          height: singleImageWidth,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3.0),
            child: Image.asset("assets/images/pic_select.png", width: singleImageWidth),
          ),
        ));
  }

  /// 初始化加载选择图片的那个图片
  List<MyAssetDragBean> getDragBeans() {
    List<MyAssetDragBean> temp = new List();
    if (CollectionUtil.isListNotEmpty(pics)) {
      pics.forEach((e) {
        MyAssetDragBean db = MyAssetDragBean(e.identifier, e.name, e.originalWidth, e.originalHeight);
        temp.add(db);
      });
    }
    return temp;
  }

  _deleteDraggedPic(delIdentifier) {
    this.pics.forEach((element) {
      print("${element.name}");
    });
    // print(index);
    // setState(() {
    this.pics.removeWhere((element) => element.identifier == delIdentifier);
    // });
  }

  Widget _getPhotoAddWidget() {
    return GestureDetector(
        onTap: () async {
          pickImage(Application.context, PickType.onlyImage);
        },
        child: Container(
          child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Image.asset(ImageUtils.getImgPath("pic_select"), width: singleImageWidth)),
        ));
  }

  /// 渲染单个可拖拽组件 last是否是最后一个，最后一个是加号
  Widget _renderSingleDragBean(MyAssetDragBean dragBean, index) {
    return GestureDetector(
        onTap: () async {
          ByteData bd = await dragBean.getByteData();
          showElasticDialog(
            context: context,
            barrierDismissible: true,
            builder: (ctx) => Stack(children: [
              Container(
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(50.0),
                  child: GestureDetector(
                      child: Image.memory(bd.buffer.asUint8List(), fit: BoxFit.fitWidth),
                      onTap: () => NavigatorUtils.goBack(ctx))),
            ]),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: AssetThumb(
            asset: dragBean,
            quality: 70,
            height: singleImageWidth.toInt(),
            width: singleImageWidth.toInt(),
            spinner: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: AssetThumb(
                asset: dragBean,
                quality: 10,
                height: singleImageWidth.toInt(),
                width: singleImageWidth.toInt(),
                spinner: const CupertinoActivityIndicator(),
              ),
            ),
          ),
        ));
  }
}

class MyAssetDragBean extends Asset implements DragBean {
  MyAssetDragBean(String identifier, String name, int originalWidth, int originalHeight)
      : super(identifier, name, originalWidth, originalHeight);

  @override
  int index;

  @override
  bool selected;
}
