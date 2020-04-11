import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class SharedConstant {
  static const String LOCAL_ACCOUNT_ID = "ACCOUNT_ID";

  static const String LOCAL_ACCOUNT_TOKEN = "ACCOUNT_TOKEN";

  static const String LOCAL_ORG_ID = "ORGANIZATION_ID";
  static const String LOCAL_ORG_NAME = "ORGANIZATION_NAME";

  static const String LOCAL_USER_ID = "USER_ID";

  static const String LOCAL_FILTER_TYPES = "USER_PREFER_TYPES";

  static const String ACCOUNT_ID_IDENTIFIER = "acId";

  static const String THEME = "APP_THEME";

  /// 每个版本都应该维护并且更新的版本号
  /// 同时更新 android/app/src/build.gradle
  static const int VERSION_ID_ANDROID = 8;
  static const int VERSION_ID_IOS = 8;
  static const String VERSION_REMARK_ANDROID = "1.2.0";
  static const String VERSION_REMARK_IOS = "1.2.0";

  /// 维护本地屏蔽列表
  static const String MY_UN_LIKED = "MY_UNLIKED";
}
