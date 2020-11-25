import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/topic.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/component/bottom_sheet_choic_item.dart';
import 'package:iap_app/component/text_field.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account/simple_account.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/topic/add_topic_reply.dart';
import 'package:iap_app/model/topic/base_tr.dart';
import 'package:iap_app/model/tweet_reply.dart';
import 'package:iap_app/page/square/topic/topic_reply_card.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/toast_util.dart';

import 'common_util.dart';

class BottomSheetItem {
  final Icon icon;
  final String text;
  final callback;

  BottomSheetItem(this.icon, this.text, this.callback);
}

class BottomSheetUtil {
  static void showBottomChoice(BuildContext context, List<BSChoiceItem> items, final callback) {
    final picker = CupertinoPicker(
        backgroundColor: Color(0xffe5e6e7),
        useMagnifier: true,
        itemExtent: ScreenUtil().setHeight(50),
        onSelectedItemChanged: (position) {
          callback(position);
        },
        children: items);

    showCupertinoModalPopup(
        context: context,
        builder: (cxt) {
          return Container(
            height: 200,
            child: picker,
          );
        });
  }

  // static void showBottmSheetView(
  //     BuildContext context, List<BottomSheetItem> items) {
  //   showDialog(
  //       context: context,
  //       barrierDismissible: true,
  //       builder: (BuildContext context) {
  //         return Scaffold(
  //           //创建透明层

