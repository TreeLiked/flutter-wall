import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/topic.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/component/bottom_sheet_choic_item.dart';
import 'package:iap_app/component/text_field.dart';
import 'package:iap_app/model/account/simple_account.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/topic/add_topic_reply.dart';
import 'package:iap_app/model/topic/base_tr.dart';
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
                                  width: ScreenUtil.screenWidthDp * 0.95 - 30,
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
                                            child: Text('回复详情', style: TextStyles.textBold14))),
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
                                  crossAxisAlignment: WrapCrossAlignment.end,
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

  static void showBottomSheetSubTopicReplies(
      BuildContext context, MainTopicReply reply, List<SubTopicReply> subReplies) {
    bool isDark = ThemeUtils.isDark(context);
    TextEditingController _controller = TextEditingController();
    FocusNode _focusNode = FocusNode();
    String _hintText = "回复 ${reply.author.nick}";

    List<SubTopicReply> storage = List.from(subReplies);
    int nextPage = 2;
    AddTopicReply myReply = AddTopicReply();
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
                        color: !isDark ? Color(0xffEbEcEd) : Colours.dark_bg_color_darker,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 15, 15, 50),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildTopicReplyColumn(
                                  context, isDark, reply, storage, reply.replyCount > storage.length,
                                  () async {
                                Utils.showDefaultLoadingWithBounds(context, text: "正在加载");
                                List<SubTopicReply> temp =
                                    await TopicApi.queryTopicSubReplies(reply.topicId, reply.id, nextPage, 2);
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
                                setBottomSheetState(() {
                                  {
                                    _focusNode.requestFocus();

                                    myReply.tarAccId = tarAccount.id;
                                    myReply.topicId = reply.topicId;
                                    myReply.child = child;
                                    myReply.refId = reply.id;
                                    _hintText = "回复 " + tarAccount.nick;
                                  }
                                });
                              }),
                            )),
                      ),
                    )),
                Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                        padding: const EdgeInsets.only(left: 20, right: 10),
                        width: Application.screenWidth,
                        height: ScreenUtil().setHeight(100),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xff363636) : Color(0xffe1e2e3),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(7),
                            topRight: const Radius.circular(7),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            AccountAvatar(
                              cache: true,
                              avatarUrl: Application.getAccount.avatarUrl,
                              size: 30,
                            ),
                            Gaps.hGap15,
                            Expanded(
                              child: MyTextField(
                                controller: _controller,
                                hintText: _hintText,
                                focusNode: _focusNode,
                                maxLength: 256,
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
                                            reply.topicId, reply.id, 1, 2);
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
                                            }
                                          });
                                        }
                                      } else {
                                        NavigatorUtils.goBack(context);
                                        ToastUtil.showToast(context, '回复失败');
                                      }
                                    }
                                  } else {
                                    ToastUtil.showToast(context, '请输入内容');
                                  }
                                },
                              ),
                              flex: 1,
                            )
                          ],
                        )))
              ],
            );
          });
        });
  }

  static List<Widget> _buildTopicReplyColumn(BuildContext context, bool isDark, MainTopicReply reply,
      List<SubTopicReply> subReplies, bool hasMore, onClickMore, onClickReply) {
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
    items.add(TopicReplyCardItem(reply, isDark, false, (SimpleAccount account, bool child) => onClickReply(account, true),
        extra: false));

    if (subReplies != null && subReplies.length > 0) {
      items.add(const Divider(color: Color(0x649E9E9E)));
      items.add(Container(
        margin: const EdgeInsets.only(top: 10),
        child: Text('全部回复 ${subReplies.length}'),
      ));
      items.addAll(subReplies.map((str) => TopicReplyCardItem(
          null, isDark, true, (SimpleAccount account, bool child) => onClickReply(account, child),
          extra: false, subTopicReply: str)));
    }
    items.add(GestureDetector(
        child: Container(
            alignment: Alignment.center,
            child: Text(
              '加载更多',
              style: TextStyles.textClickable,
            )),
        onTap: () {
          onClickMore();
        }));

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
