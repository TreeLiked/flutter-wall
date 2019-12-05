class StringUtil {
  static bool isEmpty(String val) {
    return val == null || val.length == 0 || val.trim().length == 0;
  }
}
