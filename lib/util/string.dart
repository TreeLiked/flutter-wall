class StringUtil {
  static bool isEmpty(String val) {
    return val == null || val.length == 0 || val.trim().length == 0;
  }

  static String getFirstUrlInStr(String str) {
    if (isEmpty(str)) {
      return null;
    }
    RegExp httpsRegex = new RegExp(r"https?://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]");
    if (httpsRegex.hasMatch(str)) {
      return httpsRegex.firstMatch(str).group(0);
    } else {
      RegExp wwwRegex = new RegExp(r"www.[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]");
      if (wwwRegex.hasMatch(str)) {
        return "http://" + wwwRegex.firstMatch(str).group(0);
      }
    }
    return null;
  }
}
