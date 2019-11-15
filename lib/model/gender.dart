class Gender {
  final String name;
  final String zhTag;
  const Gender({this.name, this.zhTag});

  static const MALE = const Gender(name: 'MALE', zhTag: '男');
  static const FEMALE = const Gender(name: 'FEMALE', zhTag: '女');
  static const UNKNOWN = const Gender(name: 'UNKNOWN', zhTag: '未知');
}

var genderMap = {
  'MALE': Gender.MALE,
  'FEMALE': Gender.FEMALE,
  'UNKNOWN': Gender.UNKNOWN,
};
