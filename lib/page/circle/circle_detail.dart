import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:iap_app/api/circle.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/my_flat_button.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/model/account/circle_account.dart';
import 'package:iap_app/model/circle/circle.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/routes/circle_router.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/widget_util.dart';

class CircleDetailPage extends StatefulWidget {
  final int _circleId;

  final Circle circle;

  CircleDetailPage(this._circleId, {this.circle});

  @override
  State<StatefulWidget> createState() {
    return _CircleDetailPageState();
  }
}

class _CircleDetailPageState extends State<CircleDetailPage> {
  bool _loading = false;
  double avatarSize = 70;
  Circle _circle;

  @override
  void initState() {
    super.initState();
    // queryDetail();
    setState(() {
      this._circle = widget.circle;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  queryDetail() {
    CircleApi.queryCircleDetail(widget._circleId).then((resCircle) {
      if (resCircle != null) {
        setState(() {
          this._loading = false;
          this._circle = resCircle;
        });
      } else {
        setState(() {
          this._loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
      child: this._loading
          ? Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CupertinoActivityIndicator(animating: true),
                  Text('加载中..', style: pfStyle.copyWith(color: Colors.grey)),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Gaps.vGap10,
                  _renderAvatarLine(),
                  Gaps.vGap30,
                  _renderTextLine('圈子简介', _circle.brief),
                  _renderTextLine('圈子介绍', _circle.desc),
                  _renderTextLine('加入方式', _getJoinTypeZhTag()),
                  _renderTextLine('加入/上限', '${_circle.participants} / ${_circle.limit}'),
                  _renderTextLine('内容可见', '${_circle.contentPrivate ? '圈内可见' : '公开'}'),
                  _renderTextLine('访问量', '${_circle.view}+'),
                  _renderCreatorLine(
                    '圈主',
                    _circle.creator.nick,
                  ),
                  // _renderTextLine('', '查看已加入用户', contentOnTap: () {}),
                  Gaps.vGap15,
                  _renderOptLine(),
                  Gaps.vGap10,
                ],
              ),
            ),
    );
  }

  _renderAvatarLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Colors.white),
            borderRadius: BorderRadius.circular(15),
          ),
          width: avatarSize,
          height: avatarSize,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                  imageUrl: _circle.cover,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => LoadAssetImage(
                        PathConstant.IMAGE_FAILED,
                        width: avatarSize,
                        height: avatarSize,
                        fit: BoxFit.cover,
                      ))),
        )
      ],
    );
  }

  _getJoinTypeZhTag() {
    String jt = _circle.joinType;
    if (StringUtil.isEmpty(jt)) {
      return '未知';
    }
    if (jt == Circle.JOIN_TYPE_DIRECT) {
      return '任何人可加入';
    } else if (jt == Circle.JOIN_TYPE_ADMIN_AGREE) {
      return '需要管理员通过';
    } else if (jt == Circle.JOIN_TYPE_REFUSE_ALL) {
      return '当前不允许加入';
    }
  }

  _renderTextLine(String title, String content, {Function contentOnTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: const EdgeInsets.only(right: 15.0),
              width: 100,
              alignment: Alignment.centerRight,
              child: Text('$title',
                  softWrap: true,
                  style: pfStyle.copyWith(fontSize: Dimens.font_sp14, color: ColorConstant.getCommonText()))),
          Expanded(
              child: GestureDetector(
                  onTap: contentOnTap == null ? null : contentOnTap(),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.end,
                    children: [
                      Text('$content',
                          textAlign: TextAlign.left,
                          softWrap: true,
                          style: pfStyle.copyWith(
                              fontSize: Dimens.font_sp15,
                              color: contentOnTap == null
                                  ? ColorConstant.getMainText()
                                  : ColorConstant.getTweetNickColor(context)))
                    ],
                  ))),
        ],
      ),
    );
  }

  _renderCreatorLine(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(right: 15.0),
            width: 100,
            alignment: Alignment.centerRight,
            child: Text('$title',
                softWrap: true,
                style: pfStyle.copyWith(fontSize: Dimens.font_sp14, color: ColorConstant.getCommonText())),
          ),
          Expanded(
            child: GestureDetector(
                onTap: () {
                  CircleAccount account = _circle.creator;
                  NavigatorUtils.push(
                      context,
                      Routes.accountProfile +
                          Utils.packConvertArgs(
                              {'nick': account.nick, 'accId': account.id, 'avatarUrl': account.avatarUrl}));
                },
                child: Wrap(
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.center,
                  children: [
                    Text('$content',
                        textAlign: TextAlign.left,
                        softWrap: true,
                        style: pfStyle.copyWith(
                            fontSize: Dimens.font_sp15, color: ColorConstant.getTweetNickColor(context))),
                  ],
                )),
          )
        ],
      ),
    );
  }

  _renderOptLine() {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            child : Text('查看已加入用户',style: pfStyle.copyWith(color: Colors.green)),
            onPressed: () {
              NavigatorUtils.push(context, CircleRouter.ACC_LIST + "?circleId=" + _circle.id.toString());
            },
          ),
          // MyFlatButton('关  闭', ColorConstant.getCommonText(), onTap: () => NavigatorUtils.goBack(context))
        ],
      ),
    );
  }
}
