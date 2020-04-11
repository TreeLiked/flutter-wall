class MemberResultCode {
  /// 参数不合法
  static const String INVALID_PARAM = "519";

  /// 不合法的手机号 不满足手机号格式
  static const String INVALID_PHONE = "520";

  /// 手机号未被注册，不允许登录
  static const String UN_REGISTERED_PHONE = "521";

  /// 手机号已被注册，无法再被注册
  static const String REGISTERED_PHONE = "522";

  /// 登录失败
  static const String LOGIN_ERROR = "523";

  /// 无效的邀请码
  static const String INVALID_INVOCATION_CODE = "524";

  /// 注册失败
  static const String ERROR_REGISTER = "525";

}
