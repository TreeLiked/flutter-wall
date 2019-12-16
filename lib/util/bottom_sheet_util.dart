import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/component/bottom_sheet_choic_item.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/theme_utils.dart';

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
                        color: !ThemeUtils.isDark(context) ? Color(0xffEbEcEd) : Colours.dark_bg_color_darker,
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
    // showModalBottomSheet(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return new Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: <Widget>[
    //           Container(
    //             decoration: BoxDecoration(
    //                 color: Color(0xfff4f5f7),
    //                 borderRadius: BorderRadius.all(Radius.circular(30))),
    //             padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
    //             child: Row(children: _renderItems(context, items)),
    //           )
    //         ],
    //       );
    //     });
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
