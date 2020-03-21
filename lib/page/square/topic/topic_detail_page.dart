import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/bezier_bounce_footer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/topic.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/imgae_container.dart';
import 'package:iap_app/common-widget/popup_window.dart';
import 'package:iap_app/component/text_field.dart';
import 'package:iap_app/component/tweet_delete_bottom_sheet.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account/simple_account.dart';
import 'package:iap_app/model/media.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/topic/add_topic.dart';
import 'package:iap_app/model/topic/add_topic_reply.dart';
import 'package:iap_app/model/topic/base_tr.dart';
import 'package:iap_app/model/topic/topic.dart';
import 'package:iap_app/page/common/report_page.dart';
import 'package:iap_app/page/home/home_comment_wrapper.dart';
import 'package:iap_app/page/square/topic/topic_reply_card.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart';

class TopicDetailPage extends StatefulWidget {
  final int topicId;
  Topic topic;

  TopicDetailPage(this.topicId, {this.topic});

  @override
  State<StatefulWidget> createState() {
    return _TopicDetailPageState(topic);
  }
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  Topic topic;

  _TopicDetailPageState(this.topic);

  bool isDark = false;
  GlobalKey _sortButtonKey = GlobalKey();

  List _sortTypeList = ["热门排序", "时间排序"];
  int _sortTypeIndex = 0;

  Future _getReplyTask;
  int _currentPage = 1;
  int _fetchSize = 30;
  List<MainTopicReply> mainTopicReplies;

  TextEditingController _editController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  String _defaultHintText = "评论";
  String _hintText = "评论";

  AddTopicReply myReply = AddTopicReply();

  @override
  void initState() {
    super.initState();
    _fetchTopicIfNullAndExtra();
    _fetchMainReplies(1);
  }

  void _fetchTopicIfNullAndExtra() async {
    if (topic == null) {
      Topic topic = await TopicApi.queryTopicById(widget.topicId);
      setState(() {
        this.topic = topic;
        _getReplyTask = _fetchMainReplies(1);
        myReply.topicId = topic.id;
        myReply.refId = topic.id;
        myReply.child = false;
        myReply.tarAccId = topic.author.id;
      });
    } else {
      setState(() {
        _getReplyTask = _fetchMainReplies(1);
        myReply.topicId = topic.id;
        myReply.refId = topic.id;
        myReply.child = false;
        myReply.tarAccId = topic.author.id;
      });
    }
  }

  Future<List<MainTopicReply>> _fetchMainReplies(int currentPage) async {
    List<MainTopicReply> temp = await TopicApi.queryTopicMainReplies(topic.id, currentPage, _fetchSize,
        order: _sortTypeIndex == 0 ? BaseTopicReply.QUERY_ORDER_HOT : BaseTopicReply.QUERY_ORDER_TIME);
    if (temp == null) {
      return [];
    }
    return temp;
  }