  //           backgroundColor: Colors.transparent, //透明类型
  //           body: AnimatedContainer(
  //               alignment: Alignment.center,
  //               height: MediaQuery.of(context).size.height -
  //                   MediaQuery.of(context).viewInsets.bottom,
  //               duration: const Duration(milliseconds: 120),
  //               curve: Curves.easeInCubic,
  //               child: Stack(
  //                 children: <Widget>[
  //                   Positioned(
  //                     bottom: 0,
  //                     left: 0,
  //                     child: Container(
  //                         decoration: BoxDecoration(
  //                           // color: ThemeUtils.getDialogBackgroundColor(context),
  //                           color: Colors.white,
  //                           borderRadius: BorderRadius.circular((8.0)),
  //                         ),
  //                         // width: 280.0,
  //                         height: 100.0,
  //                         child: Column(
  //                           children: <Widget>[Text('jdasjkdsa')],
  //                         )),
  //                   )
  //                 ],
  //               )),
  //         );
  //       });
  // }
  static void showBottomSheetView(BuildContext context, List<BottomSheetItem> items) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return StatefulBuilder(builder: (context1, state) {
            return Stack(
              children: <Widget>[
                Container(
                    // height: 350,
                    // constraints: BoxConstraints(maxHeight: 500),
                    decoration: BoxDecoration(
                        color: !ThemeUtils.isDark(context) ? Color(0xffEbEcEd) : Colours.dark_bottom_sheet,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Wrap(
                              alignment: WrapAlignment.start,
                              runAlignment: WrapAlignment.start,
                              runSpacing: 10.0,
                              children: _renderItems(context, items)),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                child: Container(
                                  margin: EdgeInsets.only(top: 15),
                                  width: ScreenUtil.screenWidth * 0.95 - 30,
                                  child: CupertinoButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: () => NavigatorUtils.goBack(context),
                                    child: Text('取消'),
                                  ),
                                ),
                              )
                            ],
                          ),
                          // Expanded(
                          //   child: Container(
                          //       child: Wrap(
                          //     spacing: 2,
                          //     alignment: WrapAlignment.start,
                          //     runAlignment: WrapAlignment.spaceEvenly,
                          //     runSpacing: 5,
                          //     children: <Widget>[],
                          //   )),
                          // )
                        ],
                      ),
                    )),
              ],
            );
          });
        });
  }

  static void showBottomSheet(BuildContext context, double heightFactor, Widget content,
      {bool topLine = true, Widget topWidget}) {
    bool isDark = ThemeUtils.isDark(context);
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return StatefulBuilder(builder: (context1, state) {
            return Stack(
              children: <Widget>[
                Container(
                    height: Application.screenHeight * heightFactor,
                    decoration: BoxDecoration(
                        color: !isDark ? Color(0xffEbEcEd) : Colours.dark_bg_color,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                    child: Stack(
                      children: <Widget>[
                        topLine
                            ? Positioned(
                                left: (Application.screenWidth - 50) / 2,
                                top: 10.0,
                                child: Container(
                                  child: Container(
                                      height: 5.0,
                                      width: 50.0,
                                      decoration: BoxDecoration(
                                          color: Color(0xffaeb4bd),
                                          borderRadius: BorderRadius.circular(73.0))),
                                ),
                              )
                            : (topWidget ?? Gaps.empty),
                        SafeArea(
                            top: false,
                            child: Container(
                              margin:
                                  EdgeInsets.only(top: topLine ? 20.0 : (topWidget == null ? 10.0 : 50.0)),
                              child: SingleChildScrollView(
                                child: content,
                              ),
                            ))
                      ],
                    ))
              ],
            );
          });
        });
  }

  static void showBottomSheetSingleReplyDetail(BuildContext context, BaseTopicReply reply, {Function onTap}) {
    bool isDark = ThemeUtils.isDark(context);
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return StatefulBuilder(builder: (context1, state) {
            return Stack(
              children: <Widget>[
                Container(
                    height: Application.screenHeight / 1.8,
//                     constraints: BoxConstraints(maxHeight: 500),
                    decoration: BoxDecoration(
                        color: !isDark ? Color(0xffEbEcEd) : Colours.dark_bg_color_darker,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 15, 15, 50),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Gaps.empty,
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: Container(
                                            alignment: Alignment.center,
                                            child: Text('详情', style: TextStyles.textBold14))),
                                    Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                            child: Icon(Icons.close, color: ThemeUtils.getIconColor(context)),
                                            onTap: onTap ?? () => {NavigatorUtils.goBack(context)},
                                          ),
                                        )),
                                  ],
                                ),
                                Gaps.vGap16,
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: <Widget>[
                                    AccountAvatar(
                                      avatarUrl: reply.author.avatarUrl,
                                      size: 30,
                                      onTap: () {
                                        NavigatorUtils.goAccountProfile(context, reply.author);
                                      },
                                    ),
                                    RichText(
                                      softWrap: true,
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text: "  ${reply.author.nick}",
                                            style: TextStyle(
                                                fontSize: Dimens.font_sp15, color: Colours.app_main)),
                                        TextSpan(
                                            text: " 回复于 ${TimeUtil.getShortTime(reply.sentTime)}",
                                            style: TextStyle(fontSize: Dimens.font_sp15, color: Colors.grey)),
                                      ]),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Text("${reply.body}",
                                      style: MyDefaultTextStyle.getMainTextBodyStyle(isDark,
                                              fontSize: Dimens.font_sp15)
                                          .copyWith(height: 1.8)),
                                )
                              ],
                            )),
                      ),
                    )),
              ],
            );
          });
        });
  }

  static void showBottomSheetSingleTweetReplyDetail(
      BuildContext context, TweetReply reply, bool dirAnon, bool isAuthorAndTweetAnon,
      {Function onTap}) {
    bool isDark = ThemeUtils.isDark(context);
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return StatefulBuilder(builder: (context1, state) {
            return Stack(
              children: <Widget>[
                Container(
                    height: Application.screenHeight * 0.5,
                    decoration: BoxDecoration(
                        color: !isDark ? Color(0xffEbEcEd) : Colours.dark_bg_color,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 15, 15, 50),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(flex: 1, child: Gaps.empty),
                                    Expanded(
                                        flex: 1,
                                        child: Container(
                                            alignment: Alignment.center,
                                            child: Text('详情', style: TextStyles.textSize18))),
                                    Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                            child: Icon(Icons.close, color: ThemeUtils.getIconColor(context)),
                                            onTap: onTap ?? () => {NavigatorUtils.goBack(context)},
                                          ),
                                        )),
                                  ],
                                ),
                                Gaps.vGap16,
                                Wrap(
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    AccountAvatar(
                                      whitePadding: true,
                                      avatarUrl: dirAnon || isAuthorAndTweetAnon
                                          ? PathConstant.ANONYMOUS_PROFILE
                                          : reply.account.avatarUrl,
                                      size: 35,
                                      onTap: dirAnon || isAuthorAndTweetAnon
                                          ? null
                                          : () => NavigatorUtils.goAccountProfile2(context, reply.account),
                                    ),
                                    Gaps.hGap10,
                                    RichText(
                                      softWrap: true,
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text: dirAnon
                                                ? TextConstant.TWEET_ANONYMOUS_REPLY_NICK
                                                : isAuthorAndTweetAnon
                                                    ? TextConstant.TWEET_AUTHOR_TEXT
                                                    : "${reply.account.nick}",
                                            style: TextStyle(
                                                fontSize: Dimens.font_sp16, color: Colours.app_main)),
                                        TextSpan(
                                            text: "回复于 ${TimeUtil.getShortTime(reply.sentTime)}",
                                            style: TextStyle(fontSize: Dimens.font_sp16, color: Colors.grey)),
                                      ]),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Text("${reply.body}",
                                      style: MyDefaultTextStyle.getMainTextBodyStyle(isDark,
                                              fontSize: Dimens.font_sp16)
                                          .copyWith(height: 2.0, letterSpacing: 1.2)),
                                )
                              ],
                            )),
                      ),
                    )),
              ],
            );
          });
        });
  }

  static void showBottomSheetSubTopicReplies(
      BuildContext context, MainTopicReply reply, bool closed, List<SubTopicReply> subReplies) {
    bool isDark = ThemeUtils.isDark(context);

    TextEditingController _controller = TextEditingController();
    FocusNode _focusNode = FocusNode();
    String _hintText = "回复 ${reply.author.nick}";
    List<SubTopicReply> storage = List.from(subReplies);
    int nextPage = 2;
    AddTopicReply myReply = AddTopicReply();
    myReply.refId = reply.id;
    myReply.topicId = reply.topicId;
    myReply.child = true;
    myReply.tarAccId = reply.author.id;
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return StatefulBuilder(builder: (context1, setBottomSheetState) {
            return Stack(
              children: <Widget>[
                Container(
                    height: Application.screenHeight / 1.3,
                    // constraints: BoxConstraints(maxHeight: 500),
                    decoration: BoxDecoration(
                        color: !isDark ? Color(0xffEbEcEd) : Colours.dark_bg_color,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                    child: Scrollbar(
                        child: Listener(
                      onPointerDown: (_) => _focusNode?.unfocus(),
                      child: SingleChildScrollView(
                        child: Container(
                            padding:
                                EdgeInsets.fromLTRB(10, !closed ? ScreenUtil().setHeight(125) : 10, 15, 50),
                            child: Column(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _buildTopicReplyColumn(context, isDark, closed, reply, storage,
                                      reply.replyCount > storage.length, () async {
                                    Utils.showDefaultLoadingWithBounds(context, text: "正在加载");
                                    List<SubTopicReply> temp = await TopicApi.queryTopicSubReplies(
                                        reply.topicId, reply.id, nextPage, 20);
                                    NavigatorUtils.goBack(context);
                                    if (temp == null || temp.length == 0) {
                                      ToastUtil.showToast(context, '没有更多回复');
                                      return;
                                    } else {
                                      setBottomSheetState(() {
                                        {
                                          storage.addAll(temp);
                                          nextPage++;
                                        }
                                      });
                                    }
                                  }, (SimpleAccount tarAccount, bool child) {
                                    if (myReply == null) {
                                      myReply = AddTopicReply();
                                    }
                                    setBottomSheetState(() {
                                      {
                                        _controller.clear();
                                        myReply.tarAccId = tarAccount.id;
                                        myReply.topicId = reply.topicId;
                                        myReply.child = child;
                                        myReply.refId = reply.id;
                                        _hintText = "回复 " + tarAccount.nick;
                                        print(
                                            "${myReply.topicId}--${myReply.tarAccId}--${myReply.child}--${myReply.refId}--");
                                        _focusNode.requestFocus();
                                      }
                                    });
                                  }),
                                )
                              ],
                            )),
                      ),
                    ))),
                closed
                    ? Gaps.empty
                    : Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
                          width: Application.screenWidth,
                          height: ScreenUtil().setHeight(105),
                          decoration: BoxDecoration(
//                              color: isDark ? Colours.dark_bg_color : Color(0xffe1e2e3),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: MyTextField(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(width: 0.0, style: BorderStyle.none),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  controller: _controller,
                                  hintText: _hintText,
                                  focusNode: _focusNode,
                                  maxLength: 256,
                                  bgColor: !isDark ? Colors.white : Color(0xff454545),
                                  onSub: (String val) async {
                                    if (val != null && val.trim().length > 0) {
                                      Utils.showDefaultLoadingWithBounds(context);
                                      Result r = await TopicApi.addReply(
                                          reply.topicId, myReply.refId, myReply.child, myReply.tarAccId, val);
                                      if (r == null) {
                                        NavigatorUtils.goBack(context);
                                        ToastUtil.showServiceExpToast(context);
                                        return;
                                      } else {
                                        print("${r.isSuccess} --- ${r.message}");
                                        if (r.isSuccess) {
                                          _controller?.clear();
                                          List<SubTopicReply> temp = await TopicApi.queryTopicSubReplies(
                                              reply.topicId, reply.id, 1, 20);
                                          NavigatorUtils.goBack(context);
                                          if (temp == null || temp.length == 0) {
                                            ToastUtil.showToast(context, '查询失败');
                                            return;
                                          } else {
                                            setBottomSheetState(() {
                                              {
                                                storage
                                                  ..clear()
                                                  ..addAll(temp);
                                                nextPage = 2;
                                                _hintText = "回复 ${reply.author.nick}";
                                                myReply.refId = reply.id;
                                                myReply.topicId = reply.topicId;
                                                myReply.child = true;
                                                myReply.tarAccId = reply.author.id;
                                              }
                                            });
                                          }
                                        } else {
                                          NavigatorUtils.goBack(context);
                                          ToastUtil.showToast(context, '回复失败');
                                        }
                                      }
                                    }
                                  },
                                ),
                                flex: 1,
                              )
                            ],
                          ),
                        ))
              ],
            );
          });
        });
  }

  static List<Widget> _buildTopicReplyColumn(BuildContext context, bool isDark, bool closed,
      MainTopicReply reply, List<SubTopicReply> subReplies, bool hasMore, onClickMore, onClickReply) {
    List<Widget> items = List();
    items.add(Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Gaps.empty,
        ),
        Expanded(
            flex: 4,
            child: Container(alignment: Alignment.center, child: Text('所有回复', style: TextStyles.textBold14))),
        Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                child: Icon(Icons.close, color: ThemeUtils.getIconColor(context)),
                onTap: () => NavigatorUtils.goBack(context),
              ),
            )),
      ],
    ));
    items.add(TopicReplyCardItem(
        reply, isDark, false, closed, (SimpleAccount account, bool child) => onClickReply(account, true),
        extra: false));

    if (subReplies != null && subReplies.length > 0) {
      items.add(const Divider(color: Color(0x649E9E9E)));
      items.add(Container(
        margin: const EdgeInsets.only(top: 10),
        child: Text('全部回复 ${reply.replyCount ?? ''}'),
      ));
      items.addAll(subReplies.map((str) => TopicReplyCardItem(
          null, isDark, true, closed, (SimpleAccount account, bool child) => onClickReply(account, true),
          extra: false, subTopicReply: str)));
    }
    items.add(Container(
      alignment: Alignment.center,
      child: FlatButton(
        child: Text(
          '加载更多',
          style: TextStyles.textClickable,
        ),
        onPressed: () => onClickMore(),
      ),
    ));

    items.add(Gaps.vGap30);

    return items;
  }

  static List<Widget> _renderItems(BuildContext context, List<BottomSheetItem> items) {
    return items.map((f) => _renderSingleItem(context, f)).toList();
  }

  static Widget _renderSingleItem(BuildContext context, BottomSheetItem item) {
    return InkWell(
        onTap: () => item.callback(),
        child: Container(
            margin: const EdgeInsets.only(right: 15),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    color: !ThemeUtils.isDark(context) ? Colors.white : Colours.dark_bg_color,
                    borderRadius: const BorderRadius.all(Radius.circular(15))),
                padding: const EdgeInsets.all(20),
                child: item.icon,
              ),
              Padding(padding: EdgeInsets.only(top: 10), child: Text(item.text))
            ])));
  }
}
