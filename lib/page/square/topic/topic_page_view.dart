import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:iap_app/api/topic.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/imgae_container.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/topic/topic.dart';
import 'package:iap_app/model/university.dart';
import 'package:iap_app/page/square/topic/topic_detail_page.dart';
import 'package:iap_app/part/notification/my_sn_card.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/routes/square_router.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TopicPageView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TopicPageView();
  }
}

class _TopicPageView extends State<TopicPageView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<TopicPageView> {
  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController = new RefreshController(initialRefresh: true);

  bool isDark = false;

  int _currentPage = 1;
  List<Topic> topics;

  var _colors = [Colors.blue, Colors.green, Colors.teal, Colors.indigoAccent, Colors.purple];
  TextStyle style;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onRefresh(BuildContext context) async {
//    print('On refresh');
//    _esRefreshController.resetLoadState();
    _currentPage = 1;
    List<Topic> topics = await getData(_currentPage);
    if (topics != null && topics.length > 0) {
      setState(() {
        this.topics = topics;
      });
    } else {
      setState(() {
        this.topics = [];
      });
    }
    _refreshController.refreshCompleted();
  }

  Future<List<Topic>> getData(int page) async {
    List<Topic> topics = await TopicApi.queryTopics(page);
    return topics;
  }

  Future<void> _onLoading() async {
    print('loading more data');

    await Future.delayed(Duration(seconds: 1));

    setState(() {});
    _refreshController.loadComplete();
//    List<BaseTweet> temp = await getData(++_currentPage);
//    tweetProvider.update(temp, append: true, clear: false);
//    if (CollectionUtil.isListEmpty(temp)) {
//      _currentPage--;
//      _esRefreshController.finishLoad(success: true, noMore: true);
//      _refreshController.loadNoData();
//    } else {
//      _esRefreshController.finishLoad(success: true, noMore: false);
//    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    isDark = ThemeUtils.isDark(context);
    style = MyDefaultTextStyle.getTweetSigStyle(context, fontSize: Dimens.font_sp13);

    return Scaffold(
        body: Scrollbar(
      controller: _scrollController,
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _refreshController,
//        scrollController: _scrollController,
        header: WaterDropHeader(
          waterDropColor: Colors.deepPurple,
          complete: const Text('刷新完成'),
        ),
        footer: ClassicFooter(
          loadingText: '正在加载',
          canLoadingText: '释放以加载更多',
          noDataText: '到底了哦',
        ),
        child: CustomScrollView(slivers: <Widget>[
          SliverToBoxAdapter(
              child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: topics == null
                ? Gaps.empty
                : topics.length == 0
                    ? Container(
                        margin: const EdgeInsets.only(top: 20),
                        alignment: Alignment.center,
                        child: Text('暂无数据'),
                      )
                    : Column(
                        children: this
                            .topics
                            .map((topic) => GestureDetector(
                                  onTap: () => NavigatorUtils.push(
                                    context,
                                    SquareRouter.topicDetail + "?topicId=0123",
                                  ),
                                  child: _buildTopicCard(topic),
                                ))
                            .toList()),
          ))
        ]),
        onRefresh: () => _onRefresh(context),
        onLoading: _onLoading,
      ),
    ));
  }

  Widget _buildTitleWithExtra(String titleText, onPress,
      {String moreText = "查看更多",
      Icon suffixIcon = const Icon(Icons.play_arrow, size: 18, color: Colors.grey)}) {
    return Row(
      children: <Widget>[
        Text('$titleText', style: TextStyles.textBold16),
        Expanded(
            child: GestureDetector(
                onTap: onPress,
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                  Text(moreText, style: MyDefaultTextStyle.getTweetNickStyle(context, Dimens.font_sp13p5)),
                  suffixIcon,
                ])))
      ],
    );
  }

  Widget _buildTopicCard(Topic topic) {
//    print("topic card render ${topic.toJson()}");
    return GestureDetector(
        onTap: () => _forwardTopicDetail(context, topic),
        child: Container(
          child: MyShadowCard(
              child: Container(
            padding: const EdgeInsets.only(top: 5.0, left: 2.0, bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Gaps.vGap5,
                _buildTitle(topic.title),
                _buildBodyExtra(topic.body),
                _buildExtraRow(topic.participantsCount, topic.hot),
                _buildTagsRow(topic.tags),
                _buildAuthorInfoRow(topic),
              ],
            ),
          )),
        ));
  }

  void _forwardTopicDetail(BuildContext context, Topic topic) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => TopicDetailPage(topic.id, topic: topic)));
  }

  Widget _buildTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Text(
        title.trim() ?? TextConstant.TEXT_UN_CATCH_ERROR,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.textBold16,
      ),
    );
  }

  Widget _buildImage(String coverUrl) {
    return coverUrl == null
        ? Gaps.empty
        : ImageContainer(
            url: coverUrl,
            maxWidth: Application.screenWidth * 0.6,
            maxHeight: Application.screenHeight * 0.2,
          );
  }

  Widget _buildBodyExtra(String body) {
    return body == null || body.trim().length == 0
        ? Gaps.empty
        : Container(
            margin: const EdgeInsets.only(bottom: 5),
            child: Text(body.trim() ?? TextConstant.TEXT_UN_CATCH_ERROR,
                maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyles.textGray14),
          );
  }

  Widget _buildAuthorInfoRow(Topic topic) {
    return Container(
        margin: const EdgeInsets.only(bottom: 5),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              AccountAvatar(
                avatarUrl: topic.author.avatarUrl,
                size: 22,
                onTap: () => NavigatorUtils.goAccountProfile(context, topic.author),
              ),
              Gaps.hGap4,
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: topic.author.nick,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => NavigatorUtils.goAccountProfile(context, topic.author),
                      style: MyDefaultTextStyle.getTweetNickStyle(context, Dimens.font_sp13p5)),
                  TextSpan(
                      text: ' 创建于 ${TimeUtil.getShortTime(topic.sentTime)}',
                      style: MyDefaultTextStyle.getTweetTimeStyle(context, fontSize: Dimens.font_sp13p5))
                ]),
              ),
