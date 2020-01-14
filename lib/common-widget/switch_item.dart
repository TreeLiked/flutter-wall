import 'package:flutter/material.dart';
import 'package:iap_app/res/resources.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/style/text_style.dart';

// class SwitchItem extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//     return SwitchItemState;
//   }

// }
class SwitchItem extends StatelessWidget {
  const SwitchItem({Key key, this.onTap, @required this.title, this.initBool = false}) : super(key: key);

  final onTap;
  final String title;
  final initBool;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15.0),
      padding: const EdgeInsets.fromLTRB(0, 10.0, 15.0, 10.0),
      constraints: BoxConstraints(maxHeight: double.infinity, minHeight: 50.0),
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border(
        bottom: Divider.createBorderSide(context, width: 0.6),
      )),
      child: Row(
        //为了数字类文字居中
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(child: Text(title, style: TextStyles.textSize14)),
          // const Spacer(),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Switch.adaptive(
                value: this.initBool,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (bool val) {
                  onTap(val);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
