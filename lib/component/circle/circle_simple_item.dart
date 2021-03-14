import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/common-widget/my_special_text_builder.dart';
import 'package:iap_app/component/satck_img_conatiner.dart';
import 'package:iap_app/component/simgple_tag.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/oss_canstant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/circle/circle.dart';
import 'package:iap_app/model/hot_tweet.dart';
import 'package:iap_app/model/media.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/page/circle/circle_home.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/widget_util.dart';

class CircleSimpleItem extends StatelessWidget {
  final Circle _circle;
  BuildContext context;
  final double bottomMargin;

  CircleSimpleItem(this._circle, {this.bottomMargin = 15.0});

  bool isDark;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    isDark = ThemeUtils.isDark(context);

    if (_circle == null) {
      return Gaps.empty;
    }

    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CircleHome(_circle)),
            ),
        child: Container(
            // height: double.negativeInfinity,
            margin: EdgeInsets.only(bottom: bottomMargin),
            padding: EdgeInsets.only(top: 0.0, right: 15.0, left: 15.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[_renderLeft(), Expanded(child: _renderRight())],
            )));
  }

  _renderRight() {
    return Container(
      height: 100,
      padding: const EdgeInsets.only(left: 10.0, top: 5.0, bottom: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: -1,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: <Widget>[
                      ExtendedText('${_circle.brief}',
                          maxLines: 1,
                          selectionEnabled: false,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: MyDefaultTextStyle.getTweetBodyStyle(context, fontSize: Dimens.font_sp16p5)
                              .copyWith(fontWeight: FontWeight.w500, letterSpacing: 1.1)),
                    ],
                  )),
              Gaps.vGap5,
              Expanded(
                  flex: -1,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: <Widget>[
                      ExtendedText('${_circle.desc}',
                          maxLines: 1,
                          selectionEnabled: false,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: pfStyle.copyWith(color: Colors.grey, fontSize: Dimens.font_sp14)),
                    ],
                  )),
            ],
          ),
          Text('70万浏览过，超过1K人加入', style: pfStyle.copyWith(fontSize: Dimens.font_sp13, color: Colors.grey))
        ],
      ),
    );
  }

  _renderLeft() {
    return StackImageContainer(
      _circle.cover,
      hasShadow: false,
      positionedWidgets: [
        Positioned(
            child: SimpleTag(
              "娱乐",
              round: true,
              radius: 2.0,
              bgColor: Colors.white70,
              textColor: Colors.black87,
            ),
            left: 5.0,
            top: 5.0)
      ],
      height: 100,
      width: 100,
    );
    return Container(
        width: 100,
        alignment: Alignment.center,
//                    padding: const EdgeInsets.only(right: 5.0),
        child: ClipRRect(
          clipBehavior: Clip.antiAlias,
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          child: AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: _circle.cover + OssConstant.THUMBNAIL_SUFFIX,
                placeholder: (context, url) => CupertinoActivityIndicator(),
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const LoadAssetImage(PathConstant.IMAGE_FAILED),
              )),
        ));
  }
}