//          Expanded(
//              flex: 1,
//              child: Container(
//                alignment: Alignment.centerRight,
//                child: _buildUniRow(topic.university.name ?? TextConstant.TEXT_UN_CATCH_ERROR),
//              ))
            ]));
  }

  Widget _buildExtraRow(int participantsCount, int hot) {
    bool a = participantsCount != null && participantsCount > 0;
    return a
        ? Container(
            margin: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: <Widget>[
                RichText(
                  text: TextSpan(children: [
                    TextSpan(text: '已有 ', style: style),
                    TextSpan(
                        text: '${participantsCount ?? 0}',
                        style: isDark ? style : style.copyWith(color: Colours.dark_button_disabled)),
                    TextSpan(text: '人参与讨论, 热度', style: style),
                    TextSpan(
                        text: '$hot',
                        style: isDark ? style : style.copyWith(color: Colours.dark_button_disabled)),
                  ]),
                )
              ],
            ),
          )
        : Gaps.empty;
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
            color: _colors[Random().nextInt(_colors.length - 1)].withAlpha(isDark ? 50 : 150),
            borderRadius: BorderRadius.circular(5.0)),
        margin: const EdgeInsets.only(right: 10,bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
        child: Text("# $tag", style: TextStyles.textWhite14));
  }

  Widget _buildUniRow(University university) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.5),
      decoration:
          BoxDecoration(color: Colours.app_main.withAlpha(45), borderRadius: BorderRadius.circular(5)),
      child: Text(
        university.name ?? TextConstant.TEXT_UN_CATCH_ERROR,
        style: MyDefaultTextStyle.getTweetSigStyle(context, fontSize: Dimens.font_sp13),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
