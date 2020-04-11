import 'package:flutter/material.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/size_constant.dart';

class TweetStatisticsWrapper extends StatelessWidget {
  final int viewCnt;
  final int praiseCnt;

  TweetStatisticsWrapper(this.viewCnt, this.praiseCnt);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 10),
      child: Text(
        "$viewCnt次浏览${praiseCnt == 0 ? '' : '，$praiseCnt人觉得很赞'}",
        softWrap: true,
        maxLines: 2,
        style: const TextStyle(
            fontSize: SizeConstant.TWEET_STATISTICS_SIZE, color: ColorConstant.TWEET_STATISTICS_COLOR),
      ),
    );
  }
}
