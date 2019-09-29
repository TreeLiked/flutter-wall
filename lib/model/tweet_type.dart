final tweetTypeMap = {
  "LOVE_CONFESSION": TweetTypeEntity.LOVE_CONFESSION,
  "ASK_MARRIAGE": TweetTypeEntity.ASK_MARRIAGE,
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

  const TweetTypeEntity({this.name, this.zhTag});

  static const LOVE_CONFESSION =
      const TweetTypeEntity(name: "LOVE_CONFESSION", zhTag: "表白系列");
  static const ASK_MARRIAGE =
      const TweetTypeEntity(name: "ASK_MARRIAGE", zhTag: "我要征婚");
  static const SOMEONE_FIND =
      const TweetTypeEntity(name: "SOMEONE_FIND", zhTag: "寻人");

  static const QUESTION_CONSULT =
      const TweetTypeEntity(name: "QUESTION_CONSULT", zhTag: "问题咨询");
  static const COMPLAINT =
      const TweetTypeEntity(name: "COMPLAINT", zhTag: "吐槽");
  static const GOSSIP = const TweetTypeEntity(name: "GOSSIP", zhTag: "闲聊");
  static const HAVE_FUN = const TweetTypeEntity(name: "HAVE_FUN", zhTag: "一起玩");

  static const LOST_AND_FOUND =
      const TweetTypeEntity(name: "LOST_AND_FOUND", zhTag: "失物招领");
  static const HELP_AND_REWARD =
      const TweetTypeEntity(name: "HELP_AND_REWARD", zhTag: "帮我做事");
  static const SECOND_HAND_TRANSACTION =
      const TweetTypeEntity(name: "SECOND_HAND_TRANSACTION", zhTag: "二手交易");
}
