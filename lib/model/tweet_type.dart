import 'dart:ui';

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
};

class TweetTypeEntity {
  final String name;
  final String zhTag;
  final Color color;

  const TweetTypeEntity({this.name, this.zhTag, this.color});

  static const LOVE_CONFESSION = const TweetTypeEntity(
      name: "LOVE_CONFESSION", zhTag: "表白", color: Color(0xffFA8072));
  static const ASK_FOR_MARRIAGE = const TweetTypeEntity(
      name: "ASK_FOR_MARRIAGE", zhTag: "征婚", color: Color(0xffE9967A));
  static const SOMEONE_FIND =
      const TweetTypeEntity(name: "SOMEONE_FIND", zhTag: "寻人");

  static const QUESTION_CONSULT =
      const TweetTypeEntity(name: "QUESTION_CONSULT", zhTag: "问题咨询");
  static const COMPLAINT = const TweetTypeEntity(
      name: "COMPLAINT", zhTag: "吐槽", color: Color(0xffD2B48C));
  static const GOSSIP = const TweetTypeEntity(name: "GOSSIP", zhTag: "闲聊");
  static const HAVE_FUN = const TweetTypeEntity(name: "HAVE_FUN", zhTag: "一起玩");

  static const LOST_AND_FOUND =
      const TweetTypeEntity(name: "LOST_AND_FOUND", zhTag: "失物招领");
  static const HELP_AND_REWARD =
      const TweetTypeEntity(name: "HELP_AND_REWARD", zhTag: "帮我做事");
  static const SECOND_HAND_TRANSACTION =
      const TweetTypeEntity(name: "SECOND_HAND_TRANSACTION", zhTag: "二手交易");
}
