import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/tweet_account.dart';
import 'package:iap_app/util/string.dart';

class Gender {
  final String name;
  final String zhTag;

  const Gender({this.name, this.zhTag});

  static const MALE = const Gender(name: 'MALE', zhTag: '男');
  static const FEMALE = const Gender(name: 'FEMALE', zhTag: '女');
  static const UNKNOWN = const Gender(name: 'UNKNOWN', zhTag: '未知');

  static Gender parseGender(String str) {
    if (StringUtil.isEmpty(str)) {
      return Gender.UNKNOWN;
    }
    str = str.toUpperCase();
    if (str == MALE.name) {
      return MALE;
    }
    if (str == FEMALE.name) {
      return FEMALE;
    }
    return Gender.UNKNOWN;
  }

  static Gender parseGenderByAccount(Account account) {
    if(account == null) {
      return Gender.UNKNOWN;
    }
    return parseGender(account.gender);
  }

  static Gender parseGenderByTweetAccount(TweetAccount account) {
    if(account == null) {
      return Gender.UNKNOWN;
    }
    return parseGender(account.gender);
  }
}

var genderMap = {
  'MALE': Gender.MALE,
  'FEMALE': Gender.FEMALE,
  'UNKNOWN': Gender.UNKNOWN,
};