  @override
  void dispose() {
    _editController?.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isDark = ThemeUtils.isDark(context);
    return Scaffold(
        appBar: AppBar(
          title: Flex(direction: Axis.horizontal, mainAxisSize: MainAxisSize.max, children: <Widget>[
            Expanded(
                flex: 1,
                child: topic == null
                    ? Gaps.empty
                    : Container(
                        alignment: Alignment.bottomLeft,
                        child: AccountAvatar(
                            avatarUrl: topic.author.avatarUrl,
                            size: 34,
                            onTap: () => NavigatorUtils.goAccountProfile(context, topic.author)))),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: const Text('详情'),
              ),
            ),
            const Spacer(
              flex: 1,
            ),
          ]),
          centerTitle: true,
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => NavigatorUtils.goBack(context)),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.more_horiz),
              onPressed: () {
                _showMoreMenus(context);
              },
            )
          ],
          elevation: 0.2,
        ),
        body: topic == null
            ? Container(alignment: Alignment.topCenter, child: WidgetUtil.getLoadingAnimation())
            : Listener(
                onPointerDown: (_) {
                  if (topic != null) {
                    _focusNode.unfocus();
                  }
                },
                child: Stack(
                  children: <Widget>[
                    CustomScrollView(slivers: <Widget>[
                      SliverToBoxAdapter(
                          child: Container(
                        margin: EdgeInsets.only(
                          left: 15,
                          right: 15,
                          top: 10,
                          bottom: ScreenUtil().setHeight(110),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _buildBody(),
                            Gaps.vGap12,
                            Gaps.line,
                            _buildCommentRow(),
                            _buildCommentWrap(),
//                      _buildCommentHeader(),
                          ],
                        ),
                      )),
                    ]),
                    topic.status != Topic.STATUS_OPEN
                        ? Gaps.empty
                        : Positioned(
                            left: 0,
                            bottom: 0,
                            child: Container(
                                padding: const EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
                                width: Application.screenWidth,
                                alignment: Alignment.topCenter,
                                height: ScreenUtil().setHeight(120),
                                decoration: BoxDecoration(
                                  color: isDark ? Color(0xff363636) : Color(0xfff2f3f4),
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: MyTextField(
                                        controller: _editController,
                                        hintText: _hintText,
                                        focusNode: _focusNode,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(width: 0.0, style: BorderStyle.none),
                                          borderRadius: BorderRadius.circular(11.5),
                                        ),
                                        bgColor: !isDark ? Colors.white : Color(0xff454545),
                                        maxLength: 256,
                                        onSub: (String val) async {
                                          if (val != null && val.trim().length > 0) {
                                            Utils.showDefaultLoadingWithBounds(context);
                                            Result r = await TopicApi.addReply(topic.id, myReply.refId,
                                                myReply.child, myReply.tarAccId, val);
                                            NavigatorUtils.goBack(context);
                                            if (r == null) {
                                              ToastUtil.showServiceExpToast(context);
                                              return;
                                            } else {
                                              print("${r.isSuccess} --- ${r.message}");
                                              if (r.isSuccess) {
                                                _editController?.clear();
                                                setState(() {
                                                  _hintText = _defaultHintText;
                                                  _getReplyTask = _fetchMainReplies(1);
                                                });
                                              } else {
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
                )));
  }

  void _hitReply(SimpleAccount targetAccount, bool child, int parentId) {
    if (myReply == null) {
      myReply = AddTopicReply();
    }
    setState(() {
      _hintText = "回复 ${targetAccount.nick}";
      myReply.topicId = topic.id;
      myReply.tarAccId = targetAccount.id;
      myReply.child = child;
      myReply.refId = parentId;
      print("${myReply.topicId}--${myReply.tarAccId}--${myReply.child}--${myReply.refId}--");
      _focusNode.requestFocus();
    });
  }

  Widget _buildBody() {
    bool hasExtra = topic.body != null && topic.body.trim().length != 0;
    return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        constraints: const BoxConstraints(minHeight: 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: topic.title ?? TextConstant.TEXT_UN_CATCH_ERROR,
                      style: MyDefaultTextStyle.getMainTextBodyStyle(isDark))
                ]),
              ),
            ),
            hasExtra
                ? Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: topic.body.trim(), style: MyDefaultTextStyle.getSubTextBodyStyle(isDark))
                      ]),
                    ),
                  )
                : Gaps.empty,
            _buildImages(),
            _buildAuthInfo(),
            _buildUniRow(),
            _buildTagsRow(topic.tags),
          ],
        ));
  }

  Widget _buildImages() {
    List<Media> medias = topic.medias;
    if (medias == null || medias.length == 0) {
      return Gaps.empty;
    }
    // TODO 暂不展示图片以外的媒体类型
    medias.removeWhere((media) => media.mediaType != "IMAGE");
    double singleImageWidth = (Application.screenWidth - 40 - 10 - 15) / medias.length;

    List<Widget> items = List();
    for (int i = 0; i < medias.length; i++) {
      items.add(Container(
        margin: const EdgeInsets.only(right: 5),
        child: ImageContainer(
          url: medias[i].url,
          maxWidth: singleImageWidth,
          maxHeight: Application.screenHeight * 0.25,
          height: singleImageWidth,
          callback: () => open(context, i),
        ),
      ));
    }
    return Container(margin: const EdgeInsets.only(bottom: 5.0), child: Wrap(children: items));
  }

  void open(BuildContext context, final int index) {
    Utils.openPhotoView(context, topic.medias.map((m) => m.url).toList(), index, topic.id);
  }

  Widget _buildAuthInfo() {
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.only(bottom: 5),
      child: RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(children: [
          TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () => NavigatorUtils.goAccountProfile(context, topic.author),
              text: topic.author.nick,
              style: MyDefaultTextStyle.getTweetNickStyle(context, SizeConstant.TWEET_TIME_SIZE)),
          TextSpan(
              text: ' 发布于 ${TimeUtil.getShortTime(topic.sentTime)}',
              style: MyDefaultTextStyle.getTweetTimeStyle(context))
        ]),
      ),
    );
  }

  Widget _buildUniRow() {
    return Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.5),
          decoration:
              BoxDecoration(color: Colours.app_main.withAlpha(45), borderRadius: BorderRadius.circular(5)),
          child: Text(
            " F " + topic.university.name ?? TextConstant.TEXT_UN_CATCH_ERROR,
            style: MyDefaultTextStyle.getTweetSigStyle(context, fontSize: Dimens.font_sp13),
          ),
        ));
  }

  Widget _buildTagsRow(List<String> tags) {
    if (tags == null || tags.length == 0) {
      return Gaps.empty;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Wrap(alignment: WrapAlignment.start, children: tags.map((t) => _buildSingleTag(t)).toList()),
    );
  }

  Widget _buildSingleTag(String tag) {
    if (tag == null || tag.trim().length == 0) {
      return Gaps.empty;
    }
    return Container(
        decoration: BoxDecoration(
            color: topicTagColors[Random().nextInt(topicTagColors.length - 1)].withAlpha(isDark ? 50 : 150),
            borderRadius: BorderRadius.circular(5.0)),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
        child: Text("# $tag", style: TextStyles.textWhite14));
  }

  Widget _buildCommentWrap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildCommentHeader(),
        _buildConcreteComment(),
      ],
    );
  }

  Widget _buildConcreteComment() {
    return Container(
      child: FutureBuilder<List<MainTopicReply>>(
          builder: (context, AsyncSnapshot<List<MainTopicReply>> async) {
            if (async.connectionState == ConnectionState.active ||
                async.connectionState == ConnectionState.waiting) {
              return new Center(
                child: new SpinKitThreeBounce(
                  color: Colors.deepPurple,
                  size: 18,
                ),
              );
            }
            if (async.connectionState == ConnectionState.done) {
              if (async.hasError) {
                return _centerText('拉取评论失败');
              } else if (async.hasData) {
                List<MainTopicReply> list = async.data;
                if (list == null || list.length == 0) {
                  return _centerText('暂无评论');
                }
                this.mainTopicReplies = list;
                return Column(
                  children: _buildReplyList(list.length == _fetchSize),
                );
              }
            }
            return Gaps.empty;
          },
          future: _getReplyTask),
    );
  }

  List<Widget> _buildReplyList(bool hasMore) {
    List<Widget> widgets = List();
    widgets.addAll(mainTopicReplies
        .map((tr) => Column(
              children: <Widget>[
                // 无论是回复直接回复还是子回复，参照id都是直接回复的id
                TopicReplyCardItem(tr, isDark, false, topic.status != Topic.STATUS_OPEN,
                    (SimpleAccount acc, bool child) => _hitReply(acc, true, tr.id),
                    extra: true),
                Gaps.line
              ],
            ))
        .toList());
    print(topic.toJson());
//    if (mainTopicReplies!= null && topic!= null && mainTopicReplies.length < topic.replyCount) {
    if (hasMore) {
      widgets.add(Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 20),
          child: FlatButton(
            child: Text('加载更多', style: TextStyles.textClickable),
            onPressed: () async {
              Utils.showDefaultLoadingWithBounds(context, text: '正在加载更多');
              List<MainTopicReply> replies = await _fetchMainReplies(++_currentPage);
              NavigatorUtils.goBack(context);
              if (replies != null && replies.length > 0) {
                setState(() {
                  this.mainTopicReplies.addAll(replies);
                });
              } else {
                ToastUtil.showToast(context, '没有更多回复了');
              }
            },
          )));
    }
    return widgets;
  }

  Widget _buildCommentHeader() {
    return GestureDetector(
        key: _sortButtonKey,
        onTap: () => _showSortTypeSel(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              child: Text('${_sortTypeList[_sortTypeIndex]}', style: TextStyles.textGray14),
            ),
            Icon(Icons.keyboard_arrow_down, color: ThemeUtils.getIconColor(context))
          ],
        ));
  }

  Widget _buildCommentRow() {
    bool closed = topic.status != Topic.STATUS_OPEN;
    return Container(
        alignment: Alignment.centerRight,
        child: FlatButton(
            color: ThemeUtils.getBackColor(context),
            child: Text(closed ? '话题已关闭' : '评论',
                style: TextStyle(
                    color: closed ? Colors.amber : Colors.blueAccent,
                    fontSize: SizeConstant.TWEET_TIME_SIZE + 1)),
            onPressed: !closed ? () => _hitReply(topic.author, false, topic.id) : null));
  }

  void _showSortTypeSel() {
    // 获取点击控件的坐标
    final RenderBox button = _sortButtonKey.currentContext.findRenderObject();
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    // 获得控件左下方的坐标
    print("${button.size}");
    print("${button.localToGlobal(Offset.zero)}");
    var a = button.localToGlobal(Offset(0.0, button.size.height), ancestor: overlay);
    // 获得控件右下方的坐标
    var b = button.localToGlobal(button.size.bottomRight(Offset(0, 0)), ancestor: overlay);
    print("${a.dx}, ${a.dy}");
    print("${b.dx}, ${b.dy}");
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(a, b),
      Offset.zero & overlay.size,
    );
    print("$position");
    TextStyle textStyle = TextStyle(
      fontSize: Dimens.font_sp14,
      color: Theme.of(context).primaryColor,
    );
    showPopupWindow(
      context: context,
      fullWidth: true,
      position: position,
      elevation: 0.0,
      child: GestureDetector(
        onTap: () => NavigatorUtils.goBack(context),
        child: Container(
          color: const Color(0x99000000),
          height: Application.screenHeight - b.dy,
          child: ListView.builder(
            physics: ClampingScrollPhysics(),
            itemCount: _sortTypeList.length,
            itemBuilder: (_, index) {
              Color backgroundColor = ThemeUtils.getBackgroundColor(context);
              return Material(
                color: backgroundColor,
                child: InkWell(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Text(
                      _sortTypeList[index],
                      style: index == _sortTypeIndex ? textStyle : null,
                    ),
                  ),
                  onTap: () {
                    NavigatorUtils.goBack(context);
                    setState(() {
                      _sortTypeIndex = index;
                      _getReplyTask = _fetchMainReplies(1);
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _centerText(String text) {
    return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 10),
        child: Text(
          text ?? "",
          style: TextStyles.textGray14,
        ));
  }

  void _showMoreMenus(BuildContext context) {
    BottomSheetUtil.showBottomSheetView(context, _getSheetItems());
  }

  List<BottomSheetItem> _getSheetItems() {
    List<BottomSheetItem> items = List();

    String accountId = Application.getAccountId;
    if (!StringUtil.isEmpty(accountId) && accountId == widget.topic.author.id) {
      if (topic.status == Topic.STATUS_OPEN) {
        // 添加关闭话题按钮
        items.add(BottomSheetItem(
            Icon(
              Icons.lock_open,
              color: Colors.amber,
            ),
            "关闭当前话题", () {
          NavigatorUtils.goBack(context);
          _showDeleteBottomSheet();
        }));
      }
      // 作者自己的内容
//      items.add(BottomSheetItem(Icon(Icons.delete, color: Colors.redAccent), '删除', () {
//        Navigator.pop(context);
//        _showDeleteBottomSheet();
//      }));
    }
    items.add(BottomSheetItem(
        Icon(
          Icons.warning,
          color: Colors.grey,
        ),
        '举报', () {
      NavigatorUtils.goBack(context);
      NavigatorUtils.goReportPage(context, ReportPage.REPORT_TOPIC, widget.topicId.toString(), "话题举报");
    }));
    return items;
  }

  _showDeleteBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SimpleConfirmBottomSheet(
          tip: '这将关闭话题[话题可见，评论功能关闭]，此操作不可撤销',
          confirmText: '确认关闭',
          onTapDelete: () async {
            Utils.showDefaultLoading(context);
            Result r = await TopicApi.modTopicStatus(topic.id, true);
            NavigatorUtils.goBack(context);
            if (r == null) {
              ToastUtil.showToast(context, '服务错误');
            } else {
              if (r.isSuccess) {
                ToastUtil.showToast(context, '关闭成功');
                setState(() {
                  topic.status = Topic.STATUS_CLOSE;
                });
              } else {
                ToastUtil.showToast(context, '用户身份验证失败');
              }
            }
          },
        );
      },
    );
  }
}
