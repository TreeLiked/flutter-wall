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

  static const DELICIOUS = const CircleTypeEnum("DELICIOUS", "美食", Icons.local_dining, Colors.orange);
  static const GAME = const CircleTypeEnum("GAME", "游戏", Icons.auto_awesome, Colors.green);
  static const SOCIAL = const CircleTypeEnum("SOCIAL", "社交", Icons.pets, Colors.blue);
  static const STUDY = const CircleTypeEnum("STUDY", "学习", Icons.school, Colors.deepPurple);
  static const LIFE = const CircleTypeEnum("LIFE", "生活", Icons.camera, Colors.lime);
  static const SHARE = const CircleTypeEnum("SHARE", "共享", Icons.music_note, Colors.lightBlueAccent);
  static const UNKNOWN = const CircleTypeEnum("OTHER", "其他", Icons.exposure_minus_1, Colors.blueGrey);

  static CircleTypeEnum fromName(String name) {
    var firstWhere = circleTypeMap.values.firstWhere((element) => element.name == name);
    if (firstWhere == null) {
      firstWhere = UNKNOWN;
    }
    return firstWhere;
  }
}
