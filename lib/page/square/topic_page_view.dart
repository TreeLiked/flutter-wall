import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/part/notification/my_sn_card.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TopicPageView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TopicPageView();
  }
}

class _TopicPageView extends State<TopicPageView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<TopicPageView> {
  List<String> titleList;

  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController = new RefreshController(initialRefresh: false);

  @override
  void initState() {
    this.titleList = [
      "网易云音乐上看到过最触动的热评是什么？",
      "有没有可以摘抄下来的神仙句子",
      "有哪些你第一眼就爱上的电影台词",
      "你和异性发生过的最尴尬的事情是什么",
      "有没有哪些最好一辈子也不必要读懂的话",
      "你和异性发生过的最尴尬的事情是什么",
      "有没有可以摘抄下来的神仙句子",
      "你和异性发生过的最尴尬的事情是什么",
      "网易云音乐上看到过最触动的热评是什么？",
    ];
    super.initState();
  }

  Future<void> _onRefresh(BuildContext context) async {
//    print('On refresh');
//    _esRefreshController.resetLoadState();
//    _currentPage = 1;
//    List<BaseTweet> temp = await getData(_currentPage);
//    tweetProvider.update(temp, clear: true, append: false);
//    setState(() {
//      _lastRefresh = DateTime.now();
//    });
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      this.titleList = [
        "网易云音乐上看到过最触动的热评是什么？",
        "有没有可以摘抄下来的神仙句子",
        "有哪些你第一眼就爱上的电影台词",
        "你和异性发生过的最尴尬的事情是什么",
        "有没有哪些最好一辈子也不必要读懂的话",
        "你和异性发生过的最尴尬的事情是什么",
        "有没有可以摘抄下来的神仙句子",
        "你和异性发生过的最尴尬的事情是什么",
        "网易云音乐上看到过最触动的热评是什么？",
      ];
    });
    _refreshController.refreshCompleted();
  }

  void initData() async {
//    List<BaseTweet> temp = await getData(1);
//    tweetProvider.update(temp, clear: true, append: false);
//    _esRefreshController.finishRefresh(success: true);
  }

  Future<void> _onLoading() async {
    print('loading more data');

    await Future.delayed(Duration(seconds: 1));
    List<String> temp = this.titleList.sublist(0, Random().nextInt(5) + 1);

    setState(() {
      this.titleList.addAll(temp);
    });
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
          complete: const Text('刷新完成', style: TextStyle(color: Colors.grey)),
        ),
        footer: ClassicFooter(
          loadingText: '正在加载',
          canLoadingText: '释放以加载更多',
          noDataText: '到底了哦',
        ),
        child: CustomScrollView(slivers: <Widget>[
          SliverToBoxAdapter(
              child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
                children: this
                    .titleList
                    .map((f) => _buildTopicCard(
                        f, 'https://tva1.sinaimg.cn/large/006tNbRwgy1ga6e7kafy4j30u00u0acu.jpg'))
                    .toList()),
          ))
        ]),
//        child: ListView.builder(
//            shrinkWrap: true,
//            itemCount: this.titleList.length,
//            itemBuilder: (context, index) {
//              print(index);
//              return _buildTopicCard(this.titleList[index], 'https://tva1.sinaimg.cn/large/006tNbRwgy1ga6e7kafy4j30u00u0acu.jpg');
//
//            }),

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

  Widget _buildTopicCard(String title, String accountAvatarUrl) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: MySnCard(
          child: Container(
        padding: const EdgeInsets.only(top: 5.0, left: 2.0, bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title ?? TextConstant.TEXT_UNCATCH_ERROR,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.textSize16,
            ),
            Gaps.vGap5,
            _buildHotReply(),
            Gaps.vGap5,
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              AccountAvatar(
                avatarUrl: Application.getAccount.avatarUrl,
                size: 20,
              ),
              Gaps.hGap4,
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: Application.getAccount.nick,
                      style: MyDefaultTextStyle.getTweetNickStyle(context, Dimens.font_sp13)),
                  TextSpan(text: ' 创建于一小时前', style: MyDefaultTextStyle.getTweetTimeStyle(context)),
                ]),
              ),
              Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: _buildUniRow("南京工程学院"),
                  ))
            ]),
            Gaps.vGap5,
            _buildExtraRow()
          ],
        ),
      )),
    );
  }

  Widget _buildHotReply() {
    return Container(child: Text('hello'));
  }

  Widget _buildUniRow(String uniName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.5),
      decoration:
          BoxDecoration(color: Colours.app_main.withAlpha(25), borderRadius: BorderRadius.circular(8)),
      child: Text(
        uniName,
        style: MyDefaultTextStyle.getTweetSigStyle(context, fontSize: Dimens.font_sp12),
      ),
    );
  }

  Widget _buildExtraRow() {
    return Container(
      child: Row(
        children: <Widget>[
          Text('已有1021人参与讨论，热度203131',
              style: MyDefaultTextStyle.getTweetSigStyle(context, fontSize: Dimens.font_sp12)),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
//      padding: const EdgeInsets.fromLTRB(0, 50, 0, 5),
//      color: Colors.black,
      width: Application.screenWidth,
      height: ScreenUtil().setHeight(315),
      child: Swiper(
        itemCount: titleList.length,
        itemWidth: Application.screenWidth * 0.9,
//        itemHeight: 300,
        itemBuilder: _swiperBuilder,
        duration: 310,
        pagination: SwiperPagination(
            alignment: Alignment.bottomRight,
            builder: DotSwiperPaginationBuilder(
                size: 6.0, activeSize: 6.5, activeColor: Colors.white, color: Colors.black38)),
        controller: SwiperController(),
        scrollDirection: Axis.horizontal,
        autoplay: true,
        layout: SwiperLayout.STACK,
        onTap: (index) => print('点击了第$index'),
      ),
    );
  }

  Widget _swiperBuilder(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: ClipRRect(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(10))),
          child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(children: <Widget>[
                Container(
                  width: double.infinity,
                  color: Colors.lightBlueAccent,
                  child: Column(
                    children: <Widget>[Text('你怎么看一个女孩子谈过很多哥女朋友')],
                  ),
                )

//                CachedNetworkImage(
//                  width: double.infinity,
//                  imageUrl: imageList[index],
//                  fit: BoxFit.fitWidth,
//                  filterQuality: FilterQuality.high,
//                ),
//              BackdropFilter(
//                filter: ImageFilter.blur(
//                  sigmaY: 5,
//                  sigmaX: 5,
//                ),
//                child: Container(
//                  color: Colors.black26,
//                  width: double.infinity,
//                  height: double.infinity,
//                ),
//              ),
//              Positioned(
//                left: 0,
//                top: 0,
//                child: Text('hello'),
              ]))),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
