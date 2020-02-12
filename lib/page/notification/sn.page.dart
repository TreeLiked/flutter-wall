import 'package:flutter/material.dart';
import 'package:iap_app/part/notification/my_sn_card.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/resources.dart';
import 'package:iap_app/res/styles.dart';

// 系统通知tabView
class SystemNotificationPage extends StatefulWidget {
  SystemNotificationPage({Key key}) : super(key: key);

  @override
  createState() => _SystemNotificationPage();
}

class _SystemNotificationPage extends State<SystemNotificationPage>
    with AutomaticKeepAliveClientMixin<SystemNotificationPage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
          itemCount: 20,
//          physics: AlwaysScrollableScrollPhysics(),
//          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemBuilder: (_, index) {
            return Column(
              children: <Widget>[
                Gaps.vGap15,
//                Text("2019-5-31 17:19:36", style: Theme.of(context).textTheme.subtitle),
                Gaps.vGap8,
                MyShadowCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
//                            Expanded(child: Text("系统通知")),
                            Container(
                              margin: const EdgeInsets.only(right: 4.0),
                              height: 8.0,
                              width: 8.0,
                              decoration: BoxDecoration(
                                color: Colours.app_main,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
//                            Images.arrowRight
                          ],
                        ),
                        Gaps.vGap8,
                        Gaps.line,
                        Gaps.vGap8,
                        Text("您多次被用户举报，请及时缴纳罚金", style: TextStyles.textSize12),
                      ],
                    ),
                  ),
                )
              ],
            );
          });
//    ));
  }

  @override
  bool get wantKeepAlive => true;
}
