//import 'package:flutter/material.dart';
//import 'package:flutter_slidable/flutter_slidable.dart';
//import 'package:iap_app/common-widget/account_avatar.dart';
//import 'package:iap_app/global/size_constant.dart';
//import 'package:iap_app/part/notification/my_pm_card.dart';
//import 'package:iap_app/res/colors.dart';
//import 'package:iap_app/res/gaps.dart';
//import 'package:iap_app/res/resources.dart';
//import 'package:iap_app/res/styles.dart';
//import 'package:iap_app/style/text_style.dart';
//import 'package:iap_app/util/time_util.dart';
//
//// 用户私信tabView
//class PersonalMessagePage extends StatefulWidget {
//  PersonalMessagePage({Key key}) : super(key: key);
//
//  @override
//  createState() => _PersonalMessagePage();
//}
//
//class _PersonalMessagePage extends State<PersonalMessagePage>
//    with AutomaticKeepAliveClientMixin<PersonalMessagePage> {
//  @override
//  // TODO: implement wantKeepAlive
//  bool get wantKeepAlive => true;
//
//  @override
//  Widget build(BuildContext context) {
//    super.build(context);
//    return ListView.builder(
//        itemCount: 20,
//        physics: AlwaysScrollableScrollPhysics(),
////        padding: const EdgeInsets.symmetric(horizontal: 16.0),
//        itemBuilder: (_, index) {
//          return Slidable(
//            actionPane: SlidableDrawerActionPane(),
//            actionExtentRatio: 0.25,
//            child: Container(
//              child: Padding(
//                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
//                child: Row(
//                  mainAxisSize: MainAxisSize.max,
//                  children: <Widget>[
//                    AccountAvatar(
//                        avatarUrl: 'https://tva1.sinaimg.cn/large/006tNbRwgy1g9lw15sms6j30u011dgny.jpg',
//                        size: SizeConstant.TWEET_PROFILE_SIZE),
//                    Gaps.hGap8,
//                    Expanded(
//                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        children: <Widget>[
//                          Row(
//                            mainAxisSize: MainAxisSize.max,
//                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                            children: <Widget>[
//                              Text('长安归故里$index'),
////                                  Gaps.vGap4,
//                              Text(
//                                TimeUtil.getShortTime(new DateTime(2019, 12, 17, 19, index)),
//                                style: MyDefaultTextStyle.getTweetTimeStyle(context),
//                              )
//                            ],
//                          ),
//                          Text(
//                            '你在干嘛呢',
//                            style: TextStyles.textGray12,
//                          ),
//
////                        Gaps.line
//                        ],
//                      ),
//                    )
//                  ],
//                ),
//              ),
//            ),
//            actions: <Widget>[
//              IconSlideAction(
//                caption: 'Archive',
//                color: Colors.blue,
//                icon: Icons.archive,
//              ),
//              IconSlideAction(
//                caption: 'Share',
//                color: Colors.indigo,
//                icon: Icons.share,
//              ),
//            ],
//            secondaryActions: <Widget>[
//              IconSlideAction(
//                caption: '更多',
//                color: Colors.black45,
//                icon: Icons.more_horiz,
//              ),
//              IconSlideAction(
//                caption: '删除',
//                color: Colors.red,
//                icon: Icons.delete,
//              ),
//            ],
//          );
//        });
//  }
//}
