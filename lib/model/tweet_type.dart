import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final tweetTypeMap = {
  "LOVE_CONFESSION": TweetTypeEntity.LOVE_CONFESSION,
  "ASK_FOR_MARRIAGE": TweetTypeEntity.ASK_FOR_MARRIAGE,
  "SOMEONE_FIND": TweetTypeEntity.SOMEONE_FIND,
  "QUESTION_CONSULT": TweetTypeEntity.QUESTION_CONSULT,
  "COMPLAINT": TweetTypeEntity.COMPLAINT,
  "GOSSIP": TweetTypeEntity.GOSSIP,
  "HAVE_FUN": TweetTypeEntity.HAVE_FUN,
  "LOST_AND_FOUND": TweetTypeEntity.LOST_AND_FOUND,
  "HELP_AND_REWARD": TweetTypeEntity.HELP_AND_REWARD,
  "SECOND_HAND_TRANSACTION": TweetTypeEntity.SECOND_HAND_TRANSACTION,
  "OTHER": TweetTypeEntity.OTHER,
  "OFFICIAL": TweetTypeEntity.OFFICIAL,
  "AD": TweetTypeEntity.AD,
};

class TweetTypeUtil {
  static Map getFilterableTweetTypeMap() {
    final filteredMap = new Map.fromIterable(
        tweetTypeMap.keys.where(
            (k) => tweetTypeMap[k].filterable && tweetTypeMap[k].visible),
        value: (k) => tweetTypeMap[k]);
    return filteredMap;
  }

  static Map<dynamic, TweetTypeEntity> getVisibleTweetTypeMap() {
    final visibleMap = new Map.fromIterable(
        tweetTypeMap.keys.where((k) => tweetTypeMap[k].visible),
        value: (k) => tweetTypeMap[k]);
    return visibleMap;
  }

  static Map<dynamic, TweetTypeEntity> getPushableTweetTypeMap() {
    final visibleMap = new Map.fromIterable(
        tweetTypeMap.keys.where((k) => tweetTypeMap[k].pushable),
        value: (k) => tweetTypeMap[k]);
    return visibleMap;
  }

  // static Map getAllTweetTypeMap() {
  //   return Map.from(tweetTypeMap);
  // }
}

class TweetTypeEntity {
  final String name;
  final String zhTag;
  final Color color;
  final String coverUrl;
  final IconData iconData;
  final Color iconColor;
  final String intro;

  // 是否可以被本地筛选掉
  final bool filterable;
  // 是否用户可以选择此类型标签发布内容
  final bool pushable;
  // 是否可以被用户取消订阅
  final bool canUnSubscribe;
  // 是否用户可见
  final bool visible;

  const TweetTypeEntity(
      {this.iconData,
      this.iconColor,
      this.name,
      this.zhTag,
      this.color,
      this.coverUrl,
      this.intro = "暂无介绍喔～",
      this.filterable = true,
      this.pushable = true,
      this.canUnSubscribe = true,
      this.visible = true});

  static const LOVE_CONFESSION = const TweetTypeEntity(
      iconData: Icons.favorite,
      iconColor: Color(0xffFA8072),
      name: "LOVE_CONFESSION",
      zhTag: "表白",
      color: Color(0xffFA8072),
      intro: "对你何止一句中意",
      coverUrl:
          "https://iutr-image.oss-cn-hangzhou.aliyuncs.com/almond-donuts/default/type_cover_confession.png");
  static const ASK_FOR_MARRIAGE = const TweetTypeEntity(
      iconData: Icons.people,
      iconColor: Colors.red,
      name: "ASK_FOR_MARRIAGE",
      zhTag: "征婚",
      intro: "我想早恋，但已经晚了",
      color: Colors.red,
      coverUrl:
          "https://iutr-image.oss-cn-hangzhou.aliyuncs.com/almond-donuts/default/type_cover_marriage.png");
  static const SOMEONE_FIND = const TweetTypeEntity(
      iconData: Icons.portrait,
      iconColor: Colors.lightBlue,
      name: "SOMEONE_FIND",
      intro: "世界上所有的相遇都是久别重逢",
      zhTag: "寻人",
      color: Colors.lightBlue);

  static const QUESTION_CONSULT = const TweetTypeEntity(
      iconData: Icons.local_library,
      iconColor: Colors.deepOrangeAccent,
      name: "QUESTION_CONSULT",
      intro: "发布一下，你就知道",
      color: Colors.deepOrangeAccent,
      zhTag: "咨询");

  static const COMPLAINT = const TweetTypeEntity(
      iconData: Icons.mood,
      iconColor: Color(0xffaa7aaF),
      name: "COMPLAINT",
      zhTag: "吐槽",
      color: Color(0xffaa7aaF),
      intro: "日子再坏，也要满怀期待",
      coverUrl:
          "https://iutr-image.oss-cn-hangzhou.aliyuncs.com/almond-donuts/default/type_cover_complaint.png");
  static const GOSSIP = const TweetTypeEntity(
      iconData: Icons.free_breakfast,
      iconColor: Color(0xffEEB4B4),
      intro: "多说话，多喝热水",
      name: "GOSSIP",
      color: Color(0xffEEB4B4),
      coverUrl:
          'https://tva1.sinaimg.cn/large/006y8mN6ly1g870g0gah7j30qo0xbwl7.jpg',
      zhTag: "闲聊");

  static const HAVE_FUN = const TweetTypeEntity(
      iconData: Icons.toys,
      iconColor: Color(0xffDEB887),
      intro: "看到天上的星星了吗？是我打排位掉的",
      name: "HAVE_FUN",
      color: Color(0xffDEB887),
      zhTag: "娱乐");

  static const LOST_AND_FOUND = const TweetTypeEntity(
      iconData: Icons.local_florist,
      iconColor: Colors.grey,
      intro: "你不等我回家，我还能去哪",
      name: "LOST_AND_FOUND",
      color: Colors.grey,
      zhTag: "寻物");

  static const HELP_AND_REWARD = const TweetTypeEntity(
      iconData: Icons.transfer_within_a_station,
      iconColor: Color(0xff778899),
      name: "HELP_AND_REWARD",
      intro: "送人玫瑰，手有余香",
      color: Color(0xff778899),
      zhTag: "帮助");

  static const SECOND_HAND_TRANSACTION = const TweetTypeEntity(
      iconData: Icons.compare_arrows,
      iconColor: Colors.blue,
      name: "SECOND_HAND_TRANSACTION",
      intro: "让价值再飞一会",
      color: Colors.blue,
      zhTag: "交易");

  static const OTHER = const TweetTypeEntity(
      iconData: Icons.public,
      iconColor: Color(0xffB0C4DE),
      intro: "没有别的就选这个吧！",
      name: "OTHER",
      color: Color(0xffB0C4DE),
      zhTag: "其他");

  static const OFFICIAL = const TweetTypeEntity(
      iconData: Icons.check_circle,
      iconColor: Color(0xff8470FF),
      name: "OFFICIAL",
      color: Color(0xff8470FF),
      zhTag: "官方",
      canUnSubscribe: false,
      pushable: false,
      filterable: false);

  static const AD = const TweetTypeEntity(
      iconData: Icons.school,
      iconColor: Color(0xff8B008B),
      name: "AD",
      color: Color(0xff8B008B),
      zhTag: "广告",
      canUnSubscribe: false,
      pushable: false,
      filterable: false,
      visible: false);
}
