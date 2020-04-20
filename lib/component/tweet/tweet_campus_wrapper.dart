import 'package:flutter/material.dart';
import 'package:iap_app/component/simgple_tag.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/util/string.dart';

class TweetCampusWrapper extends StatelessWidget {
  final String institute;
  final String cla;

  TweetCampusWrapper(this.institute, this.cla);

  @override
  Widget build(BuildContext context) {
    bool insEmpty = StringUtil.isEmpty(institute);
    bool claEmpty = StringUtil.isEmpty(cla);

    if (insEmpty && claEmpty) {
      return Gaps.empty;
    }

    String t = insEmpty ? cla : (claEmpty ? institute : '$institute，$cla');

    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        "$t",
        style: TextStyle(fontSize: Dimens.font_sp13, letterSpacing: 0, color: Colors.grey),
      ),
    );
  }
}
