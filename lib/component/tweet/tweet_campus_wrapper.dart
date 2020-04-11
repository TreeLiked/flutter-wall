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
    if (StringUtil.isEmpty(institute) && StringUtil.isEmpty(cla)) {
      return Gaps.empty;
    }
    String claT = StringUtil.isEmpty(cla) ? '' : ' , $cla';
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 10.0),
      child: SimpleTag(
        "${institute.trim()}$claT",
        round: false,
//        style: TextStyle(fontSize: Dimens.font_sp13,letterSpacing: 1.0),
      ),
    );
  }
}
