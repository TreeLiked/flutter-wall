import 'package:flutter/material.dart';

final circleTypeMap = {
  "DELICIOUS": CircleTypeEnum.DELICIOUS,
  "GAME": CircleTypeEnum.GAME,
  "SOCIAL": CircleTypeEnum.SOCIAL,
  "STUDY": CircleTypeEnum.STUDY,
  "LIFE": CircleTypeEnum.LIFE,
  "SHARE": CircleTypeEnum.SHARE,
  "OTHER": CircleTypeEnum.UNKNOWN,
};

class CircleTypeEnum {
  final String name;
  final String zhTag;
  final IconData icon;
  final Color color;

  const CircleTypeEnum(this.name, this.zhTag, this.icon, this.color);

  static const DELICIOUS = const CircleTypeEnum("DELICIOUS", "美食", Icons.local_dining, Color(0xffDAA520));
  static const GAME = const CircleTypeEnum("GAME", "游戏", Icons.auto_awesome, Color(0xff00BFFF));
  static const SOCIAL = const CircleTypeEnum("SOCIAL", "社交", Icons.pets, Color(0xffCDB38B));
  static const STUDY = const CircleTypeEnum("STUDY", "学习", Icons.school, Color(0xffCD5C5C));
  static const LIFE = const CircleTypeEnum("LIFE", "生活", Icons.camera, Color(0xff8B658B));
  static const SHARE = const CircleTypeEnum("SHARE", "共享", Icons.music_note, Color(0xff9ACD32));
  static const UNKNOWN = const CircleTypeEnum("OTHER", "其他", Icons.exposure_minus_1, Color(0xff00BFFF));

  static CircleTypeEnum fromName(String name) {
    var firstWhere = circleTypeMap.values.firstWhere((element) => element.name == name);
    if (firstWhere == null) {
      firstWhere = UNKNOWN;
    }
    return firstWhere;
  }
}
